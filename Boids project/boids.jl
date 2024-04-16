module Boids

using .Threads
using GLMakie, ImageCore, Colors

println("done importing packages")

global const dim::Int64 = 256

function R2( theta )
    return [ cos(theta) -sin(theta);
             sin(theta) cos(theta) ]
end

@kwdef mutable struct Boid
    x::Float64 = rand() * dim
    y::Float64 = rand() * dim

    dxdt::Float64 = rand() - 0.5
    dydt::Float64 = rand() - 0.5

    speed::Float64 = sqrt(dxdt^2 + dydt^2)

    n = [dxdt, dydt] / speed
    """
    n_left = @map &n * R2(pi/6)
    n_right = @map &n * R2(-pi/6)
    """
end

function move_boid( boids_array::Vector{Boid}, dt=0.01 )
    for boid in boids_array
        boid.x += boid.dxdt * dt
        boid.y += boid.dydt * dt
    end

    return boids_array
end

function move( boid_number, x_array, y_array, dxdt_array, dydt_array, dt )
    for i in 1:boid_number
        x_array[i] += dxdt_array[i]*dt
        if x_array[i] < 0 x_array[i] += dim end
        if x_array[i] > dim x_array[i] -= dim end

        y_array[i] += dydt_array[i]*dt
        if y_array[i] < 0 y_array[i] += dim end
        if y_array[i] > dim y_array[i] -= dim end
    end

    return x_array, y_array
end

function stay_in_bounds( boid_number, x_array, y_array, dxdt_array, dydt_array, dt, repulsion_force, rov )
    turning = false

    for i in 1:boid_number
        if x_array[i] < rov #&& dxdt_array[i] < 0
            angle_sign = -sign(dydt_array[i])
            angle_sign = angle_sign == 0 ? 1 : angle_sign

            dxdt_array[i], dydt_array[i] = R2( angle_sign*repulsion_force*dt ) * [dxdt_array[i], dydt_array[i]]
            turning = true
        elseif dim - x_array[i] < rov #&& dxdt_array[i] > 0
            angle_sign = sign(dydt_array[i])
            angle_sign = angle_sign == 0 ? 1 : angle_sign

            dxdt_array[i], dydt_array[i] = R2( angle_sign*repulsion_force*dt ) * [dxdt_array[i], dydt_array[i]]
            turning = true
        end

        if y_array[i] < rov && !turning #&& dydt_array[i] < 0
            angle_sign = sign(dxdt_array[i])
            angle_sign = angle_sign == 0 ? 1 : angle_sign

            dxdt_array[i], dydt_array[i] = R2( angle_sign*repulsion_force*dt ) * [dxdt_array[i], dydt_array[i]]
        elseif dim - y_array[i] < rov && !turning #&& dydt_array[i] > 0
            angle_sign = -sign(dxdt_array[i])
            angle_sign = angle_sign == 0 ? 1 : angle_sign

            dxdt_array[i], dydt_array[i] = R2( angle_sign*repulsion_force*dt ) * [dxdt_array[i], dydt_array[i]]
        end
    end

    return dxdt_array, dydt_array
end

function vector_1_2( boid_1_x, boid_1_y, boid_2_x, boid_2_y )
    return [ boid_2_x-boid_1_x, boid_2_y-boid_1_y ]
end

function sign_of_angle(a, b)
    return sign( a[1]*b[2] - b[1]*a[2] )
end

function angle(a, b)
    return acos(clamp(a⋅b/(norm(a)*norm(b)), -1, 1))
end

