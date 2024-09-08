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
            if event.key == Keyboard.left
                t[] = 0
                notify(t)
            end
            if event.key == Keyboard.right
                t[] += 10
                notify(t)
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
            if event.key == Keyboard.left
                t[] = 0
                notify(t)
            end
            if event.key == Keyboard.right
                t[] += 10
                notify(t)
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

###########################################################

function main_U_complicated_physiological()

    ############## modes

    k = 1
    l = 1
    m = 1

    ############## physiological case variables

    L1 = 6.0e-3
    L2 = 11.9e-3
    L3 = 2.0e-3

    L = L1 + L2 + L3

    X1 = 0:0.001*L1:L1
    X2 = 0:0.001*L2:L2
    X3 = 0:0.001*L3:L3

    TH1 = X1*2*pi/L .- 4*pi/5
    TH2 = (X2 .+ L1)*2*pi/L .- 4*pi/5
    TH3 = (X3 .+ L2 .+ L1)*2*pi/L .- 4*pi/5

    R01 = [ 10 for _ in 0:0.001*L1:L1 ]
    R02 = [ 10 for _ in 0:0.001*L2:L2 ]
    R03 = [ 10 for _ in 0:0.001*L3:L3 ]

    t = Observable(0.0)
    dt = 0.003

    ################ physiological case constants

    B1 = 3

    eps = 2
    delta = 1/eps

    E1 = 4
    S1 = 1.2e-6
    RHO1 = 8e2

    E2 = 1.8e9 * 1e-7
    S2 = 1e-7
    RHO2 = 8e2

    E3 = 1.8e9 * 1e-8
    S3 = 9e-7
    RHO3 = 8e2

    O11 = (2*k)*pi/L1
    O21 = (2*l)*pi/L2
    O31 = (2*m)*pi/L3

    O12 = (2*k+1)*pi/L1
    O22 = (2*l+1)*pi/L2
    O32 = (2*m+1)*pi/L3

    Oc11 = O11 * sqrt(E1/RHO1)
    Oc21 = O21 * sqrt(E2/RHO2)
    Oc31 = O31 * sqrt(E3/RHO3)

    Oc12 = O12 * sqrt(E1/RHO1)
    Oc22 = O22 * sqrt(E2/RHO2)
    Oc32 = O32 * sqrt(E3/RHO3)

    #Evisc = 8e-1
    XI1 = 1e-1 #Evisc / (2*E1)

    Oa11 = Oc11 * sqrt( 1 - XI1^2 )

    Oa12 = Oc12 * sqrt( 1 - XI1^2 )

    PHI1 = 0

    ################# physiological case stress

    R11 = @lift( [ 10+U(0, B1, O11, x)*cos(Oa11*$t)*exp(-XI1*Oc11*$t) for x in X1 ] )
    R21 = @lift( [ 10+U(0, +E1*S1*O11/(E2*S2*O21) * B1, O21, x)*cos(Oc21*$t) for x in X2 ] )
    R31 = @lift( [ 10+U(0, +eps * E1*S1*O11/(E3*S3*O31) * B1, O31, x)*cos(Oc31*$t) for x in X3 ] )

    R12 = @lift( [ 10+U(0, B1, O12, x)*cos(Oa12*$t)*exp(-XI1*Oc12*$t) for x in X1 ] )
    R22 = @lift( [ 10+U(0, -E1*S1*O12/(E2*S2*O22) * B1, O22, x)*cos(Oc22*$t) for x in X2 ] )
    R32 = @lift( [ 10+U(0, +eps * E1*S1*O12/(E3*S3*O31) * B1, O31, x)*cos(Oc31*$t) for x in X3 ] )

    R13 = @lift( [ 10+U(0, B1, O11, x)*cos(Oa11*$t)*exp(-XI1*Oc11*$t) for x in X1 ] )
    R23 = @lift( [ 10+U(0, +E1*S1*O11/(E2*S2*O22) * B1, O22, x)*cos(Oc22*$t) for x in X2 ] )
    R33 = @lift( [ 10+U(0, -eps * E1*S1*O11/(E3*S3*O32) * B1, O32, x)*cos(Oc32*$t) for x in X3 ] )

    R14 = @lift( [ 10+U(0, B1, O12, x)*cos(Oa12*$t)*exp(-XI1*Oc12*$t) for x in X1 ] )
    R24 = @lift( [ 10+U(0, -E1*S1*O12/(E2*S2*O21) * B1, O21, x)*cos(Oc21*$t) for x in X2 ] )
    R34 = @lift( [ 10+U(0, -eps * E1*S1*O12/(E3*S3*O32) * B1, O32, x)*cos(Oc32*$t) for x in X3 ] )
    
    
    ################# plot set up

    fig = Figure()
    
    axes1 = PolarAxis( fig[1,1], rminorgridvisible = false, thetaminorgridvisible = false, rgridwidth = 0, thetagridwidth = 0, rticklabelsize = 0, thetaticklabelsize = 0, width = 400, height = 400 )
    axes2 = PolarAxis( fig[1,2], rminorgridvisible = false, thetaminorgridvisible = false, rgridwidth = 0, thetagridwidth = 0, rticklabelsize = 0, thetaticklabelsize = 0, width = 400, height = 400 )
    axes3 = PolarAxis( fig[2,1], rminorgridvisible = false, thetaminorgridvisible = false, rgridwidth = 0, thetagridwidth = 0, rticklabelsize = 0, thetaticklabelsize = 0, width = 400, height = 400 )
    axes4 = PolarAxis( fig[2,2], rminorgridvisible = false, thetaminorgridvisible = false, rgridwidth = 0, thetagridwidth = 0, rticklabelsize = 0, thetaticklabelsize = 0, width = 400, height = 400 )

    rlims!( axes1, 0.0, 15 )
    rlims!( axes2, 0.0, 15 )
    rlims!( axes3, 0.0, 15 )
    rlims!( axes4, 0.0, 15 )

    lines!( axes1, TH1, R01 )
    lines!( axes1, TH2, R02 )
    lines!( axes1, TH3, R03 )

    lines!( axes2, TH1, R01 )
    lines!( axes2, TH2, R02 )
    lines!( axes2, TH3, R03 )

    lines!( axes3, TH1, R01 )
    lines!( axes3, TH2, R02 )
    lines!( axes3, TH3, R03 )

    lines!( axes4, TH1, R01 )
    lines!( axes4, TH2, R02 )
    lines!( axes4, TH3, R03 )

    Label( fig[0, 1:2], L"\text{Physiological Model Case}", fontsize = 20 )

    box1 = Box(fig[1:2, 1:2], color = :white, cornerradius = 10, strokewidth = 0.5, width = 830, height = 830 )
    translate!(box1.blockscene, 0, 0, -100)

    ################## disc case plotting

    crange1 = minimum(R11[]), maximum(R11[])
    
    band!( axes1, TH1, R01, R11; color = R11, colorrange = crange1 )
    band!( axes1, TH2, R02, R21; color = R21, colorrange = crange1 )
    band!( axes1, TH3, R03, R31; color = R31, colorrange = crange1 )

    crange2 = minimum(R12[]), maximum(R12[])
    
    band!( axes2, TH1, R01, R12; color = R12, colorrange = crange2 )
    band!( axes2, TH2, R02, R22; color = R22, colorrange = crange2 )
    band!( axes2, TH3, R03, R32; color = R32, colorrange = crange2 )

    crange3 = minimum(R13[]), maximum(R13[])
    
    band!( axes3, TH1, R01, R13; color = R13, colorrange = crange3 )
    band!( axes3, TH2, R02, R23; color = R23, colorrange = crange3 )
    band!( axes3, TH3, R03, R33; color = R33, colorrange = crange3 )

    crange4 = minimum(R14[]), maximum(R14[])
    
    band!( axes4, TH1, R01, R14; color = R14, colorrange = crange4 )
    band!( axes4, TH2, R02, R24; color = R24, colorrange = crange4 )
    band!( axes4, TH3, R03, R34; color = R34, colorrange = crange4 )

    ################### during run events

    display( fig )

    is_paused = false

    on( events(fig.scene).keyboardbutton ) do event
        if event.action == Keyboard.press
            if event.key == Keyboard.space
                is_paused = !is_paused
            end
            if event.key == Keyboard.left
                t[] = 0
                notify(t)
            end
            if event.key == Keyboard.right
                t[] += 0.1
                notify(t)
            end
        end
    end

    while events(fig.scene).window_open[]
        if !is_paused t[] += dt end

        notify(t)
        sleep(10*dt)
    end

    return
