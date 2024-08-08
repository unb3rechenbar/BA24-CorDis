# using Distributed
# using OrnsteinZernike
# using GLMakie
# using FFTW
# using Statistics
# using ProgressMeter
# using QuadGK
# using NLsolve
# using ForwardDiff
# using Symbolics
# using LinearAlgebra
# using LoopVectorization
# using Base.Threads

using Pkg

if !haskey(Pkg.installed(), "OrnsteinZernike")
    Pkg.add("OrnsteinZernike")
end

if !haskey(Pkg.installed(), "GLMakie")
    Pkg.add("GLMakie")
end

if !haskey(Pkg.installed(), "FFTW")
    Pkg.add("FFTW")
end

if !haskey(Pkg.installed(), "Statistics")
    Pkg.add("Statistics")
end

if !haskey(Pkg.installed(), "ProgressMeter")
    Pkg.add("ProgressMeter")
end

if !haskey(Pkg.installed(), "QuadGK")
    Pkg.add("QuadGK")
end

if !haskey(Pkg.installed(), "NLsolve")
    Pkg.add("NLsolve")
end

if !haskey(Pkg.installed(), "ForwardDiff")
    Pkg.add("ForwardDiff")
end

if !haskey(Pkg.installed(), "Symbolics")
    Pkg.add("Symbolics")
end

if !haskey(Pkg.installed(), "LinearAlgebra")
    Pkg.add("LinearAlgebra")
end

if !haskey(Pkg.installed(), "LoopVectorization")
    Pkg.add("LoopVectorization")
end


