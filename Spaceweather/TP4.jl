using GLMakie
using DelimitedFiles
using LinearAlgebra

###############################

function F( M, x )
    return M^2 / 2 - log(M) - 2*log(x) - 2/x #+ 1.5
end

function F_M( M, x0=0.5 )
    return M^2 / 2 - log(M) - 2*log(x0) - 2/x0
end

function dFdM( M, x )
    return M - 1/M
end

function NewtonRaphson( fun, dfun, y0, eps, x )
    y = y0
    g = fun( y0, x )
    i = 0

    while abs(g) >= eps && i <= 1000
        y = y - fun( y, x ) / dfun( y, x )
        y = y <= 0 ? 0.01 : y
        y = y >= 10 ? 10 : y

        g = fun( y, x )
        i+=1
    end

    return y
end

function carve( V )
    Va = []
    for v in V
        add = true
        if v > 10 || v < 0 continue end
        for va in Va
            if abs(v - va) < 0.01 add = false end
        end
        if add push!( Va, v ) end
    end
    return Va
end

###############################

function main()

    X = 0.01:0.01:3
    MM = 0.01:0.01:3

    F_xM = [ F( M, x ) for M in MM, x in X ]

    fig = Figure( fontsize=20 )
    ax = Axis( fig[1,1], title=L"Contour of the $F$ function as function of $M$ and $x$" )

    contour!( ax, MM, X, F_xM, levels = -2:0.1:0, labels=true, colormap=:managua )

    @show ( F( 1, 1 ) )

    display( fig )

    return
end

function main2()

    MM0 = [0.2, 2.8]
    MM = 0.05:0.05:3
    X = 0.05:0.05:3

    MM_sol = [ NewtonRaphson( F, dFdM, M0, 0.0001, x ) for x in X, M0 in MM0 ]

    fig = Figure( fontsize=20 )
    ax = Axis( fig[1,1], limits = (0, 3, 0, 3), title=L"Contour of the $F$ function as function of $M$ and $x$ at F=0 (with Newton method)" )
    lines!( ax, MM_sol[:, 1], X )
    lines!( ax, MM_sol[:, 2], X )

    display( fig )

    return
end

################################

global const mp = 1.67e-27
global const kB = 1.3807e-23
global const G = 6.67e-11
global const Ms = 2e30

function css( T )
    return sqrt( 2*T*kB / mp )
end

function main3()
    RS = 6.96e8
    RT = 215*RS

    T0 = 624853
    cs = css(T0)

    xT = RT * 2 * cs^2 / (G*Ms)

    M0 = 3

    MT = NewtonRaphson( F, dFdM, M0, 0.001, xT )
    @show vT = MT * cs

    TT = 6000:1000:700000
    CS = [ css(T) for T in TT ]
    VT = [ MT * cS for cS in CS ]

    fig = Figure( fontsize=20 )
    ax = Axis( fig[1,1], xscale=log10, title=L"Wind speed $V_S$ at Earth as function of $T_0$" )
    lines!( ax, TT, VT )

    lines!( ax, [T0, T0], [1e3, 5e5] )
    lines!( ax, [6000, 1e6], [4e5, 4e5] )
    text!(250000, 410000, text = L"(624853 K, \,\, 400000 m/s)")

    display( fig )

    return
end

main3()