end

function main_U_complicated_pathological()

    ############## modes

    k = 1
    l = 1
    m = 1
    n = 1

    ############## pathological case variables

    L1 = 6.0e-3
    L2 = 11.9e-3 * 0.5
    L4 = 11.9e-3 * 0.5
    L3 = 2.0e-3

    L = L1 + L2 + L4 + L3

    X1 = 0:0.001*L1:L1
    X2 = 0:0.001*L2:L2
    X4 = 0:0.001*L4:L4
    X3 = 0:0.001*L3:L3

    TH1 = X1*2*pi/L .- 4*pi/5
    TH2 = (X2 .+ L1)*2*pi/L .- 4*pi/5
    TH4 = (X4 .+ L1 .+ L2)*2*pi/L .- 4*pi/5
    TH3 = (X3 .+ L1 .+ L2 .+ L4)*2*pi/L .- 4*pi/5

    R01 = [ 10 for _ in 0:0.001*L1:L1 ]
    R02 = [ 10 for _ in 0:0.001*L2:L2 ]
    R04 = [ 10 for _ in 0:0.001*L4:L4 ]
    R03 = [ 10 for _ in 0:0.001*L3:L3 ]

    time_dilation = Observable(1.0)
    t = Observable(0.0)
    dt = @lift( 0.03/$time_dilation )

    ################ pathological case constants

    B1 = 3

    eps = 2
    eta = -1
    mu = -1
    #delta defined in the actual stress calculation

    E1 = 4
    S1 = 1.2e-6
    RHO1 = 8e2

    E2 = 1.8e9 * 1e-7
    S2 = 1e-7
    RHO2 = 8e2

    E4 = 1.8e9 * 1e-7
    S4 = 1e-7
    RHO4 = 8e2

    E3 = 1.8e9 * 1e-8
    S3 = 9e-7
    RHO3 = 8e2

    O11 = (2*k)*pi/L1
    O21 = (2*l)*pi/L2
    O41 = (2*n)*pi/L4
    O31 = (2*m)*pi/L3

    O12 = (2*k+1)*pi/L1
    O22 = (2*l+1)*pi/L2
    O42 = (2*n+1)*pi/L4
    O32 = (2*m+1)*pi/L3

    O13 = (2*k)*pi/L1
    O23 = (2*l+1/2)*pi/L2
    O43 = (2*n+1/2)*pi/L4
    O33 = (2*m)*pi/L3

    O14 = (2*k+1)*pi/L1
    O24 = (2*l+1+1/2)*pi/L2
    O44 = (2*n+1+1/2)*pi/L4
    O34 = (2*m+1)*pi/L3

    Oc11 = O11 * sqrt(E1/RHO1)
    Oc21 = O21 * sqrt(E2/RHO2)
    Oc41 = O41 * sqrt(E4/RHO4)
    Oc31 = O31 * sqrt(E3/RHO3)

    Oc12 = O12 * sqrt(E1/RHO1)
    Oc22 = O22 * sqrt(E2/RHO2)
    Oc42 = O42 * sqrt(E4/RHO4)
    Oc32 = O32 * sqrt(E3/RHO3)

    Oc13 = O13 * sqrt(E1/RHO1)
    Oc23 = O23 * sqrt(E2/RHO2)
    Oc43 = O43 * sqrt(E4/RHO4)
    Oc33 = O33 * sqrt(E3/RHO3)

    Oc14 = O14 * sqrt(E1/RHO1)
    Oc24 = O24 * sqrt(E2/RHO2)
    Oc44 = O44 * sqrt(E4/RHO4)
    Oc34 = O34 * sqrt(E3/RHO3)

    #Evisc = 8e-1
    XI1 = 1e-1 #Evisc / (2*E1)

    Oa11 = Oc11 * sqrt( 1 - XI1^2 )
    Oa12 = Oc12 * sqrt( 1 - XI1^2 )

    Oa13 = Oc13 * sqrt( 1 - XI1^2 )
    Oa14 = Oc14 * sqrt( 1 - XI1^2 )

    PHI1 = 0

    ################# pathological case stress

    R11 = @lift( [ 10+U(0, B1, O11, x)*cos(Oa11*$t)*exp(-XI1*Oc11*$t) for x in X1 ] )
    R21 = @lift( [ 10+U(0, +E1*S1*O11/(E2*S2*O21) * B1, O21, x)*cos(Oc21*$t) for x in X2 ] )
    R41 = @lift( [ 10+U(0, -sign(eta)/eta * E1*S1*O11/(E4*S4*O42) * B1, O42, x)*cos(Oc42*$t) for x in X4 ] )
    R31 = @lift( [ 10+U(0, +eps * E1*S1*O11/(E3*S3*O31) * B1, O31, x)*cos(Oc31*$t) for x in X3 ] )

    R12 = @lift( [ 10+U(0, B1, O12, x)*cos(Oa12*$t)*exp(-XI1*Oc12*$t) for x in X1 ] )
    R22 = @lift( [ 10+U(0, -E1*S1*O12/(E2*S2*O21) * B1, O21, x)*cos(Oc21*$t) for x in X2 ] )
    R42 = @lift( [ 10+U(0, +sign(eta)/eta * E1*S1*O12/(E4*S4*O42) * B1, O42, x)*cos(Oc42*$t) for x in X4 ] )
    R32 = @lift( [ 10+U(0, -eps * E1*S1*O12/(E3*S3*O32) * B1, O32, x)*cos(Oc32*$t) for x in X3 ] )

    ###

    R13 = @lift( [ 10+U(0, B1, O13, x)*cos(Oa13*$t)*exp(-XI1*Oc13*$t) for x in X1 ] )
    R23 = @lift( [ 10+U(0, +E1*S1*O13/(E2*S2*O24) * B1, O24, x)*cos(Oc24*$t) for x in X2 ] )
    R43 = @lift( [ 10+U(+sign(mu)/mu * E1*S1*O13/(E2*S2*O24) * B1, 0, O44, x)*cos(Oc44*$t) for x in X4 ] )
    R33 = @lift( [ 10+U(0, +eps * E1*S1*O13/(E3*S3*O33) * B1, O33, x)*cos(Oc33*$t) for x in X3 ] )

    R14 = @lift( [ 10+U(0, B1, O14, x)*cos(Oa14*$t)*exp(-XI1*Oc14*$t) for x in X1 ] )
    R24 = @lift( [ 10+U(0, -E1*S1*O14/(E2*S2*O23) * B1, O23, x)*cos(Oc23*$t) for x in X2 ] )
    R44 = @lift( [ 10+U(+sign(mu)/mu * E1*S1*O14/(E2*S2*O23) * B1, 0, O43, x)*cos(Oc43*$t) for x in X4 ] )
    R34 = @lift( [ 10+U(0, -eps * E1*S1*O14/(E3*S3*O34) * B1, O34, x)*cos(Oc34*$t) for x in X3 ] )
    
    ################# plot set up

    fig = Figure()
    
    axes1 = PolarAxis( fig[1,1], rminorgridvisible = false, thetaminorgridvisible = false, rgridwidth = 0, thetagridwidth = 0, rticklabelsize = 0, thetaticklabelsize = 0, width = 400, height = 400 )
    axes2 = PolarAxis( fig[1,2], rminorgridvisible = false, thetaminorgridvisible = false, rgridwidth = 0, thetagridwidth = 0, rticklabelsize = 0, thetaticklabelsize = 0, width = 400, height = 400 )
    axes3 = PolarAxis( fig[2,1], rminorgridvisible = false, thetaminorgridvisible = false, rgridwidth = 0, thetagridwidth = 0, rticklabelsize = 0, thetaticklabelsize = 0, width = 400, height = 400 )
    axes4 = PolarAxis( fig[2,2], rminorgridvisible = false, thetaminorgridvisible = false, rgridwidth = 0, thetagridwidth = 0, rticklabelsize = 0, thetaticklabelsize = 0, width = 400, height = 400 )

    rlims!( axes1, 0.0, 15 )
    rlims!( axes2, 0.0, 15 )
    rlims!( axes3, 0.0, 15 )
    rlims!( axes4, 0.0, 15 )

    lines!( axes1, TH1, R01 )
    lines!( axes1, TH2, R02 )
    lines!( axes1, TH3, R03 )
    lines!( axes1, TH4, R04 )

    lines!( axes2, TH1, R01 )
    lines!( axes2, TH2, R02 )
    lines!( axes2, TH3, R03 )
    lines!( axes2, TH4, R04 )

    lines!( axes3, TH1, R01 )
    lines!( axes3, TH2, R02 )
    lines!( axes3, TH3, R03 )
    lines!( axes3, TH4, R04 )

    lines!( axes4, TH1, R01 )
    lines!( axes4, TH2, R02 )
    lines!( axes4, TH3, R03 )
    lines!( axes4, TH4, R04 )

    Label( fig[0, 1:2], L"\text{Pathological Model Case}", fontsize = 20 )

    box1 = Box(fig[1:2, 1:2], color = :white, cornerradius = 10, strokewidth = 0.5, width = 830, height = 830 )
    translate!(box1.blockscene, 0, 0, -100)

    ################## pathological case plotting

    crange1 = minimum(R11[]), maximum(R11[])
    
    band!( axes1, TH1, R01, R11; color = R11, colorrange = crange1 )
    band!( axes1, TH2, R02, R21; color = R21, colorrange = crange1 )
    band!( axes1, TH3, R03, R31; color = R31, colorrange = crange1 )
    band!( axes1, TH4, R04, R41; color = R41, colorrange = crange1 )

    crange2 = minimum(R12[]), maximum(R12[])
    
    band!( axes2, TH1, R01, R12; color = R12, colorrange = crange2 )
    band!( axes2, TH2, R02, R22; color = R22, colorrange = crange2 )
    band!( axes2, TH3, R03, R32; color = R32, colorrange = crange2 )
    band!( axes2, TH4, R04, R42; color = R42, colorrange = crange2 )

    crange3 = minimum(R13[]), maximum(R13[])
    
    band!( axes3, TH1, R01, R13; color = R13, colorrange = crange3 )
    band!( axes3, TH2, R02, R23; color = R23, colorrange = crange3 )
    band!( axes3, TH3, R03, R33; color = R33, colorrange = crange3 )
    band!( axes3, TH4, R04, R43; color = R43, colorrange = crange3 )

    crange4 = minimum(R14[]), maximum(R14[])
    
    band!( axes4, TH1, R01, R14; color = R14, colorrange = crange4 )
    band!( axes4, TH2, R02, R24; color = R24, colorrange = crange4 )
    band!( axes4, TH3, R03, R34; color = R34, colorrange = crange4 )
    band!( axes4, TH4, R04, R44; color = R44, colorrange = crange4 )

    ################### run-time events

    display( fig )

    is_paused = false

    on( events(fig.scene).keyboardbutton ) do event
        if event.action == Keyboard.press
            if event.key == Keyboard.space
                is_paused = !is_paused
            end
            if event.key == Keyboard.left
                t[] = 0
                notify(t)
            end
            if event.key == Keyboard.right
                t[] += 0.1
                notify(t)
            end
            if event.key == Keyboard.down
                time_dilation[] *= 2.0
                notify(time_dilation)
            end
            if event.key == Keyboard.up
                time_dilation[] /= 2.0
                notify(time_dilation)
            end
        end
    end

    while events(fig.scene).window_open[]
        if !is_paused t[] += dt[] end

        notify(t)
        sleep(time_dilation[]*dt[])
    end

    return
