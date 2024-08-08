using CSV, DataFrames, Statistics

# -> Read in the data
data = CSV.read(ARGS[1], DataFrame)

# -> Extract the data from colum with name "k"
k = data.k

# -> Extract the data from colum with name "D_k"
D_k = data.D_k

# -> Get the maximum and minimum of the data
max_D_k = maximum([E for (q, E) in zip(k, D_k) if q <= 14])
min_D_k = minimum([E for (q, E) in zip(k, D_k) if q <= 14])

# -> Print the result
println("The maximum of D_k is: ", max_D_k, " and the minimum of D_k is: ", min_D_k, ", using the data from ", ARGS[1])

# -> Get density
file = split(ARGS[1], "/")[end]
density = split(file, "-")[1]
resolution = split(file, "-")[2]

# -> Save the result; if "-S" in string stored in ARGS[1], then in file "MaxMin-S.csv", else in "MaxMin-nS.csv"; append to file if not written before
if occursin("-S", ARGS[1])
    if occursin("-exp", ARGS[1])
        CSV.write("MaxMin-S-exp.csv", DataFrame(max_D_k = [max_D_k], min_D_k = [min_D_k], density = [density], resolution = [resolution]), append = true)
    else 
        CSV.write("MaxMin-S.csv", DataFrame(max_D_k = [max_D_k], min_D_k = [min_D_k], density = [density], resolution = [resolution]), append = true)
    end
else
    if occursin("-exp", ARGS[1])
        CSV.write("MaxMin-nS-exp.csv", DataFrame(max_D_k = [max_D_k], min_D_k = [min_D_k], density = [density], resolution = [resolution]), append = true)
    else
        CSV.write("MaxMin-nS.csv", DataFrame(max_D_k = [max_D_k], min_D_k = [min_D_k], density = [density], resolution = [resolution]), append = true)
    end
end