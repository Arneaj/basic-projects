using GLMakie
using DelimitedFiles
using LinearAlgebra

function part1()
    T = [ 16, 17, 18, 19, 20, 21, 22, 23 ]
    SSN = [ 145, 120, 102, 73, 54, 51, 58, 106 ]
    CH = [ 0, 1, 4, 3, 3, 5, 5, 7 ]

    fig = Figure()
    ax1 = Axis( fig[1,1], title="SSN as function of time", limits=(16, 23, 0, 150) )
    ax2 = Axis( fig[1,2], title="CH as function of time", limits=(16, 23, 0, 8) )

    band!( ax1, T, SSN, [0,0,0,0,0,0,0,0] )
    barplot!( ax2, T, CH )
    display( fig )
end

function part2()    
    file = readdlm("KP.txt", ' ', Float64, '\n')

    T =  file[:,3] .+ file[:,4]/24
    KP = file[:,8]

    
    fig = Figure()
    ax1 = Axis( fig[1,1], title="Kp as function of time", limits=(16, 23, 0, 4) )

    barplot!( ax1, T, KP, color=:green )
    display( fig )
end

part1()