using GLMakie, ImageCore, Colors
using .Threads

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

mutable struct Star 
    pos::Point3

    nu::Float64
    radius::Float64

    branch_id::Int64
end

mutable struct Branch
    nb_stars::Int64

    a::Float64
    e::Float64
    i::Float64
    omega::Float64
    Omega::Float64

    focal_point::Point3

    stars::Vector{Star}
    clouds::Vector{Point3}
end

mutable struct Galaxy
    nb_branches::Int64
    center::Point3

    branches::Vector{Branch}

    positions::Observable{Vector{Point3}}
    cloud_positions::Observable{Vector{Point3}}
end

offset(omega) = 0.038*log(omega) + 0.2576

decay(d, k=1, l=1) = k*exp(-l*d)

velocity( distance_to_focal::Float64, a::Float64, mu::Float64 ) = sqrt( mu*(2.0/distance_to_focal - 1.0/a) )

distance( point_a::Point3, point_b::Point3 ) = norm( point_b - point_a )

function create_galaxy( nb_stars_per_branch, center::Point3, radius, e, i, Omega, d_omega )::Galaxy
    branches::Vector{Branch} = []

    initial_omega::Float64 = d_omega
    stars::Vector{Star} = []

    current_a::Float64 = radius/(1-e)
    current_b::Float64 = current_a*sqrt(1-e^2)

    scale_factor = sqrt( 1-e^2 ) / sqrt( 1 - (e*cos(d_omega + offset(d_omega)))^2 )
    desired_inner_radius = 0.15
    power_required = log(desired_inner_radius / radius) / log(scale_factor)

    nb_branches::Int64 = round( power_required )

    focal_point = [ current_a*e*cos(initial_omega), current_a*e*sin(initial_omega), 0 ]

    positions::Vector{Point3} = []
    cloud_positions::Vector{Point3} = []

    for s in 1:nb_stars_per_branch
        nu::Float64 = 2.0*pi*s/nb_stars_per_branch
        radius::Float64 = current_b / sqrt(1 - (e*cos(nu))^2)

        pos = Point3( radius*cos(nu), radius*sin(nu), 0 )
        pos = R3_z( initial_omega ) * pos
        #pos += focal_point

        white_offset = randn(3)
        white_offset[1] *= 0.2
        white_offset[2] *= 0.2
        white_offset[3] *= decay( norm(pos), 0.1, 0.5 )

        new_pos = pos + white_offset

        push!( positions, new_pos )

        new_star = Star( pos, nu, radius, 1 )
        push!( stars, new_star )
    end 

    local_cloud_pos::Vector{Point3} = []
    for c in 1:2
        nu::Float64 = pi*c
        radius = current_b / sqrt(1 - (e*cos(nu))^2)

        pos = Point3( radius*cos(nu), radius*sin(nu), 0 )
        pos = R3_z( initial_omega ) * pos

        white_offset = randn(3)
        white_offset[1] *= 0.2
        white_offset[2] *= 0.2
        white_offset[3] *= decay( norm(pos), 0.1, 0.5 )

        new_pos = pos + white_offset

        push!( local_cloud_pos, pos )
        push!( cloud_positions, new_pos )
    end

    branch = Branch( nb_stars_per_branch, current_a, e, i, initial_omega, Omega, focal_point, stars, local_cloud_pos )
    push!( branches, branch )

    current_offset = offset(initial_omega)

    for b in 2:nb_branches
        omega = b*d_omega
        stars = []

        previous_a = branches[b-1].a
        previous_b = previous_a * sqrt( 1-e^2 )

        current_a = previous_b / sqrt( 1 - (e*cos(initial_omega + current_offset))^2 )
        current_b = current_a * sqrt( 1-e^2 )

        focal_point = [ current_a*e*cos(omega), current_a*e*sin(omega), 0 ]

        for s in 1:nb_stars_per_branch
            nu = 2.0*pi*s/nb_stars_per_branch
            radius = current_b / sqrt( 1 - (e*cos(nu))^2 )

            pos = Point3( radius*cos(nu), radius*sin(nu), 0 )
            pos = R3_z( omega ) * pos
            #pos += focal_point

            white_offset = randn(3)
            white_offset[1] *= 0.2
            white_offset[2] *= 0.2
            white_offset[3] *= decay( norm(pos), 0.1, 0.5 )

            new_pos = pos + white_offset

            push!( positions, new_pos )

            new_star = Star( pos, nu, radius, b )
            push!( stars, new_star )
        end 

        local_cloud_pos = []
        for c in 1:2
            nu::Float64 = pi*c
            radius = current_b / sqrt(1 - (e*cos(nu))^2)

            pos = Point3( radius*cos(nu), radius*sin(nu), 0 )
            pos = R3_z( omega ) * pos

            white_offset = randn(3)
            white_offset[1] *= 0.2
            white_offset[2] *= 0.2
            white_offset[3] *= decay( norm(pos), 0.1, 0.5 )

            new_pos = pos + white_offset

            push!( local_cloud_pos, pos )
            push!( cloud_positions, new_pos )
        end

        branch = Branch( nb_stars_per_branch, current_a, e, i, omega, Omega, focal_point, stars, local_cloud_pos )
        push!( branches, branch )
    end

    obs_positions = Observable( positions )
    obs_cloud_positions = Observable( cloud_positions )

    galaxy = Galaxy( nb_branches, center, branches, obs_positions, obs_cloud_positions )

    return galaxy
