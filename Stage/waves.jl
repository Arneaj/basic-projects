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

function main_U_as_V()
    L = 1
    X = 0:0.001:L

    TH = X*2*pi/L

    R0 = [ 10 for _ in 0:0.001:L ]

    dt = 0.03
    T = 0:dt:5

    AA = 1
    BB = 1.5
    OO = 4
    OOO = (2*2+1)*pi/L
    N = 3
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

    axes = [ PolarAxis( fig[i,j], rminorgridvisible = false, thetaminorgridvisible = false, rgridwidth = 0, thetagridwidth = 0, rticklabelsize = 0, thetaticklabelsize = 0, height = 200, width = 200 ) for i in 1:4:5, j in 1:5 ]

    Label( fig[-1, 1], L"$ f(0) = f(L) $", fontsize = 20 )
    Label( fig[0, 1], L"$ f'(0) = f'(L) $", fontsize = 20 )

    Label( fig[-1, 2:3], L"$ f(0) = f(L) $", fontsize = 20 )
    Label( fig[0, 2:3], L"$ f'(0) = -f'(L) $", fontsize = 20 )
    Label( fig[2, 2], L"$ \Omega = 4 $", fontsize = 15 )
    Label( fig[2, 3], L"$ \Omega = \frac{(2n+1) \pi}{L} $", fontsize = 15 )
    
    Label( fig[-1, 4], L"$ f(0) = f(L) $", fontsize = 20 )
    Label( fig[0, 4], L"$ f'(0) = -f'(L) + \nu $", fontsize = 20 )

    Label( fig[-1, 5], L"$ f(0) = f(L) $", fontsize = 20 )
    Label( fig[0, 5], L"$ f'(0) = \varepsilon f'(L) + \nu $", fontsize = 20 )

    Label( fig[3, 1], L"$ f(0) = \delta f(L) $", fontsize = 20 )
    Label( fig[4, 1], L"$ f'(0) = \varepsilon f'(L) $", fontsize = 20 )

    Label( fig[3, 2], L"$ f(0) = \delta f(L) $", fontsize = 20 )
    Label( fig[4, 2], L"$ f'(0) = f'(L) $", fontsize = 20 )
    
    Label( fig[3, 3:4], L"$ f(0) = - f(L) $", fontsize = 20 )
    Label( fig[4, 3:4], L"$ f'(0) = f'(L) $", fontsize = 20 )
    Label( fig[6, 3], L"$ \Omega = 4 $", fontsize = 15 )
    Label( fig[6, 4], L"$ \Omega = \frac{(2n+1) \pi}{L} $", fontsize = 15 )

    Label( fig[3, 5], L"$ f(0) = - f(L) $", fontsize = 20 )
    Label( fig[4, 5], L"$ f'(0) = - f'(L) $", fontsize = 20 )

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

    box1 = Box(fig[-1:2, 2:3], color = :white, cornerradius = 10, strokewidth = 0.5, width = 440, height = 340 )
    translate!(box1.blockscene, 0, 0, -100)

    box2 = Box(fig[3:6, 3:4], color = :white, cornerradius = 10, strokewidth = 0.5, width = 440, height = 340 )
    translate!(box2.blockscene, 0, 0, -100)

    display( fig )

    is_paused = false

    on( events(fig.scene).keyboardbutton ) do event
        if event.action == Keyboard.press
            if event.key == Keyboard.space
                is_paused = !is_paused
            end
        end
    end

    while events(fig.scene).window_open[]
        if !is_paused t[] += dt end

        notify(t)
        sleep(dt)
    end

    return
end

