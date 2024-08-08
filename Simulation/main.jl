# ==================================================
# Project: Bachelor Thesis 2024: Studies of ERM Models with Correlated Disorder
# Author: Tom Folgmann
# Date: 2024, July/August
# ==================================================


# This file contains the main simulation script for the Bachelor Thesis 2024. The software is provided as is. Run the simulation using runsim.sh.
# ==================================================

# > ============ LOAD PACKAGES ============ <
using Distributed

@everywhere begin
using OrnsteinZernike, FFTW, Statistics, ProgressMeter, QuadGK, NLsolve, ForwardDiff, LinearAlgebra, LoopVectorization, Base.Threads, CSV, DataFrames, SpecialFunctions

function process_args(args)
	if length(args) == 0
		return
	end

	global ρ = parse(Float64, args[1])
	global structure_factor_toggle = parse(Bool, args[2])
	global tmp_path = args[3]
	global iterations_count = parse(Int, args[4])
	global k_max = parse(Int, args[5])
	global exp_g_toggle = parse(Bool, args[6])
	global Heaviside_toggle = parse(Bool, args[7])
end

# > ============ DEFINITION OF INITIAL VALUES ============ <
ρ = 0.2
structure_factor_toggle = false
exp_g_toggle = false
Heaviside_toggle = true
tmp_path = "."

gridpoints = 512


d = 3
kBT = 1.0
ρ = 0.2

ρ_N = 5
ρ_min = 0.1
ρ_max = 1.2
ρRange = range(ρ_min, stop=ρ_max, length = ρ_N)

a = 1

params = (1.0,2.0,1.0)

iterations_count = 1000

k_max = 20
k_samples = gridpoints

θ_samples = 100

multi_ρ_toggle = false
combine_ρ_toggle = false
testplots = false


# > ============ PROCESSING OF ARGUMENTS ============ <
process_args(ARGS)


println("ρ = $ρ")
println("Structure Factor Toggle = $structure_factor_toggle")
println("Tmp Path = $tmp_path")
println("Iterations = $iterations_count")
println("k_max = $k_max")
println("Exp G Toggle = $exp_g_toggle")
println("Heaviside Toggle = $Heaviside_toggle")


# -> Define custom potential
U_num = (r,p) -> 1/2 * (r - p[1])^2
U_test = (r,p) -> 4 * p[1] * ((p[2]/r)^12 - (p[2]/r)^6)
U_ideal = (r,p) -> 0

# -> Define Closure
closure = HypernettedChain()

end


# > ============ DEFINITION OF SPRING FUNCTIONS ============ <
@everywhere function HeavisideSpring(r,p)
	if r < p[3]
		return 1
	else
		return 0
	end
end

@everywhere function GaussianSpring(x,p)
	return exp(-0.5 * x^2)
end

@everywhere function FHeavisideSpring_1d(ω)
	local p = params

	if ω == 0.0
		return 4 * pi * p[3]^3/3
	# elseif ω < 0.01
		# return ((4*pi)/(3))-((2*ω^(2)*pi)/(15))+((ω^(4)*pi)/(210))-((ω^(6)*pi)/(11340))+((ω^(8)*pi)/(997920))-((ω^(10)*pi)/(129729600));
	else
		return 4 * pi * (sin(p[3] * ω) - p[3] * ω * cos(p[3] * ω)) * ω^(-3)
	end
end

@everywhere function FGaussianSpring_1d(ω)
	local p = params

	testint = (l,q) -> 4 * pi * quadgk(x -> exp(-0.5 * x^2) * x^2 * sin(q * x)/(q * x), 0, l)[1]

	return testint(Inf, ω)
end

	

# > ============ DEFINITION OF POTENTIAL FUNCTIONS ============ <
@everywhere function U_HeavisideSpring(r, p)
    if r < p[3]
        return 0.5 * (r - p[1])^p[2]
    else
        return 0
    end
end

@everywhere function U_GaussianSpring(r, p)

	int = t -> (pi/2)^(0.5) * t * erf(t * (0.5)^(0.5)) + exp(-0.5 * t^2) - 1

	return int(r)
end

# > ============ DEFINITION OF ALGORITHM FUNCTIONS ============ <

@everywhere Ff = q -> begin 
	if Heaviside_toggle
		return FHeavisideSpring_1d(q)
	else
		return FGaussianSpring_1d(q)
	end
end