end

function update_positions( nb_stars_per_branch::Int64, galaxy::Galaxy, center::Point3, dt, mu )

    for b in 1:galaxy.nb_branches
        current_branch = galaxy.branches[b]
        current_a = current_branch.a
        current_e = current_branch.e
        current_omega = current_branch.omega
        current_b = current_a * sqrt( 1 - current_e^2 )

        current_rot_mat = R3_z( current_omega )

        current_n = sqrt( mu / (current_a^3) )

        for s in 1:nb_stars_per_branch
            current_star = current_branch.stars[s]
            current_nu = current_star.nu
            current_r = current_star.radius

            d_nu = current_n*dt #/ (1 - current_e*cos(current_nu))
            new_nu = current_nu + d_nu
            if ( new_nu > 2.0*pi ) new_nu -= 2.0*pi end

            cos_nu = cos(new_nu)

            new_r = current_b / sqrt( 1 - (current_e*cos_nu)^2 )

            new_pos = Point3( new_r*cos_nu, new_r*sin(new_nu), 0 )
            new_pos = current_rot_mat * new_pos

            white_offset = galaxy.positions[][s + (b-1)*nb_stars_per_branch] - current_star.pos

            new_new_pos = new_pos + white_offset

            galaxy.branches[b].stars[s].nu = new_nu
            galaxy.branches[b].stars[s].radius = new_r
            galaxy.branches[b].stars[s].pos = new_pos

            galaxy.positions[][s + (b-1)*nb_stars_per_branch] = new_new_pos
        end
    end
end

function main()

    d_omega = pi/72
    e = 0.65
    radius = 2.0
    nb_stars_per_branch::Int64 = 500

    center = Point3(0.0, 0.0, 0.0)

    galaxy = create_galaxy( nb_stars_per_branch, center, radius, e, 0.0, 0.0, d_omega )

    set_theme!( theme_black() )
    fig = Figure( size = (1200, 800) )
    
    ax = LScene( fig[1,1], show_axis=false )

    display( fig )

    #scatter!( ax, galaxy.cloud_positions, transparency = true, color=:white, markersize=0.1,
    #            glowwidth=50, glowcolor=(:lightslateblue, 0.01) )

    scatter!( ax, galaxy.positions, transparency = true, colormap=:magma,  #sunset,CMRmap,magma
                color=1:1000, markersize=0.04, 
                glowwidth=0.8, glowcolor=(:whitesmoke, 0.2) )

    dt = 0.01
    t_0 = time()
    t_max = 30.0

    while time() - t_0 < t_max
        update_positions( nb_stars_per_branch, galaxy, center, dt, 0.1 )

        notify( galaxy.positions )

        sleep( dt )
    end
end

main()