end

###########################################################

function XI(x, L1)
    return 0.1*4*(x/L1)*(1-x/L1)
end

function main_U_help_physiological()

    ############## physiological case variables

    L1 = 8e-3 #7.2e-3
    L2 = 16e-3 #16.86e-3 
    L3 = 4e-3 #3.54e-3

    L = L1 + L2 + L3

    X1 = 0:0.001*L1:L1
    X2 = 0:0.001*L2:L2
    X3 = 0:0.001*L3:L3

    TH1 = X1*2*pi/L .- 4*pi/5
    TH2 = (X2 .+ L1)*2*pi/L .- 4*pi/5
    TH3 = (X3 .+ L2 .+ L1)*2*pi/L .- 4*pi/5

    R01 = [ 10 for _ in 0:0.001*L1:L1 ]
    R02 = [ 10 for _ in 0:0.001*L2:L2 ]
    R03 = [ 10 for _ in 0:0.001*L3:L3 ]

    t = Observable(0.0)
    dt = 0.001
    time_dilation = Observable(1.0)

    ################ physiological case constants

    A1 = 1
    B1 = 0.2

    eps1 = 2
    delta1 = 1/eps1

    E1 = 2e3
    S1 = 1.4e-6
    RHO1 = 1e3

    E2 = 2e3
    S2 = 1.1e-7
    RHO2 = 1e3

    E3 = 2e3
    S3 = 5.2e-7
    RHO3 = 1e3

    O(k) = k*pi/L1

    Oc(k) = O(k) * sqrt(E1/RHO1)

    #Evisc = 8e-1
    XI1 = 1e-1 #Evisc / (2*E1)

    Oa(k, x) = Oc(k) * sqrt( 1 - XI(x, L1)^2 )

    PHI1 = 0

    ################# physiological case stress

    R11 = @lift( [ 10+U(A1, B1, O(4), x)*cos(Oa(4, x)*$t)*exp(-XI(x, L1)*Oc(4)*$t) for x in X1 ] )
    #R11 = @lift( [ 10+U(A1, B1, O(4), x)*cos(Oc(4)*$t) for x in X1 ] )
    R21 = @lift( [ 10+U(A1, S1/S2 * B1, O(4), x)*cos(Oc(4)*$t) for x in X2 ] )
    R31 = @lift( [ 10+U(A1, eps1 * S1/S3 * B1, O(4), x)*cos(Oc(4)*$t) for x in X3 ] )

    B3 = -A1
    B2 = delta1 * S3/S2 * B3
    B1a = - S2/S1 * B2

    R12 = @lift( [ 10+U(A1, B1a, O(3), x)*cos(Oa(3, x)*$t)*exp(-XI(x, L1)*Oc(3)*$t) for x in X1 ] )    
    #R12 = @lift( [ 10+U(A1, B1, O(4.5), x)*cos(Oc(4.5)*$t) for x in X1 ] )
    R22 = @lift( [ 10+U(-A1, B2, O(3), x)*cos(Oc(3)*$t) for x in X2 ] )
    R32 = @lift( [ 10+U(-A1, B3, O(3), x)*cos(Oc(3)*$t) for x in X3 ] )
 
    
    ################# plot set up

    fig = Figure()
    
    axes1 = PolarAxis( fig[1,1], rminorgridvisible = false, thetaminorgridvisible = false, rgridwidth = 0, thetagridwidth = 0, rticklabelsize = 0, thetaticklabelsize = 0, width = 600, height = 600 )
    axes2 = PolarAxis( fig[1,2], rminorgridvisible = false, thetaminorgridvisible = false, rgridwidth = 0, thetagridwidth = 0, rticklabelsize = 0, thetaticklabelsize = 0, width = 600, height = 600 )

    rlims!( axes1, 0.0, 15 )
    rlims!( axes2, 0.0, 15 )

    lines!( axes1, TH1, R01 )
    lines!( axes1, TH2, R02 )
    lines!( axes1, TH3, R03 )

    lines!( axes2, TH1, R01 )
    lines!( axes2, TH2, R02 )
    lines!( axes2, TH3, R03 )

    lines!( axes1, [TH1[1], TH1[1]], [10, 15], color = :black, alpha = 0.3 )
    lines!( axes1, [TH2[1], TH2[1]], [10, 15], color = :black, alpha = 0.3 )
    lines!( axes1, [TH3[1], TH3[1]], [10, 15], color = :black, alpha = 0.3 )

    lines!( axes2, [TH1[1], TH1[1]], [10, 15], color = :black, alpha = 0.3 )
    lines!( axes2, [TH2[1], TH2[1]], [10, 15], color = :black, alpha = 0.3 )
    lines!( axes2, [TH3[1], TH3[1]], [10, 15], color = :black, alpha = 0.3 )

    Label( fig[0, 1:2], L"\text{Physiological Model Case}", fontsize = 20 )

    box1 = Box(fig[1, 1:2], color = :white, cornerradius = 10, strokewidth = 0.5, width = 1230, height = 630 )
    translate!(box1.blockscene, 0, 0, -100)

    ################## disc case plotting

    crange1 = minimum(R21[]), maximum(R21[])
    
    band!( axes1, TH1, R01, R11; color = R11, colorrange = crange1 )
    band!( axes1, TH2, R02, R21; color = R21, colorrange = crange1 )
    band!( axes1, TH3, R03, R31; color = R31, colorrange = crange1 )

    crange2 = minimum(R22[]), maximum(R22[])
    
    band!( axes2, TH1, R01, R12; color = R12, colorrange = crange2 )
    band!( axes2, TH2, R02, R22; color = R22, colorrange = crange2 )
    band!( axes2, TH3, R03, R32; color = R32, colorrange = crange2 )

    
    ################### during run events

    display( fig )

    is_paused = false

    on( events(fig.scene).keyboardbutton ) do event
        if event.action == Keyboard.press
            if event.key == Keyboard.space
                is_paused = !is_paused
            end
            if event.key == Keyboard.left
                t[] = 0
                notify(t)
            end
            if event.key == Keyboard.right
                t[] += 0.1
                notify(t)
            end
            if event.key == Keyboard.down
                time_dilation[] *= 2.0
                notify(time_dilation)
            end
            if event.key == Keyboard.up
                time_dilation[] /= 2.0
                notify(time_dilation)
            end
        end
    end

    while events(fig.scene).window_open[]
        if !is_paused t[] += dt/time_dilation[] end

        notify(t)
        sleep(time_dilation[]*dt)
    end

    return