@everywhere function Uf(q, p)
	if Heaviside_toggle
		return U_HeavisideSpring(q, p)
	else
		return U_GaussianSpring(q, p)
	end
end


# > ============ FUNCTION TO PROCESS SYSTEM ============ <

@everywhere function Process_System(d, ρ, kBT)
	# -> Define system potential (model)
	potential = CustomPotential(Uf, params)

	# -> Create System struct
	system = SimpleLiquid(d, ρ, kBT, potential)

	# -> generate solution from system parameters
	method = NgIteration(M=gridpoints)
	solution = @time solve(system, closure, method)

	print(length(solution.r))

	gmE = [x - 1 for x in solution.gr]

	# -> Prepare Integration for cFT
	ΔrRange = [solution.r[i] - solution.r[i-1] for i in 2:length(solution.r)]
	Δr = mean(ΔrRange)

	# -> Calculate int (g(|r|) - 1) * e^(i k r) dr on [-R,R]^3
	cFT_integrand_old = (q,r) -> im * (r * q)^(-1) * (exp(-im * r * q) - exp(im * r * q)) * r^2 # q are integers
	cFT_integrand = (q,r) -> 2 * sinc(q * r) * r^2
	
	cFT = q -> begin
		if exp_g_toggle
			sum(2 * pi * (exp(-1 * Uf(r, params)) - 1) * JacDet * Δr for (JacDet,r) in zip(cFT_integrand.(q, solution.r),solution.r))
		else 
			sum([2 * pi * gm * JacDet * Δr for (JacDet,gm,r) in zip(cFT_integrand.(q, solution.r),[x - 1 for x in solution.gr],solution.r)]) # use cFT_integrand on all r values from solution.r, then discretely integr.
		end
	end

	# -> Calculate Structure Factor S(k)
	S_k = q -> 1 + ρ * real(cFT(q))

	return solution, cFT, S_k
end

@everywhere function Dyson_Iteration(solution, cFT, S_k)

	# -> Calculate vertices
	BarePropagator = (ω,z) -> begin
		# if ρ > 0.8
			return 1 / (z - ρ * (Ff(0) - Ff(ω)))
		# else
		# 	if ω == 0
		# 		return 0
		# 	else
		# 		IntVal = 4 * pi * exp(-0.5) * ω^(-1) * quadgk(r -> r * sin(ω * r) * exp(r - r^2/2), 0, Inf)[1]
		# 		return IntVal
		# 	end
		# end
	end
	Vertex = (x,y) -> (Ff(x) - Ff(y))

	# -> Discretize the wave vector range
	Q = range(0.1, stop=k_max, length = k_samples)
	ΔQ = Q[2] - Q[1]
	Gv = z -> BarePropagator.(Q,z)	# Function to generate initial guess

	# -> Discretize the angle range
	θRange = range(0, stop=pi, length = θ_samples)
	Δθ = θRange[2] - θRange[1]

	# -> Define safe norm function
	NormPminusSph_safe = (p,r,θ) -> begin
		norm_val = (p^2 + r^2 - 2 * p * r * cos(θ))^0.5
		if norm_val <= 0
			# println("Norm value is negative at p = $p, r = $r, θ = $θ. Using eps instead.")
			norm_val = eps()
		end
		return norm_val
	end

	# -> Check all occuring Norm values for S(k)
	S_safe = q -> begin
		S_k_val = S_k(q)
		if isnan(S_k_val)
			throw(ArgumentError("S(k) is NaN at $q"))
		end

		if structure_factor_toggle
			return S_k_val
		else
			return 1
		end
	end

	# -> Define integrand
	Integrand = Gv -> (p, q, θ) -> begin
	    norm_val = NormPminusSph_safe(p, q, θ)
	    if norm_val <= 0
	        throw(ArgumentError("Norm value is negative at p = $p, r = $q, θ = $θ"))
	    end
	    if structure_factor_toggle
	    	return S_safe(norm_val) * Vertex(q,norm_val)^2 * q^2 * sin(θ) * (2 * pi)^(-2)
		else 
			return 1 * Vertex(q,norm_val)^2 * q^2 * sin(θ) * (2 * pi)^(-2)
		end
	end

	# -> Build Integration matrix
	IntegrationMatrix = zeros(length(Q), length(Q))

	# -> Fill Integration matrix
	@time @showprogress @threads for i in 1:length(Q)
		p = Q[i]
		for j in 1:length(Q)
			q = Q[j]
			if j == 1
				IntegrationMatrix[j,i] = sum(Integrand(Gv)(p,q,θ) * Δθ for θ in θRange)
			else 
				IntegrationMatrix[j,i] = sum(Integrand(Gv)(p,q,θ) * Δθ for θ in θRange) * (Q[j] - Q[j-1])
			end
		end
	end

	# -> Define Integral using Matrix Multiplication
	MDiscreteOneLoopSelfEnergy = Gv -> (IntegrationMatrix * Gv)

	# -> Define Iterator function
	MIterator = Gv -> [(z - ρ * (Ff(0) - Ff(p)) - ρ * MDiscreteOneLoopSelfEnergy(Gv)[i])^(-1) for (i,p) in enumerate(Q)]

	# -> Define initial values
	z = 0.0
	initial_Gv = Gv(0.0)

	# -> Perform Iteration
	println("Setup completed, performing Dyson Iteration")
	result = @time fixedpoint(x -> MIterator(x), initial_Gv, show_trace = true, ftol=1e-2, iterations = iterations_count)

	# SOLVER = "newton"

	return result
