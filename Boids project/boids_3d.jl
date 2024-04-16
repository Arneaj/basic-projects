module Boids3d

using FileIO, MeshIO
using .Threads
using GeometryBasics
using GLMakie, ImageCore, Colors

println("done importing packages")

global const dim::Int64 = 256*2

function R3_x( phi )
    return [ 1 0 0;
             0 cos(phi) -sin(phi);
             0 sin(phi) cos(phi) ]
end

function R3_y( theta )
    return [ cos(theta) 0 -sin(theta);
                      0 1 0;
             sin(theta) 0 cos(theta) ]
end

function R3_z( psi )
    return [ cos(psi) -sin(psi) 0;
             sin(psi) cos(psi)  0;
                            0 0 1 ]
end

function move( boid_number, x_array, y_array, z_array, dxdt_array, dydt_array, dzdt_array, dt )
    for i in 1:boid_number
        x_array[i] += dxdt_array[i]*dt
        if x_array[i] < 0 x_array[i] += dim end
        if x_array[i] > dim x_array[i] -= dim end

        y_array[i] += dydt_array[i]*dt
        if y_array[i] < 0 y_array[i] += dim end
        if y_array[i] > dim y_array[i] -= dim end

        z_array[i] += dzdt_array[i]*dt
        if z_array[i] < 0 z_array[i] += dim end
        if z_array[i] > dim z_array[i] -= dim end
    end

    return x_array, y_array, z_array
end

function stay_in_bounds( boid_number, x_array, y_array, z_array, dxdt_array, dydt_array, dzdt_array, dt, repulsion_force, rov )
    turning = false

    for i in 1:boid_number
        if x_array[i] < rov #&& dxdt_array[i] < 0
            angle_sign_y = -sign(dydt_array[i])
            angle_sign_y = angle_sign_y == 0 ? 1 : angle_sign_y

            angle_sign_z = -sign(dzdt_array[i])
            angle_sign_z = angle_sign_z == 0 ? 1 : angle_sign_z

            dxdt_array[i], dydt_array[i], dzdt_array[i] = R3_y( angle_sign_y*repulsion_force*dt ) * R3_z( angle_sign_z*repulsion_force*dt ) * [dxdt_array[i], dydt_array[i], dzdt_array[i]]
            turning = true
        elseif dim - x_array[i] < rov #&& dxdt_array[i] > 0
            angle_sign_y = sign(dydt_array[i])
            angle_sign_y = angle_sign_y == 0 ? 1 : angle_sign_y

            angle_sign_z = sign(dzdt_array[i])
            angle_sign_z = angle_sign_z == 0 ? 1 : angle_sign_z

            dxdt_array[i], dydt_array[i], dzdt_array[i] = R3_y( angle_sign_y*repulsion_force*dt ) * R3_z( angle_sign_z*repulsion_force*dt ) * [dxdt_array[i], dydt_array[i], dzdt_array[i]]
            turning = true
        end

        if y_array[i] < rov && !turning #&& dydt_array[i] < 0
            angle_sign_x = sign(dxdt_array[i])
            angle_sign_x = angle_sign_x == 0 ? 1 : angle_sign_x

            angle_sign_z = sign(dzdt_array[i])
            angle_sign_z = angle_sign_z == 0 ? 1 : angle_sign_z

            dxdt_array[i], dydt_array[i], dzdt_array[i] = R3_x( angle_sign_x*repulsion_force*dt ) * R3_z( angle_sign_z*repulsion_force*dt ) * [dxdt_array[i], dydt_array[i], dzdt_array[i]]
            turning = true
        elseif dim - y_array[i] < rov && !turning #&& dydt_array[i] > 0
            angle_sign_x = -sign(dxdt_array[i])
            angle_sign_x = angle_sign_x == 0 ? 1 : angle_sign_x

            angle_sign_z = -sign(dzdt_array[i])
            angle_sign_z = angle_sign_z == 0 ? 1 : angle_sign_z

            dxdt_array[i], dydt_array[i], dzdt_array[i] = R3_x( angle_sign_x*repulsion_force*dt ) * R3_z( angle_sign_z*repulsion_force*dt ) * [dxdt_array[i], dydt_array[i], dzdt_array[i]]
            turning = true
        end

        if z_array[i] < rov && !turning #&& dydt_array[i] < 0
            angle_sign_x = -sign(dxdt_array[i])
            angle_sign_x = angle_sign_x == 0 ? 1 : angle_sign_x

            angle_sign_y = -sign(dydt_array[i])
            angle_sign_y = angle_sign_y == 0 ? 1 : angle_sign_y

            dxdt_array[i], dydt_array[i], dzdt_array[i] = R3_x( angle_sign_x*repulsion_force*dt ) * R3_y( angle_sign_y*repulsion_force*dt ) * [dxdt_array[i], dydt_array[i], dzdt_array[i]]
        elseif dim - z_array[i] < rov && !turning #&& dydt_array[i] > 0
            angle_sign_x = -sign(dxdt_array[i])
            angle_sign_x = angle_sign_x == 0 ? 1 : angle_sign_x

            angle_sign_y = -sign(dydt_array[i])
            angle_sign_y = angle_sign_y == 0 ? 1 : angle_sign_y

            dxdt_array[i], dydt_array[i], dzdt_array[i] = R3_x( angle_sign_x*repulsion_force*dt ) * R3_y( angle_sign_y*repulsion_force*dt ) * [dxdt_array[i], dydt_array[i], dzdt_array[i]]
        end
    end

    return dxdt_array, dydt_array, dzdt_array
