using CSV, DataFrames, Statistics

# -> Read in the data
data = CSV.read(ARGS[1], DataFrame)

# -> Extract the data from colum with name "k"
k = data.k

# -> Extract the data from colum with name "D_k"
D_k = data.D_k

# -> Define the function for the velocity of sound
VelocityOfSound(k, D_k) = mean([E^(0.5)/q for (E,q) in zip(D_k,k) if E > 0 && q > 0])

# -> Calculate the velocity of sound
v = VelocityOfSound(k, D_k)

# -> Print the result
println("The velocity of sound is: ", v, " m/s, using the data from ", ARGS[1])

# -> Get density 
file = split(ARGS[1], "/")[end]
density = split(file, "-")[1]
resolution = split(file, "-")[2]

# -> Save the result; if "-S" in string stored in ARGS[1], then in file "VelocityOfSound-S.csv", else in "VelocityOfSound-nS.csv"; append to file if not written before
if occursin("-S", ARGS[1])
    if occursin("-exp", ARGS[1])
        CSV.write("VelocityOfSound-S-exp-fixed.csv", DataFrame(v = [v], density = [density], resolution = [resolution]), append = true)
    else
        CSV.write("VelocityOfSound-S-fixed.csv", DataFrame(v = [v], density = [density], resolution = [resolution]), append = true)
    end
else
    if occursin("-exp", ARGS[1])
        CSV.write("VelocityOfSound-nS-exp-fixed.csv", DataFrame(v = [v], density = [density], resolution = [resolution]), append = true)
    else
        CSV.write("VelocityOfSound-nS-fixed.csv", DataFrame(v = [v], density = [density], resolution = [resolution]), append = true)
    end
end