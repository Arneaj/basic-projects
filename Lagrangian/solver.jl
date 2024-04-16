using GLMakie

global const g = 9.81
global const l_0 = 1.0
global const k = 150.0
global const m = 10.0

function RK4( fun, t, y, step ) 
    f1 = fun( t, y )
    f2 = fun( t+step/2, y+step*f1/2 )
    f3 = fun( t+step/2, y+step*f2/2 )
    f4 = fun( t+step, y+step*f3 )

    return y + step*(f1+2*f2+2*f3+f4)/6
end

function solver( duration, step, fun, initial_condition )
    N::Int64 = round( duration/step )

    Y = zeros( Float64, length(initial_condition), N )
    Y[:, 1] = initial_condition

    T = 0:step:duration

    for i in 2:N
        Y[:, i] = RK4( fun, T[i], Y[:, i-1], step )
    end

    return Y
end

function spring_pendulum( t, y )
    new_y = [ y[2], 
              y[1]*y[4]^2 + g*cos(y[3]) - k/m*(y[1]-l_0),
              y[4],
              -y[4]*2*y[2]/y[1] - g/y[1] * sin(y[3]) ]

    return new_y
end

function main()
    Y0 = [ l_0, 0.0, pi/4, 0.0 ]

    t_max = 10.0
    dt = 0.01
    N::Int64 = round( t_max/dt )

    Y = solver( t_max, dt, spring_pendulum, Y0 )

    M = Observable( Point2(Y0[1]*sin(Y0[3]), -Y0[1]*cos(Y0[3])) )

    fig = Figure()
    ax = Axis( fig[1,1], limits=(-3, 3, -3, 3) )

    scatter!( ax, Point2(0.0) )
    scatter!( ax, M )

    display( fig )

    for i in 2:N
        M[] = Point2( Y[1, i]*sin(Y[3, i]), -Y[1, i]*cos(Y[3, i]) )
        sleep(dt)
    end
end

main()