end

function vector_1_2( boid_1_x, boid_1_y, boid_1_z, boid_2_x, boid_2_y, boid_2_z )
    return [ boid_2_x-boid_1_x, boid_2_y-boid_1_y, boid_2_z-boid_1_z ]
end

function sign_of_angle(a, b)
    return sign( a[1]*b[2] - b[1]*a[2] )
end

function angle(a, b)
    return acos(clamp(a⋅b/(norm(a)*norm(b)), -1, 1))
end

function proj_x_y(vect)
    return [ vect[1], vect[2] ]
end

function proj_y_z(vect)
    return [ vect[2], vect[3] ]
end

function proj_z_x(vect)
    return [ vect[3], vect[1] ]
end

function boid_interaction( boid_number, x_array, y_array, z_array, dxdt_array, dydt_array, dzdt_array, dt, repulsion_force, fov, rov, roa, attraction_force, direction_force )

    for i in 1:boid_number
        center_of_attraction = [0,0,0]
        group_direction = [0,0,0]
        nb_of_attracting_boids = 0

        for j in 1:boid_number
            if i==j continue end

            boid_vector = vector_1_2( x_array[i], y_array[i], z_array[i], x_array[j], y_array[j], z_array[j] )
            boid_vector_norm = norm( boid_vector )

            vector_angle_x = angle( [dydt_array[i], dzdt_array[i]], proj_y_z(boid_vector) )
            vector_angle_y = angle( [dzdt_array[i], dxdt_array[i]], proj_z_x(boid_vector) )
            vector_angle_z = angle( [dxdt_array[i], dydt_array[i]], proj_x_y(boid_vector) )

            if boid_vector_norm < rov #&& abs( vector_angle ) < fov
                angle_sign_x = sign_of_angle( [dydt_array[i], dzdt_array[i]], proj_y_z(boid_vector) )
                angle_sign_x = angle_sign_x == 0 ? 1 : angle_sign_x
                angle_sign_y = sign_of_angle( [dzdt_array[i], dxdt_array[i]], proj_z_x(boid_vector) )
                angle_sign_y = angle_sign_y == 0 ? 1 : angle_sign_y
                angle_sign_z = sign_of_angle( [dxdt_array[i], dydt_array[i]], proj_x_y(boid_vector) )
                angle_sign_z = angle_sign_z == 0 ? 1 : angle_sign_z

                dxdt_array[i], dydt_array[i], dzdt_array[i] = R3_x( -angle_sign_x*repulsion_force*dt ) * R3_y( -angle_sign_y*repulsion_force*dt ) * R3_z( -angle_sign_z*repulsion_force*dt ) * [dxdt_array[i], dydt_array[i], dzdt_array[i]]
            end

            if boid_vector_norm < roa #&& abs( vector_angle ) < fov
                center_of_attraction += [ x_array[j], y_array[j], z_array[j] ]

                group_direction += [ dxdt_array[j], dydt_array[j], dzdt_array[j] ]

                nb_of_attracting_boids += 1
            end
        end

        if nb_of_attracting_boids != 0 
            # attraction by center of group
            center_of_attraction /= nb_of_attracting_boids

            attraction_vector = vector_1_2( x_array[i], y_array[i], z_array[i], center_of_attraction[1], center_of_attraction[2], center_of_attraction[3] )

            vector_angle_x = angle( [dydt_array[i], dzdt_array[i]], proj_y_z(attraction_vector) )
            angle_sign_x = sign_of_angle( [dydt_array[i], dzdt_array[i]], proj_y_z(attraction_vector) )
            angle_sign_x = angle_sign_x == 0 ? 1 : angle_sign_x

            vector_angle_y = angle( [dzdt_array[i], dxdt_array[i]], proj_z_x(attraction_vector) )
            angle_sign_y = sign_of_angle( [dzdt_array[i], dxdt_array[i]], proj_z_x(attraction_vector) )
            angle_sign_y = angle_sign_y == 0 ? 1 : angle_sign_y

            vector_angle_z = angle( [dxdt_array[i], dydt_array[i]], proj_x_y(attraction_vector) )
            angle_sign_z = sign_of_angle( [dxdt_array[i], dydt_array[i]], proj_x_y(attraction_vector) )
            angle_sign_z = angle_sign_z == 0 ? 1 : angle_sign_z

            dxdt_array[i], dydt_array[i], dzdt_array[i] = R3_x( angle_sign_x*attraction_force*dt ) * R3_y( angle_sign_y*attraction_force*dt ) * R3_z( angle_sign_z*attraction_force*dt ) * [dxdt_array[i], dydt_array[i], dzdt_array[i]]

            # try to follow group general_direction
            group_direction /= nb_of_attracting_boids 

            vector_angle_x = angle( [dydt_array[i], dzdt_array[i]], proj_y_z(group_direction) )
            angle_sign_x = sign_of_angle( [dydt_array[i], dzdt_array[i]], proj_y_z(group_direction) )
            angle_sign_x = angle_sign_x == 0 ? 1 : angle_sign_x

            vector_angle_y = angle( [dzdt_array[i], dxdt_array[i]], proj_z_x(group_direction) )
            angle_sign_y = sign_of_angle( [dzdt_array[i], dxdt_array[i]], proj_z_x(group_direction) )
            angle_sign_y = angle_sign_y == 0 ? 1 : angle_sign_y

            vector_angle_z = angle( [dxdt_array[i], dydt_array[i]], proj_x_y(group_direction) )
            angle_sign_z = sign_of_angle( [dxdt_array[i], dydt_array[i]], proj_x_y(group_direction) )
            angle_sign_z = angle_sign_z == 0 ? 1 : angle_sign_z

            dxdt_array[i], dydt_array[i], dzdt_array[i] = R3_x( angle_sign_x*direction_force*dt ) * R3_y( angle_sign_y*direction_force*dt ) * R3_z( angle_sign_z*direction_force*dt ) * [dxdt_array[i], dydt_array[i], dzdt_array[i]]
        end
    end

    return dxdt_array, dydt_array, dzdt_array