function boid_interaction( boid_number, x_array, y_array, dxdt_array, dydt_array, dt, repulsion_force, fov, rov, roa, attraction_force, direction_force )

    for i in 1:boid_number
        center_of_attraction = [0,0]
        group_direction = [0,0]
        nb_of_attracting_boids = 0

        for j in 1:boid_number
            if i==j continue end

            boid_vector = vector_1_2( x_array[i], y_array[i], x_array[j], y_array[j] )
            boid_vector_norm = norm( boid_vector )
            vector_angle = angle( [dxdt_array[i], dydt_array[i]], boid_vector )

            if boid_vector_norm < rov && abs( vector_angle ) < fov
                angle_sign = sign_of_angle( [dxdt_array[i], dydt_array[i]], boid_vector )
                angle_sign = angle_sign == 0 ? 1 : angle_sign

                dxdt_array[i], dydt_array[i] = R2( -angle_sign*repulsion_force*dt ) * [dxdt_array[i], dydt_array[i]]
            end

            if boid_vector_norm < roa && abs( vector_angle ) < fov
                center_of_attraction += [ x_array[j], y_array[j] ]

                group_direction += [ dxdt_array[j], dydt_array[j] ]

                nb_of_attracting_boids += 1
            end
        end

        if nb_of_attracting_boids != 0 
            # attraction by center of group
            center_of_attraction /= nb_of_attracting_boids

            attraction_vector = vector_1_2( x_array[i], y_array[i], center_of_attraction[1], center_of_attraction[2] )

            vector_angle = angle( [dxdt_array[i], dydt_array[i]], attraction_vector )
            angle_sign = sign_of_angle( [dxdt_array[i], dydt_array[i]], attraction_vector )
            angle_sign = angle_sign == 0 ? 1 : angle_sign

            dxdt_array[i], dydt_array[i] = R2( angle_sign*attraction_force*dt ) * [dxdt_array[i], dydt_array[i]]

            # try to follow group general_direction
            group_direction /= nb_of_attracting_boids 

            vector_angle = angle( [dxdt_array[i], dydt_array[i]], group_direction )
            angle_sign = sign_of_angle( [dxdt_array[i], dydt_array[i]], group_direction )
            angle_sign = angle_sign == 0 ? 1 : angle_sign

            dxdt_array[i], dydt_array[i] = R2( angle_sign*direction_force*dt ) * [dxdt_array[i], dydt_array[i]]
        end
    end

    return dxdt_array, dydt_array
end

function basic_boids( boid_number=200, tmax=120., dt=0.01, repulsion_force_bounds=0, repulsion_force_boids=pi, fov=3*pi/5, rov=dim/20, roa=dim/10, attraction_force=pi/2, direction_force=pi/2 )

    fig = Figure()
    ax = Axis( fig[1,1], backgroundcolor="grey8", limits=( 0,dim, 0,dim ) )
    hidedecorations!( ax )

    x_array = Observable( [ rand()*dim for _ in 1:boid_number ] )
    y_array = Observable( [ rand()*dim for _ in 1:boid_number ] )
    dxdt_array = Observable( [ (rand()-0.5) for _ in 1:boid_number ] )
    dydt_array = Observable( [ (rand()-0.5) for _ in 1:boid_number ] )

    for i in 1:boid_number
        norm_i = sqrt( dxdt_array[][i]^2 + dydt_array[][i]^2 )
        dxdt_array[][i] *= 70/norm_i
        dydt_array[][i] *= 70/norm_i
    end

    arrows!( ax, x_array, y_array,
                 dxdt_array, dydt_array,
                 arrowcolor = x_array, linecolor=y_array, colormap=:Pastel1_9,
                 arrowsize = 10, lengthscale = 0.08 )

    display( fig )

    t0 = time()
    while time()-t0 < tmax

        dxdt_array[], dydt_array[] = stay_in_bounds( boid_number, x_array[], y_array[], dxdt_array[], dydt_array[], dt, repulsion_force_bounds, rov )

        dxdt_array[], dydt_array[] = boid_interaction( boid_number, x_array[], y_array[], dxdt_array[], dydt_array[], dt, repulsion_force_boids, fov, rov, roa, attraction_force, direction_force )

        x_array[], y_array[] = move( boid_number, x_array[], y_array[], dxdt_array[], dydt_array[], dt )

        sleep(dt)
    end
    
end







end # module