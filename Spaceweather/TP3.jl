using GLMakie
using DelimitedFiles
using LinearAlgebra
using SphericalHarmonics

global const Omega = 2.6e-6

function phi( r, theta, v_r )
    return Omega * r * sin(theta) / v_r
end

function main_1()
    theta = pi/2
    v_r_1 = 4e5
    v_r_2 = 7e5
    R_E = 1.49e11
    circle = 0:0.01:2*pi
    Phi0 = 0:pi/5:2*pi

    R = 1e8:1e8:3e11
    PHI1 = [ phi( r, theta, v_r_1 ) for r in R ]
    PHI2 = [ phi( r, theta, v_r_2 ) for r in R ]

    fig = Figure( )
    ax1 = PolarAxis( fig[1,1] )
    ax2 = PolarAxis( fig[1,2] )

    lines!( ax1, circle, R_E*ones( length(circle) ), linewidth=3 )
    lines!( ax2, circle, R_E*ones( length(circle) ), linewidth=3 )

    for phi0 in Phi0
        lines!( ax1, phi0 .+ PHI1, R, color=:red )
        lines!( ax2, phi0 .+ PHI2, R, color=:red )
    end
    
    display( fig )

    return
end

######################

global const Rss = 2.5  #something idfk
global const Rstar = 1  #star radius

function eps_l0( Br, lmax )
    THETA = 0:0.01:pi
    EPS_lm = [ Br(theta, Rstar) * computeYlm(theta, 0, lmax = lmax, m_range=SphericalHarmonics.ZeroTo, SHType = SphericalHarmonics.RealHarmonics())[1+Int64(0.5*i*(i-1))] * sin(theta) for theta in THETA, i in 1:lmax ]

    return 2*pi * [ sum(EPS_lm[:, i]) for i in 1:lmax ]
end

function Br1( theta, r )
    return 2*cos(theta)/(r^3)
end

function alpha_l0( EPS_l0, r, lmax )
    A = Rstar/Rss
    B = r/Rstar
    
    return [ EPS_l0[l] * ( l*A^(2*l+1)*B^(l-1) + (l+1)*B^(-l-2) )/( l*A^(2*l+1) + l+1 ) for l in 1:lmax ]
end

function main_2()

    lmax = 5

    dxy = 0.005

    X = -5*Rstar:dxy:5*Rstar
    Y = -5*Rstar:dxy:5*Rstar

    R = Rstar:0.001:(5*Rstar)
    THETA = -pi:0.001:pi

    EPS_l0 = eps_l0( Br1, lmax )

    #@show EPS_l0

    ALPHA_l0_of_R = [ alpha_l0( EPS_l0, r, lmax )[i] for r in R, i in 1:lmax ]
    #ALPHA_l0_of_XY = [ alpha_l0( EPS_l0, sqrt(x^2+y^2), lmax )[i] for x in X, y in Y, i in 1:lmax ]

    #@show ALPHA_l0_of_R[1,:]

    Y_l0 = [ computeYlm(theta, 0, lmax = lmax, m_range=SphericalHarmonics.ZeroTo, SHType = SphericalHarmonics.RealHarmonics())[1+Int64(0.5*i*(i-1))] for i in 1:lmax, theta in THETA ]
    BR = [ sum( ALPHA_l0_of_R[i,:] .* Y_l0[:,j] ) for i in 1:length(R), j in 1:length(THETA) ]

    BR_xy = zeros( (length(X), length(Y)) )
    for ir in 1:length(R), ith in 1:length(THETA)
        x = R[ir] * cos( THETA[ith] )
        y = R[ir] * sin( THETA[ith] )
        
        ix::Int16 = round(1 + (length(X)-1) * (x+5*Rstar)/(10*Rstar))
        iy::Int16 = round(1 + (length(Y)-1) * (y+5*Rstar)/(10*Rstar))

        BR_xy[ix, iy] = BR[ir, ith]
    end

    fig = Figure( fontsize=20 )
    ax1 = Axis( fig[1,1], aspect = DataAspect(), title=L"2D image of Sun's $B_r$, units in solar radii" )
    ax2 = Axis( fig[1,2], aspect = AxisAspect(1), title=L"Sun's $B_r$, as function of $r$ in solar radii, for different values of $\theta$" )

    image!( ax1, (-5, 5), (-5, 5), BR_xy, colormap=:managua )

    for i in 1:100:length(THETA)
        lines!( ax2, R, BR[:, i] )
    end

    #image!( ax2, R, THETA, BR, colormap=:managua )

    display( fig )

    return
end

main_1()