end

function basic_boids( boid_number=200, tmax=120., dt=0.01, repulsion_force_bounds=0, repulsion_force_boids=pi, fov=3*pi/5, rov=dim/20, roa=dim/10, attraction_force=pi/2, direction_force=pi/2 )

    ## Initialisation
    set_theme!(backgroundcolor = :grey8)
    fig = Figure()
    ax = Axis3( fig[1,1], aspect = (1, 1, 1), limits=( 0,dim, 0,dim, 0,dim ) )
    hidedecorations!( ax )

    x_array = Observable( [ rand()*dim for _ in 1:boid_number ] )
    y_array = Observable( [ rand()*dim for _ in 1:boid_number ] )
    z_array = Observable( [ rand()*dim for _ in 1:boid_number ] )
    dxdt_array = Observable( [ (rand()-0.5) for _ in 1:boid_number ] )
    dydt_array = Observable( [ (rand()-0.5) for _ in 1:boid_number ] )
    dzdt_array = Observable( [ (rand()-0.5) for _ in 1:boid_number ] )

    for i in 1:boid_number
        norm_i = sqrt( dxdt_array[][i]^2 + dydt_array[][i]^2 + dzdt_array[][i]^2 )
        dxdt_array[][i] *= dim/4/norm_i
        dydt_array[][i] *= dim/4/norm_i
        dzdt_array[][i] *= dim/4/norm_i
    end

    ## 3d plot
    #fish = load( "fish.stl" )

    """mesh(
        fish,
        color = [tri[1][2] for tri in fish for i in 1:3],
        colormap = Reverse(:Spectral)
    )"""

    arrows!( ax, x_array, y_array, z_array,
                 dxdt_array, dydt_array, dzdt_array,
                 #arrowhead=fish,
                 arrowcolor = x_array, linecolor=x_array, colormap=:Pastel1_9,
                 arrowsize = 10, lengthscale = 0 )

    ## Menu
    current_repulsion_force_bounds = repulsion_force_bounds
    current_repulsion_force_boids = repulsion_force_boids
    current_attraction_force = attraction_force
    current_direction_force = direction_force
    current_rov = rov
    current_roa = roa
    
    sl_repul_bounds = Slider( fig, range = 0:0.001:2*pi, startvalue = repulsion_force_bounds )
    sl_repul_boids = Slider( fig, range = 0:0.001:2*pi, startvalue = repulsion_force_boids )
    sl_attrac = Slider( fig, range = 0:0.001:2*pi, startvalue = attraction_force )
    sl_direc = Slider( fig, range = 0:0.001:2*pi, startvalue = direction_force )
    sl_rov = Slider( fig, range = 0:0.001:dim/5, startvalue = rov )
    sl_roa = Slider( fig, range = 0:0.001:dim/2.5, startvalue = roa )

    fig[1,2] = vgrid!( Label(fig, "Repulsion force bounds : ", width = nothing, color = :lavender), sl_repul_bounds,
                       Label(fig, "Repulsion force boids : ", width = nothing, color = :lavender), sl_repul_boids,
                       Label(fig, "Attraction force : ", width = nothing, color = :lavender), sl_attrac,
                       Label(fig, "Direction force : ", width = nothing, color = :lavender), sl_direc,
                       Label(fig, "Range of vision : ", width = nothing, color = :lavender), sl_rov,
                       Label(fig, "Range of attraction : ", width = nothing, color = :lavender), sl_roa,
                       tellheight = false, width = 150 )

    on(sl_repul_bounds.value) do repul_bounds
        current_repulsion_force_bounds = repul_bounds
    end
    on(sl_repul_boids.value) do repul_boids
        current_repulsion_force_boids = repul_boids
    end
    on(sl_attrac.value) do attrac
        current_attraction_force = attrac
    end
    on(sl_direc.value) do direc
        current_direction_force = direc
    end
    on(sl_rov.value) do rovv
        current_rov = rovv
    end
    on(sl_roa.value) do roaa
        current_roa = roaa
    end
    
    ## Display
    display( fig )

    ## Main loop
    t0 = time()
    while time()-t0 < tmax

        dxdt_array[], dydt_array[], dzdt_array[] = stay_in_bounds( boid_number, x_array[], y_array[], z_array[], dxdt_array[], dydt_array[], dzdt_array[], dt, current_repulsion_force_bounds[], current_rov[] )

        dxdt_array[], dydt_array[], dzdt_array[] = boid_interaction( boid_number, x_array[], y_array[], z_array[], dxdt_array[], dydt_array[], dzdt_array[], dt, current_repulsion_force_boids[], fov, current_rov[], current_roa[], current_attraction_force[], current_direction_force[] )

        x_array[], y_array[], z_array[] = move( boid_number, x_array[], y_array[], z_array[], dxdt_array[], dydt_array[], dzdt_array[], dt )

        sleep(dt)
    end
    
end







end # module