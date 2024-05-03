using LinearAlgebra
using GLMakie

#global const G = 6.674e-11

global const muTerra = 3.986E14
global const muLuna = 4.904E12
global const muMars = 4.282837e13
global const muSaturn = 3.7931187e16
#global const muEnceladus = 1.080318e20 * G

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

V_p(mu, a, e) = sqrt(mu/a) * sqrt(2/(1+e)+1)
V_m(mu, a, e) = sqrt(mu/a) * sqrt(2/(1+e)-1)

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

# TODO : Earth-Venus-Earth-Earth -> Saturn
#        Earth-Venus-Venus-Earth -> Saturn

global const Te = 1 # = 31558150 s
global const Tv = 6.15e-1
global const Tm = 1.88
global const Tj = 1.19e1
global const Ts = 2.94e1

global const Msun = 3.33e5
global const Me = 1 # = 5.972e24 kg
global const Mv = 8.15e-1
global const Mm = 1.07e-1
global const Mj = 3.178e2
global const Ms = 9.52e1

# Re = 1 = 1.5076e11 m

# G is in m^3 / kg / s^2 
global const G = 6.674e-11 * 1.5076e11^(-3) * 5.972e24 * 3.1558e7^2

global const dt = 0.001

#global const full_meet_T = 55.905

#global const m = 1e4 * 5.972e24^(-1)

function acc( pos, planets )
    R = planets .- pos
    R_norm = norm.( R )
    return Point2f( G * sum( [Msun,Mv,Me,Mm,Mj,Ms] .* R ./ (R_norm.^3) ) )
end

function RK4( pos, v, planets )
    d_phi = 2*pi ./ [Tv, Te, Tm, Tj, Ts] * dt
    d_planets = [ Point2f(0) for _ in 1:6 ]
    d_planets[2:6] += [ Point2f(cos(d_phi[i]), sin(d_phi[i])) for i in 1:5 ]

    k1x = v
    k1v = acc( pos, planets )

    k2x = v + dt * 0.5*k1v
    k2v = acc( pos + dt * 0.5*k1x, planets + 0.5*d_planets )

    k3x = v + dt * 0.5*k2v
    k3v = acc( pos + dt * 0.5*k2x, planets + 0.5*d_planets )

    k4x = v + dt * k3v
    k4v = acc( pos + dt * k3v, planets + d_planets )

    return pos + dt/6 * (k1x + 2*k2x + 2*k3x + k4x), v + dt/6 * (k1v + 2*k2v + 2*k3v + k4v)
end

function next_ship_pos( planets, ship_pos, ship_v, delta_v )
    pos, v = RK4( ship_pos, ship_v, planets )
    return pos, v + delta_v
end

frac( x ) = x - floor( x )

function plot_thing()
    fig = Figure()

    t = Observable( 10.0 )
    is_paused = false
    
    phiE = @lift( 2*pi* $t / Te - 3*pi/4 )
    phiV = @lift( 2*pi* $t / Tv + pi/5 )
    phiM = @lift( 2*pi* $t / Tm - pi/5 )
    phiJ = @lift( 2*pi* $t / Tj + pi/3 )
    phiS = @lift( 2*pi* $t / Ts - pi/5 )

    planets = @lift( [ Point2f(0.0), 
                      Point2f(0.723*cos($phiV), 0.723*sin($phiV)), 
                      Point2f(cos($phiE), sin($phiE)),
                      Point2f(1.52*cos($phiM), 1.52*sin($phiM)),
                      Point2f(5.20*cos($phiJ), 5.20*sin($phiJ)),
                      Point2f(9.57*cos($phiS), 9.57*sin($phiS)) ] )

    ship_pos = Point2f( cos(phiE[]) + 4.226e-4, sin(phiE[]) + 4.226e-4 )
    ship_v = Point2f(1, 1) + 2*pi/Te * Point2f( - sin(phiE[]), cos(phiE[]) ) #1,1 #0.9,2.2

    ship_points = Observable( [ ship_pos ] )

    ax = Axis( fig[1,1], aspect=AxisAspect(1), backgroundcolor=:black )
    limits!( ax, -10, 10, -10, 10 )

    sl = Slider( fig[2,1], range=0:dt:20 )
    txt = Label( fig[2,1], "Position at t=$(t[]) year" )
    fig[2,1] = vgrid!( txt, sl )

    colsize!(fig.layout, 1, Aspect(1, 1.0))

    scatter!( ax, planets, color=[:yellow, :orange, :blue, :darkred, :red, :orange],
                          markersize=[18, 8, 9, 5, 14, 12] )

    lines!( ax, ship_points, color=:white )

    on( sl.value ) do value
        t[] = value
    end

    on( events(ax.scene).keyboardbutton ) do event
        if event.action == Keyboard.press || event.action == Keyboard.repeat
            if event.key == Keyboard.right
                t[] += dt

                notify( t )
                notify( planets )
            elseif event.key == Keyboard.left
                t[] -= dt
                notify( t )
                notify( planets )
            end
        end

        if event.action == Keyboard.press
            if event.key == Keyboard.space
                is_paused = !is_paused
            end
        end
    end

    ship_pos, ship_v = next_ship_pos( planets[], ship_pos, ship_v, Point2f(0) )
    push!( ship_points[], ship_pos )
    notify( ship_points )

    display( fig )

    sleep( dt )

    while events(ax.scene).window_open[]
        if t[] < 20 && !is_paused
            t[] += dt

            dV = Point2f(0)
            dV = abs(t[]-10.25) < dt ? (@show ship_v; Point2f(-0.5, 0.5)) : dV
            dV = abs(t[]-12.2) < dt ? (@show ship_v; Point2f(-0.5, 1.2)) : dV
            dV = abs(t[]-13.79) < dt ? (@show ship_v; Point2f(1, -1)) : dV
            ship_pos, ship_v = next_ship_pos( planets[], ship_pos, ship_v, dV )
            push!( ship_points[], ship_pos )
            notify( ship_points )
        end

        txt.text[] = "Position at t=$(round(t[]-10.0; digits=2)) years"

        notify( t )
        notify( planets )

        if frac( 100*t[] ) * 0.01 < dt sleep(dt) end
    end
end