end

function main_U_help_pathological()
    
    ############## physiological case variables

    L1 = 8e-3 #7.2e-3
    L2 = 8e-3 #16.86e-3 
    L2p = 8e-3
    L3 = 4e-3 #3.54e-3

    L = L1 + L2 + L2p + L3

    X1 = 0:0.001*L1:L1
    X2 = 0:0.001*L2:L2
    X2p = 0:0.001*L2p:L2p
    X3 = 0:0.001*L3:L3

    TH1 = X1*2*pi/L .- 4*pi/5
    TH2 = (X2 .+ L1)*2*pi/L .- 4*pi/5
    TH2p = (X2p .+ L2 .+ L1)*2*pi/L .- 4*pi/5
    TH3 = (X3 .+ L2p .+ L2 .+ L1)*2*pi/L .- 4*pi/5

    R01 = [ 10 for _ in 0:0.001*L1:L1 ]
    R02 = [ 10 for _ in 0:0.001*L2:L2 ]
    R02p = [ 10 for _ in 0:0.001*L2p:L2p ]
    R03 = [ 10 for _ in 0:0.001*L3:L3 ]

    t = Observable(0.0)
    dt = 0.001
    time_dilation = Observable(1.0)

    ################ physiological case constants

    eps1 = 2
    delta1 = 0.5
    mu1 = -1
    eta1 = mu1/(eps1*delta1)

    eps2 = 2
    delta2 = 0.5
    eta2 = -0.5
    mu2 = -1/(eps2*delta2*eta2)

    E1 = 2e3
    S1 = 1.4e-6
    RHO1 = 1e3

    E2 = 2e3
    S2 = 1.1e-7
    RHO2 = 1e3

    E2p = 2e3
    S2p = 1.1e-7
    RHO2p = 1e3

    E3 = 2e3
    S3 = 5.2e-7
    RHO3 = 1e3

    O(k) = k*pi/L1

    Oc(k) = O(k) * sqrt(E1/RHO1)

    #Evisc = 8e-1
    XI1 = 1e-1 #Evisc / (2*E1)

    Oa(k, x) = Oc(k) * sqrt( 1 - XI(x, L1)^2 )

    PHI1 = 0

    ################# physiological case stress

    A3 = 1
    B3 = 1

    A11 = -A3
    A21 = A11
    A2p1 = A21 / mu1
    B11 = -S3/S1 * B3 / eps1
    B21 = S1/S2 * B11
    B2p1 = S2/S2p * B21 / eta1

    R11 = @lift( [ 10+U(A11, B11, O(2), x)*cos(Oa(2, x)*$t)*exp(-XI(x, L1)*Oc(2)*$t) for x in X1 ] )
    #R11 = @lift( [ 10+U(A1, B1, O(4), x)*cos(Oc(4)*$t) for x in X1 ] )
    R21 = @lift( [ 10+U(A21, B21, O(2), x)*cos(Oc(2)*$t) for x in X2 ] )
    R2p1 = @lift( [ 10+U(A2p1, B2p1, O(2), x)*cos(Oc(2)*$t) for x in X2p ] )
    R31 = @lift( [ 10+U(A3, B3, O(2), x)*cos(Oc(2)*$t) for x in X3 ] )

    ###

    A12 = -B3
    A22 = -A12
    A2p2 = -A22 / mu2
    A32 = -A2p2
    B12 = S3/S1 * A32/eps2
    B22 = -S1/S2 * B12
    B2p2 = -S2/S2p * B22/eta2

    R12 = @lift( [ 10+U(A12, B12, O(3), x)*cos(Oa(3, x)*$t)*exp(-XI(x, L1)*Oc(3)*$t) for x in X1 ] )
    #R11 = @lift( [ 10+U(A1, B1, O(4), x)*cos(Oc(4)*$t) for x in X1 ] )
    R22 = @lift( [ 10+U(A22, B22, O(3), x)*cos(Oc(3)*$t) for x in X2 ] )
    R2p2 = @lift( [ 10+U(A2p2, B2p2, O(3), x)*cos(Oc(3)*$t) for x in X2p ] )
    R32 = @lift( [ 10+U(A32, B3, O(3), x)*cos(Oc(3)*$t) for x in X3 ] )
 
    
    ################# plot set up

    fig = Figure()
    
    axes1 = PolarAxis( fig[1,1], rminorgridvisible = false, thetaminorgridvisible = false, rgridwidth = 0, thetagridwidth = 0, rticklabelsize = 0, thetaticklabelsize = 0, width = 600, height = 600 )
    axes2 = PolarAxis( fig[1,2], rminorgridvisible = false, thetaminorgridvisible = false, rgridwidth = 0, thetagridwidth = 0, rticklabelsize = 0, thetaticklabelsize = 0, width = 600, height = 600 )

    rlims!( axes1, 0.0, 15 )
    rlims!( axes2, 0.0, 15 )

    lines!( axes1, TH1, R01 )
    lines!( axes1, TH2, R02 )
    lines!( axes1, TH2p, R02p )
    lines!( axes1, TH3, R03 )

    lines!( axes2, TH1, R01 )
    lines!( axes2, TH2, R02 )
    lines!( axes2, TH2p, R02p )
    lines!( axes2, TH3, R03 )

    lines!( axes1, [TH1[1], TH1[1]], [10, 15], color = :black, alpha = 0.3 )
    lines!( axes1, [TH2[1], TH2[1]], [10, 15], color = :black, alpha = 0.3 )
    lines!( axes1, [TH2p[1], TH2p[1]], [10, 15], color = :black, alpha = 0.3 )
    lines!( axes1, [TH3[1], TH3[1]], [10, 15], color = :black, alpha = 0.3 )

    lines!( axes2, [TH1[1], TH1[1]], [10, 15], color = :black, alpha = 0.3 )
    lines!( axes2, [TH2[1], TH2[1]], [10, 15], color = :black, alpha = 0.3 )
    lines!( axes2, [TH2p[1], TH2p[1]], [10, 15], color = :black, alpha = 0.3 )
    lines!( axes2, [TH3[1], TH3[1]], [10, 15], color = :black, alpha = 0.3 )

    Label( fig[0, 1:2], L"\text{Pathological Model Case}", fontsize = 20 )

    box1 = Box(fig[1, 1:2], color = :white, cornerradius = 10, strokewidth = 0.5, width = 1230, height = 630 )
    
    translate!(box1.blockscene, 0, 0, -100)

    ################## disc case plotting

    crange1 = minimum(R21[]), maximum(R21[])
    
    band!( axes1, TH1, R01, R11; color = R11, colorrange = crange1 )
    band!( axes1, TH2, R02, R21; color = R21, colorrange = crange1 )
    band!( axes1, TH2p, R02p, R2p1; color = R2p1, colorrange = crange1 )
    band!( axes1, TH3, R03, R31; color = R31, colorrange = crange1 )

    crange2 = minimum(R22[]), maximum(R22[])
    
    band!( axes2, TH1, R01, R12; color = R12, colorrange = crange2 )
    band!( axes2, TH2, R02, R22; color = R22, colorrange = crange2 )
    band!( axes2, TH2p, R02p, R2p2; color = R2p2, colorrange = crange2 )
    band!( axes2, TH3, R03, R32; color = R32, colorrange = crange2 )

    ################### during run events

    display( fig )

    is_paused = false

    on( events(fig.scene).keyboardbutton ) do event
        if event.action == Keyboard.press
            if event.key == Keyboard.space
                is_paused = !is_paused
            end
            if event.key == Keyboard.left
                t[] = 0
                notify(t)
            end
            if event.key == Keyboard.right
                t[] += 0.1
                notify(t)
            end
            if event.key == Keyboard.down
                time_dilation[] *= 2.0
                notify(time_dilation)
            end
            if event.key == Keyboard.up
                time_dilation[] /= 2.0
                notify(time_dilation)
            end
        end
    end

    while events(fig.scene).window_open[]
        if !is_paused t[] += dt/time_dilation[] end

        notify(t)
        sleep(time_dilation[]*dt)
    end

    return
end

main_U_help_physiological()

return

