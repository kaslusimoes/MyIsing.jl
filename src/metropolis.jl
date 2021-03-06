##########################################
#                                        #
#   Metropolis Functions Implementation  #
#                                        #
##########################################

# Step of Metropolis' Algorithm
function metropolisstep!(spinmatrix::Array{Int64,2};
                         temp::Float64 = 1.0,
                         h::Float64    = 0.0)

    if temp == 0 error("The Temperature can't be ZERO!!") end

    n = size(spinmatrix, 1)
    x , y = rand(1:n) , rand(1:n) # Generating the postion randomically
    mclose = sum(spinneighbors(spinmatrix, x, y)) # Calculating neighbors' spin sum

    ΔE = 2(h+mclose)*spinmatrix[x,y] # energy necessary to flip the spin
    if ΔE < 0
        flip!(spinmatrix, x, y) # flip spin
    elseif rand() < exp(-ΔE/temp)
        flip!(spinmatrix, x, y) # flip spin
    end
end

# Metropolis' Algorithm for a Given Graph at a Given Temperature
function metropolis!(spinmatrix::Array{Int64,2};
                     temp::Float64  = 1.0,
                     h::Float64     = 0.0,
                     maxit::Int     = 10000,
                     plot::Bool     = true,
                     verbose::Bool  = true)

    mi = Float64[]
    
    for iter in 1:maxit
        metropolisstep!(spinmatrix, temp=temp,h=h)
        push!(mi, abs(magnetization(spinmatrix)))
    end
    
    if verbose 
        # Saving to a .csv that informs Method, Size, Temperature and QtdIterations
        df = DataFrame(Iterations=1:maxit,Magnetization=mi)
        pathcsv = "Data/Metropolis/metropolis_$(size(spinmatrix,1))grid_$(temp)temp_$(int(h))h_$(maxit)iterations"
        writetable(pathcsv, df)

        println("Finished with magnetization $(mi[end])") 
        println("Data saved to file: " * pathcsv)
    end
    if plot plotcsv(pathcsv) end

    return mi[end]
end