end


@everywhere function Draw_Figure(solution, cFT, S_k, results = nothing)
	println("Drawing figure")

	# -> Create Figure
	fig = Figure()
	println("Figure created")

	# -> Create FT Samples
	kRange = collect(range(0, stop=k_max, length = k_samples))
	cFT_Range = real.(cFT.(kRange))
	println("FT samples created")

	# -> Create Structure Factor Samples
	S_k_Range = S_k.(kRange)
	println("Structure Factor samples created")

	# -> Create Propagator Samples
	if results != nothing
		Propagator_Result = results.zero
		
		ax4 = Axis(fig[2,2], xlabel = "k", ylabel = "G(k)", title = "Propagator")
		lines!(ax4, kRange, [x^(-1) for x in Propagator_Result], color = :blue)

		ax5 = Axis(fig[2,3], xlabel = "k", ylabel = "-G(k)^(-1)", title = "Dispersion relation")
		lines!(ax5, kRange, [-x^(-1) for x in Propagator_Result], color = :blue)
	end
		

	# -> Create axis
	ax1 = Axis(fig[1,1], xlabel = "r", ylabel = "g(r)", title = "Radial Distribution Function")
	ax2 = Axis(fig[1,2], xlabel = "k", ylabel = "|(Fg)(k)|", title = "Fourier Transform of g(r)")
	ax3 = Axis(fig[2,1], xlabel = "k", ylabel = "S(k)", title = "Structure Factor")

	# -> Draw lines
	lines!(ax1, solution.r, solution.gr, color = :blue)
	lines!(ax2, kRange, cFT_Range, color = :blue)
	lines!(ax3, kRange, S_k_Range, color = :blue)

	return fig
end

@everywhere function Create_CSV(solution, cFT, S_k, results = nothing)
	println("Creating CSV")

	# -> Create Q Range
	kRange = collect(range(0, stop=k_max, length = k_samples))
	cFT_Range = real.(cFT.(kRange))
	println("FT samples created")

	# -> Create Structure Factor Samples
	S_k_Range = S_k.(kRange)
	println("Structure Factor samples created")

	# -> Create Propagator Samples
	if results != nothing
		Propagator_Result = [x^(-1) for x in results.zero]
	end

	# -> Create DataFrame
	data = DataFrame(	r = vcat(solution.r),
						gr = vcat(solution.gr),
						k = vcat(kRange),
						Fg_k = vcat(cFT_Range),
						S_k = vcat(S_k_Range),
						G_k = vcat(Propagator_Result),
						D_k = vcat([-x for x in Propagator_Result]))

	return data
end


if multi_ρ_toggle
	# check if directory exists
	if !isdir("$tmp_path/$ρ_min-$ρ_max")
		mkdir("$tmp_path/$ρ_min-$ρ_max")
	end

	@showprogress pmap(ρRange) do ρ_current
		println("ρ = $ρ_current")

		if structure_factor_toggle
			filename="$ρ_current-$k_samples-S"
		else
			filename="$ρ_current-$k_samples"
		end

		# -> Process System
		solution, cFT, S_k = Process_System(d, ρ_current, kBT)

		# -> Perform Dyson Iteration
		Propagator_Result = Dyson_Iteration(solution, cFT, S_k)

		try
			figure = Draw_Figure(solution, cFT, S_k, Propagator_Result)

			save("$tmp_path/$ρ_min-$ρ_max/$filename.png", figure)

			data = Create_CSV(solution, cFT, S_k, Propagator_Result)
			CSV.write("$tmp_path/$ρ_min-$ρ_max-noS/$filename.csv", data)

			println("Saved $ρ_current")

			println("Graphs drawn")
		catch e
			println("Error drawing the figure at $ρ_current")
			println(stacktrace(catch_backtrace()))
		end
	end	