function main_U()
    L = 1
    X = 0:0.001:L

    TH = X*2*pi/L

    R0 = [ 10 for _ in 0:0.001:L ]

    dt = 0.03

    AA = 1
    BB = 1.5
    OO = 4 # 4, 4.4 and 4.7 are nice
    OOO = (2*2+1)*pi/L
    N = 3
    NU = 0.5
    EPS = 10
    DEL = 0.5

    t = Observable( 0.0 )

    R1 = @lift( [ 10+U(A, B, 2*pi*n/L, x)*cos(6*$t) for x in X, A in AA, B in BB, n in N ] )

    R2 = @lift( [ 10+U(A2det(A, O, L), B2det(A, B, O, L), O, x)*cos(6*$t) for x in X, A in AA, B in BB, O in OO ] )
    R2bis = @lift( [ 10+U(A2det(A, O, L), B2det(A, B, O, L), O, x)*cos(6*$t) for x in X, A in AA, B in BB, O in OOO ] )

    R3 = @lift( [ 10+U(A, nu/(2*2*pi*n/L), 2*pi*n/L, x)*cos(6*$t) for x in X, A in AA, nu in NU, n in N ] )

    R4 = @lift( [ 10+U(A, nu/((1-eps)*2*pi*n/L), 2*pi*n/L, x)*cos(6*$t) for x in X, A in AA, nu in NU, eps in EPS, n in N ] )

    R5 = @lift( [ 10+U(A, eps/del * sqrt( (1-del^2)/(eps^2-1) ) * A, acos( (del*eps+1)/(del+eps) )/L + 2*pi*n/L, x)*cos(6*$t) for x in X, A in AA, del in DEL, eps in EPS, n in N ] )

    R6 = @lift( [ 10+U(0, B, 2*pi*n/L, x)*cos(6*$t) for x in X, B in BB, del in DEL, n in N ] )

    R7 = @lift( [ 10+U(A7det(A, B, O, L), B7det(A, O, L), O, x)*cos(6*$t) for x in X, A in AA, B in BB, O in OO ] )
    R7bis = @lift( [ 10+U(A7det(A, B, O, L), B7det(A, O, L), O, x)*cos(6*$t) for x in X, A in AA, B in BB, O in OOO ] )

    R8 = @lift( [ 10+U(A8det(A, n), A8det(B, n), pi*n/L, x)*cos(6*$t) for x in X, A in AA, B in BB, n in N ] )

    #################

    fig = Figure()

    axes = [ PolarAxis( fig[i,j], rminorgridvisible = false, thetaminorgridvisible = false, rgridwidth = 0, thetagridwidth = 0, rticklabelsize = 0, thetaticklabelsize = 0, height = 200, width = 200 ) for i in 1:4:5, j in 1:5 ]

    Label( fig[-1, 1], L"$ f(0) = f(L) $", fontsize = 20 )
    Label( fig[0, 1], L"$ f'(0) = f'(L) $", fontsize = 20 )

    Label( fig[-1, 2:3], L"$ f(0) = f(L) $", fontsize = 20 )
    Label( fig[0, 2:3], L"$ f'(0) = -f'(L) $", fontsize = 20 )
    Label( fig[2, 2], L"$ \Omega = 4 $", fontsize = 15 )
    Label( fig[2, 3], L"$ \Omega = \frac{(2n+1) \pi}{L} $", fontsize = 15 )
    
    Label( fig[-1, 4], L"$ f(0) = f(L) $", fontsize = 20 )
    Label( fig[0, 4], L"$ f'(0) = -f'(L) + \nu $", fontsize = 20 )

    Label( fig[-1, 5], L"$ f(0) = f(L) $", fontsize = 20 )
    Label( fig[0, 5], L"$ f'(0) = \varepsilon f'(L) + \nu $", fontsize = 20 )

    Label( fig[3, 1], L"$ f(0) = \delta f(L) $", fontsize = 20 )
    Label( fig[4, 1], L"$ f'(0) = \varepsilon f'(L) $", fontsize = 20 )

    Label( fig[3, 2], L"$ f(0) = \delta f(L) $", fontsize = 20 )
    Label( fig[4, 2], L"$ f'(0) = f'(L) $", fontsize = 20 )
    
    Label( fig[3, 3:4], L"$ f(0) = - f(L) $", fontsize = 20 )
    Label( fig[4, 3:4], L"$ f'(0) = f'(L) $", fontsize = 20 )
    Label( fig[6, 3], L"$ \Omega = 4 $", fontsize = 15 )
    Label( fig[6, 4], L"$ \Omega = \frac{(2n+1) \pi}{L} $", fontsize = 15 )

    Label( fig[3, 5], L"$ f(0) = - f(L) $", fontsize = 20 )
    Label( fig[4, 5], L"$ f'(0) = - f'(L) $", fontsize = 20 )

    
    for i in 1:2, j in 1:5
        rlims!( axes[i,j], 0.0, 15 )
        lines!( axes[i,j], TH, R0 )
    end

    crange = minimum(R7[]), maximum(R7[])
    
    band!( axes[1,1], TH, R0, R1; color = R1, colorrange = crange )
    band!( axes[1,2], TH, R0, R2; color = R2, colorrange = crange )
    band!( axes[1,3], TH, R0, R2bis; color = R2bis, colorrange = crange )
    band!( axes[1,4], TH, R0, R3; color = R3, colorrange = crange )
    band!( axes[1,5], TH, R0, R4; color = R4, colorrange = crange )
    band!( axes[2,1], TH, R0, R5; color = R5, colorrange = crange )
    band!( axes[2,2], TH, R0, R6; color = R6, colorrange = crange )
    band!( axes[2,3], TH, R0, R7; color = R7, colorrange = crange )
    band!( axes[2,4], TH, R0, R7bis; color = R7bis, colorrange = crange )
    band!( axes[2,5], TH, R0, R8; color = R8, colorrange = crange )

    box1 = Box(fig[-1:2, 2:3], color = :white, cornerradius = 10, strokewidth = 0.5, width = 440, height = 340 )
    translate!(box1.blockscene, 0, 0, -100)

    box2 = Box(fig[3:6, 3:4], color = :white, cornerradius = 10, strokewidth = 0.5, width = 440, height = 340 )
    translate!(box2.blockscene, 0, 0, -100)

    display( fig )

    is_paused = false

    on( events(fig.scene).keyboardbutton ) do event
        if event.action == Keyboard.press
            if event.key == Keyboard.space
                is_paused = !is_paused
            end
        end
    end

    while events(fig.scene).window_open[]
        if !is_paused t[] += dt end

        notify(t)
        sleep(dt)
    end

    return
