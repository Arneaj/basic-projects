using GLMakie
using LinearAlgebra

function U(A, B, Omega, x)
    return A * cos(Omega*x) + B * sin(Omega*x) 
end

function YtoR(Y)
    return 3 .+ Y #/ maximum(Y)
end

function RThtoUV(R, TH)
    return (R.*cos.(TH), R.*sin.(TH))
end

function A2det(A, Omega, L)
    abs( mod(Omega, 2*pi/L) - pi/L ) <= 0.01 ? 0 : A
end

function B2det(A, B, Omega, L)
    abs( mod(Omega, 2*pi/L) - pi/L ) <= 0.01 ? B : A * sin(Omega*L) / (cos(Omega*L)+1)
end

function A7det(A, B, Omega, L)
    abs( mod(Omega, 2*pi/L) - pi/L ) <= 0.01 ? A : - B * sin(Omega*L) / (cos(Omega*L)+1)
end

function B7det(B, Omega, L)
    abs( mod(Omega, 2*pi/L) - pi/L ) <= 0.01 ? 0 : B
end

function A8det(A, n)
    n % 2 == 0 ? 0 : A
end

function B8det(B, n)
    n % 2 == 0 ? 0 : B
end

function main()
    L = 1
    X = 0:0.001:L

    TH = X*2*pi/L

    R0 = [ 10 for _ in 0:0.001:L ]

    dt = 0.01
    T = 0:dt:5

    AA = 1
    BB = 1.5
    OO = 4
    OOO = (2*2+1)*pi/L
    N = 5
    NU = 0.5
    EPS = 10
    DEL = 0.5

    t = Observable( 0.0 )

    R1 = @lift( [ 10 + U(A, B, 2*pi*n/L, x)*cos(6*$t) for x in X, A in AA, B in BB, n in N ] )

    R2 = @lift( [ 10 + U(A2det(A, O, L), B2det(A, B, O, L), O, x)*cos(6*$t) for x in X, A in AA, B in BB, O in OO ] )
    R2bis = @lift( [ 10 + U(A2det(A, O, L), B2det(A, B, O, L), O, x)*cos(6*$t) for x in X, A in AA, B in BB, O in OOO ] )

    R3 = @lift( [ 10 + U(A, nu/(2*2*pi*n/L), 2*pi*n/L, x)*cos(6*$t) for x in X, A in AA, nu in NU, n in N ] )

    R4 = @lift( [ 10 + U(A, nu/((1-eps)*2*pi*n/L), 2*pi*n/L, x)*cos(6*$t) for x in X, A in AA, nu in NU, eps in EPS, n in N ] )

    R5 = @lift( [ 10 + U(A, eps/del * sqrt( (1-del^2)/(eps^2-1) ) * A, acos( (del*eps+1)/(del+eps) )/L + 2*pi*n/L, x)*cos(6*$t) for x in X, A in AA, del in DEL, eps in EPS, n in N ] )

    R6 = @lift( [ 10 + U(0, B, 2*pi*n/L, x)*cos(6*$t) for x in X, B in BB, del in DEL, n in N ] )

    R7 = @lift( [ 10 + U(A7det(A, B, O, L), B7det(A, O, L), O, x)*cos(6*$t) for x in X, A in AA, B in BB, O in OO ] )
    R7bis = @lift( [ 10 + U(A7det(A, B, O, L), B7det(A, O, L), O, x)*cos(6*$t) for x in X, A in AA, B in BB, O in OOO ] )

    R8 = @lift( [ 10 + U(A8det(A, n), A8det(B, n), pi*n/L, x)*cos(6*$t) for x in X, A in AA, B in BB, n in N ] )

    #################

    fig = Figure()

    axes = [ PolarAxis( fig[i,j], rminorgridvisible = false, thetaminorgridvisible = false, rgridwidth = 0, thetagridwidth = 0, rticklabelsize = 0, thetaticklabelsize = 0 ) for i in 1:2, j in 1:5 ]

    #@show U1

    for i in 1:2, j in 1:5
        rlims!( axes[i,j], 0.0, 20 )
        lines!( axes[i,j], TH, R0, linestyle=:dash )
    end

    lines!( axes[1,1], TH, R1 )
    lines!( axes[1,2], TH, R2 )
    lines!( axes[1,3], TH, R2bis )
    lines!( axes[1,4], TH, R3 )
    lines!( axes[1,5], TH, R4 )
    lines!( axes[2,1], TH, R5 )
    lines!( axes[2,2], TH, R6 )
    lines!( axes[2,3], TH, R7 )
    lines!( axes[2,4], TH, R7bis )
    lines!( axes[2,5], TH, R8 )

    display( fig )

    while events(axes[1,1].scene).window_open[]
        t[] += dt

        notify(t)
        sleep(dt)
    end

    return
end

main()

return