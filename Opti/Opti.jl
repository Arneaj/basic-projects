using LinearAlgebra
using GLMakie

global const muT = 3.986E14
global const muL = 4.904E12

global const RT = 6.378E6
global const RL = 1.737E6

global const g0 = 9.81
global const Isp = 5E3
global const S0 = 3.2*3.9

function grad( L, x::Vector, h::Float64 )
    H = h*Matrix{Float64}(I, length(x), length(x))
    gr::Vector = zeros( length(x) )

    for i in 1:length(x)
        gr[i] = ( L(x+H[:,i]) - L(x) ) / h
    end

    return gr
end

function grad_descent( L, x0, h, delta, step )
    Step = step*Matrix{Float64}(I, length(x0), length(x0)) .+ x0/1E3
    xa = x0
    xb = xa - step * grad(L, xa, h)
    print( xa )
    print( xb )

    i = 0
    while (norm( xb-xa ) <= delta && i < 10)
        xa = xb
        xb = xa - step * grad(L, xa, h)
        if (i%10 == 0) print( xa ) end
        i+=1
    end

    print( L(xb) )
end

function J2( x::Vector ) 
    eT = x[1]
    eL = x[2]
    aT = x[3]
    aL = x[4]
    return 2*sqrt(muT/aT) * ( abs(sqrt(2/(1+eT)+1) - sqrt(2/(1+eT)-1)) ) + 2*sqrt(muL/aL) * ( abs(sqrt(2/(1+eL)+1) - sqrt(2/(1+eL)-1)) ) 
end

function J3( x::Vector ) 
    eT = x[1]
    eL = x[2]
    aT = x[3]
    aL = x[4]
    return 2*sqrt(muT/aT) * ( abs(sqrt(2/(1-eT)+1) - sqrt(2/(1-eT)-1)) ) + 2*sqrt(muL/aL) * ( abs(sqrt(2/(1-eL)+1) - sqrt(2/(1-eL)-1)) ) 
end

function J_full_mission( x::Vector ) 
    eT = x[1]
    eL = x[2]
    aT = x[3]
    aL = x[4]
    return 2*sqrt(muT/aT) * ( abs(sqrt(2/(1-eT)-1)) ) + 2*sqrt(muT/aT) * ( abs(sqrt(2/(1-eT)+1) - sqrt(2/(1-eT)-1)) ) + 2*sqrt(muL/aL) * ( abs(sqrt(2/(1-eL)+1) - sqrt(2/(1-eL)-1)) )
end

function J_pit_stop( x::Vector ) 
    eT = x[1]
    eL = x[2]
    aT = x[3]
    aL = x[4]
    return 2*sqrt(muL/aL) * ( abs(sqrt(2/(1-eL)+1) - sqrt(2/(1-eL)-1)) )
end

function g1( x::Vector )
    eT = x[1]
    eL = x[2]
    aT = x[3]
    aL = x[4]
    return [-eT, eT-1, -eL, eL-1, RT-aT*(1-eT), RL-aL*(1-eL)]
end

function main()
    initial_mass = 4.8E5

    TT = 2*pi*sqrt( (RT+5*RT)^3 / muT ) / 3600
    TL = 2*pi*sqrt( (RL+5*RL)^3 / muL ) / 3600

    ideal_delta_V = J_full_mission([0.8, 0.8, RT+5*RT, RL+5*RL]) 

    ideal_delta_fuel = initial_mass * ( 1 - exp(-ideal_delta_V/(g0*Isp)) )

    ideal_cost = ideal_delta_fuel*0.27

    ISP = [ isp for isp in 2E3:1E2:3E4 ]
    DF = [ ( 1 - exp(-ideal_delta_V/(g0*isp)) ) * 100 for isp in ISP ]
    C = [ df*0.27 for df in DF ]

    @show TT
    @show TL

    @show ideal_delta_V
    @show ideal_delta_fuel
    @show ideal_cost

    fig = Figure()
    theme_dark()
    ax = Axis( fig[1, 1] )
    lines!( ax, ISP, DF )

    display(fig)

    return
end





