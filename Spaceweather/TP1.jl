using GLMakie
using DelimitedFiles
using LinearAlgebra

function my_ft( T, X, f )
    FTX = 0
    dt = T[2] - T[1]

    for i in 1:length(T)
        FTX += X[i] * exp( -1im * 2 * pi * f * T[i] ) * dt
    end

    return FTX
end

function my_ft_in_t( T, X, t )
    f = 1/t
    FTX = 0
    dt = T[2] - T[1]

    for i in 1:length(T)
        FTX += X[i] * exp( -1im * 2 * pi * f * T[i] ) * dt
    end

    return FTX
end

function main() 

    monthly_mean_total_sunspot_number = readdlm("SN_m_tot_V2.0.csv", ';', Float64, '\n')

    # arg1 is file name
    # arg2 is column separation
    # arg3 is dtype
    # arg4 is line separation

    T = monthly_mean_total_sunspot_number[:,3]
    T = T #.- T[1]

    SSN = monthly_mean_total_sunspot_number[:,4]

    fig = Figure()

    ax1 = Axis( fig[1,1], title="average SSN of last 1000 months" )
    ax2 = Axis( fig[1,2], title="FT as function of frequency" )
    ax3 = Axis( fig[2,1], title="FT as function of time" )
    ax4 = Axis( fig[2,2], title="FT as function of time with zero-padding" )

    lines!( ax1, T[length(T)-1000:length(T)], SSN[length(T)-1000:length(T)] )

    #############################################

    Ti = (T[length(T)] - T[1])
    dt = (T[2] - T[1])

    df = 0.0001

    F = (1/Ti):df:(0.01/dt)
    FTX = Vector( undef, length(F) )

    for i in 1:length(F)
        FTX[i] = my_ft( T, SSN, F[i] )
    end

    lines!( ax2, F, real(FTX).^2 .+ imag(FTX).^2 )

    #############################################

    Ta = dt*0.5:dt:0.5*Ti
    FTXa = Vector( undef, length(Ta) )

    for i in 1:length(Ta)
        FTXa[i] = my_ft_in_t( T, SSN, Ta[i] )
    end

    lines!( ax3, Ta, real(FTXa).^2 .+ imag(FTXa).^2 )
    lines!( ax3, [11, 11], [-1e1, 5e7] )
    text!( ax3, 15, 4e7, text="11s" )
    lines!( ax3, [105, 105], [-1e1, 5e7] )
    text!( ax3, 110, 4e7, text="105s" )

    #############################################

    Tat = dt*10:dt:1.3*Ti

    Tt = zeros( 4*length(T) )
    for i in 1:4*length(T)
        Tt[i] = T[1] + dt*i
    end

    SSNt = zeros( 4*length(SSN) )
    SSNt[1:length(SSN)] = SSN

    df = 0.01

    FTXta = Vector( undef, length(Tat) )

    for i in 1:length(Tat)
        FTXta[i] = my_ft_in_t( Tt, SSNt, Tat[i] )
    end

    lines!( ax4, Tat, real(FTXta).^2 .+ imag(FTXta).^2 )
    lines!( ax4, [11, 11], [-1e1, 5e7] )
    text!( ax4, 15, 4e7, text="11s" )
    lines!( ax4, [105, 105], [-1e1, 5e7] )
    text!( ax4, 110, 4e7, text="105s" )
    lines!( ax4, [185, 185], [-1e1, 5e7] )
    text!( ax4, 195, 4e7, text="185s" )

    ###############################################

    display( fig )

end

main()