elseif combine_ρ_toggle
	combined_fig = Figure()

	# -> Prepare combined figure axis
	kRange = collect(range(0, stop=k_max, length = k_samples))

	ax1 = Axis(combined_fig[1,1], xlabel = "r", ylabel = "g(r)", title = "Radial Distribution Function")
	ax2 = Axis(combined_fig[1,2], xlabel = "k", ylabel = "|(Fg)(k)|", title = "Fourier Transform of g(r)")
	ax3 = Axis(combined_fig[2,1], xlabel = "k", ylabel = "S(k)", title = "Structure Factor")
	ax4 = Axis(combined_fig[2,2], xlabel = "k", ylabel = "G(k)", title = "Propagator")

	@showprogress pmap(ρRange) do ρ
		println("ρ = $ρ")

		solution, cFT, S_k = Process_System(d, ρ, kBT)

		result = Dyson_Iteration(solution, cFT, S_k).zero
		
		try
			# -> Draw y values of system
			cFT_Range = real.(cFT.(kRange))
			S_k_Range = S_k.(kRange)

			# -> Draw lines
			restr_r = [x for x in solution.r if x < 2]
			restr_gr = [y for (x,y) in zip(solution.r,solution.gr) if x < 2]
			
			lines!(ax1, restr_r, restr_gr, label = "$ρ")
			lines!(ax2, kRange, cFT_Range, label = "$ρ")
			lines!(ax3, kRange, S_k_Range, label = "$ρ")
			lines!(ax4, kRange, result, label = "$ρ")

			println("Density $ρ drawn")
		catch e
			println("Error drawing the figure at $ρ")
			println(stacktrace(catch_backtrace()))
		end
	end
	
	# -> Add legends
	axislegend(ax1, position = :rb, "ρ")
	axislegend(ax2, position = :rb, "ρ")
	axislegend(ax3, position = :rb, "ρ")
	axislegend(ax4, position = :rb, "ρ")

	# -> Show figure
	display(combined_fig)
	wait()

elseif testplots
	fig = Figure()
	ax = Axis(fig[1,1], xlabel = "q", ylabel = "Ff(q)", title = "Ff(q)")

	solution, cFT, S_k = Process_System(d, ρ, kBT)

	qRange = collect(range(-k_max, stop=k_max, length = k_samples))
	testf_Range = cFT.(qRange)

	exp_g_toggle = false

	solution, cFT, S_k = Process_System(d, ρ, kBT)
	noexp_testf_Range = cFT.(qRange)

	lines!(ax, qRange, noexp_testf_Range, color = :blue)


	lines!(ax, qRange, testf_Range, color = :red)

	display(fig)
	wait()
else
	if structure_factor_toggle
		filename="$ρ-$k_samples-$k_max-S.csv"
	else
		filename="$ρ-$k_samples-$k_max.csv"
	end
	
	if exp_g_toggle
		filename = replace(filename, ".csv" => "-exp.csv")
	end

	if Heaviside_toggle
		filename = replace(filename, ".csv" => "-Heaviside.csv")
	else 
		filename = replace(filename, ".csv" => "-Gaussian.csv")
	end

	if @isdefined(SOLVER)
		filename = replace(filename, ".csv" => "-$SOLVER.csv")
	end

	solution, cFT, S_k = Process_System(d, ρ, kBT)

	# -> Perform Dyson Iteration
	Propagator_Result = Dyson_Iteration(solution, cFT, S_k)

	# -> Save figure
	# save("$tmp_path/$filename.png", Draw_Figure(solution, cFT, S_k, Propagator_Result))

	# -> Save CSV
	CSV.write("$tmp_path/$filename", Create_CSV(solution, cFT, S_k, Propagator_Result))

	# -> Show figure
	# display(Draw_Figure(solution, cFT, S_k, Propagator_Result))
	# wait()
end

println("All tasks completed")
