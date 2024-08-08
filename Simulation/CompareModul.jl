using CSV, DataFrames, GLMakie

# -> Read in the data
data = CSV.read(ARGS[1], DataFrame)
data2 = CSV.read(ARGS[2], DataFrame)

# -> Extract the data from colum with name "k"
k = data.k
k2 = data2.k

# -> Extract the data from colum with name "D_k"
D_k = data.D_k
D_k2 = data2.D_k

# -> Calculate the difference
diff = D_k - D_k2

# -> Write the difference to a file


CSV.write("Difference.csv", DataFrame(k = k, diff = diff))