end

function V(A, B, C, D, Omega, x)
    return A * cos(Omega*x) + B * sin(Omega*x) + C * cosh(Omega*x) + D * sinh(Omega*x) 
end

function main_V()
    L = 1
    X = 0:0.001:L

    TH = X*2*pi/L

    R0 = [ 10 for _ in 0:0.001:L ]

    dt = 0.03

    AA = 1
    BB = 1.5
    OO = 4
    OOO = (2*2+1)*pi/L
    N = 3
    NU = 5
    EPS = 3

    t = Observable( 0.0 )

    R1 = @lift( [ 10 + V(A, B, 0, 0, 2*pi*n/L, x)*cos(6*$t) for x in X, A in AA, B in BB, n in N ] )

    R2 = @lift( [ 10 + V(A, nu / (2*pi*n/L)^3 / (eps - 1), 0, 0, 2*pi*n/L, x)*cos(6*$t) for x in X, A in AA, n in N, nu in NU, eps in EPS ] )

    #################

    fig = Figure()

    axes = [ PolarAxis( fig[i,j], rminorgridvisible = false, thetaminorgridvisible = false, rgridwidth = 0, thetagridwidth = 0, rticklabelsize = 0, thetaticklabelsize = 0, height = 500, width = 500 ) for i in [1], j in 1:2 ]

    Label( fig[-3, 1], L"$ f(0) = f(L) $", fontsize = 40 )
    Label( fig[-2, 1], L"$ f'(0) = f'(L) $", fontsize = 40 )
    Label( fig[-1, 1], L"$ f''(0) = f''(L) $", fontsize = 40 )
    Label( fig[0, 1], L"$ f'''(0) = f'''(L) $", fontsize = 40 )

    Label( fig[-3, 2], L"$ f(0) = f(L) $", fontsize = 40 )
    Label( fig[-2, 2], L"$ f'(0) = f'(L) $", fontsize = 40 )
    Label( fig[-1, 2], L"$ f''(0) = f''(L) $", fontsize = 40 )
    Label( fig[0, 2], L"$ f'''(0) = -f'''(L) $", fontsize = 40 )

    for i in [1], j in 1:2
        rlims!( axes[i,j], 0.0, 20 )
        lines!( axes[i,j], TH, R0, linestyle=:dash )
    end

    lines!( axes[1,1], TH, R1 )
    lines!( axes[1,2], TH, R2 )

    display( fig )

    is_paused = false

    on( events(fig.scene).keyboardbutton ) do event
        if event.action == Keyboard.press
            if event.key == Keyboard.space
                is_paused = !is_paused
            end
        end
    end

    while events(fig.scene).window_open[]
        if !is_paused t[] += dt end

        notify(t)
        sleep(dt)
    end

    return
end

main_V()

return