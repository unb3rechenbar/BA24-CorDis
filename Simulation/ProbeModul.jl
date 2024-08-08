using CSV, DataFrames, GLMakie

# -> Read in the data
data = CSV.read(ARGS[1], DataFrame)

# -> Extract the data from colum with name "k"
k = data.k

# -> Extract the data from colum with name "D_k"
S_k = data.S_k
D_k = data.D_k

# -> Prepare figure with the data
fig = Figure()
ax = Axis(fig[1, 1], xlabel = "q", ylabel = "D(q)", title = "Structure factor D(q) for density $(split(split(ARGS[1], "/")[end], "-")[1]) and resolution $(split(split(ARGS[1], "/")[end], "-")[2])")
ax2 = Axis(fig[1, 2], xlabel = "q", ylabel = "S(q)")
lines!(ax, k, D_k, color = :blue)
lines!(ax2, k, S_k, color = :red)
# title!(ax, "Structure factor D(q) for density $(split(split(ARGS[1], "/")[end], "-")[1]) and resolution $(split(split(ARGS[1], "/")[end], "-")[2])")

# -> Show the figure
display(fig)
wait()