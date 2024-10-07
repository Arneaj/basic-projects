using GLMakie
using LinearAlgebra

function make_spine( head_pos, nb_anchors, Δanchor )
    dist_bw_anchors = norm( Δanchor )

    pos_list = Observable( [ head_pos ] )

    for i in 1:nb_anchors-1
        push!( pos_list[], pos_list[][end] + Δanchor )
    end

    dir_list = @lift( [
        normalize( $pos_list[i] - $pos_list[i+1] )
        for i in 1:nb_anchors-1
    ] )

    θ_list = @lift( [
        acos( $dir_list[i] ⋅ (- $dir_list[i+1]) / (1.01 * norm($dir_list[i]) * norm($dir_list[i+1])) )
        for i in 1:nb_anchors-2
    ] )

    return pos_list, dir_list, θ_list, dist_bw_anchors
end

function turn_90( vector )
    return [0 -1; 1 0] * vector
end

function turn_θ( vector, θ )
    return [cos(θ) -sin(θ); sin(θ) cos(θ)] * vector
end

function fish()
    fig = Figure( )
    ax = Axis( fig[1,1], aspect = AxisAspect(1), limits=(-20, 20, -20, 20), backgroundcolor=:cadetblue3 )
    hidedecorations!( ax )

    ### fish shape 
    nb_anchors = 10
    Δanchor = [1.0, 0]
    ΔposΔt = 20

    radii_list = [ 1.5, 2.0, 2.5, 2.5, 2.0, 1.5, 1.0, 1.0, 0.5 ] * 0.5
    ###

    ### main shape set-up
    start_pos = Point2f( 0.0, 0.0 )

    pos_list, dir_list, θ_list, dist_bw_anchors = make_spine( start_pos, nb_anchors, Δanchor )

    disp_list = @lift(
        push!( 
            push!(
                push!(
                    [$pos_list[1] + radii_list[1] * $dir_list[1] ],
                    ($pos_list[1:end-1] .+ radii_list .* turn_90.($dir_list))...
                ),
                $pos_list[end]
            ), (reverse($pos_list[1:end-1]) .- reverse(radii_list) .* reverse(turn_90.($dir_list)))...
        )
    )

    @lift( push!( $disp_list, $disp_list[1] ) )
    ###

    ### fish fins and eyes
    eyes_pos = @lift( [ 
        $pos_list[1] + 0.5*radii_list[2] * turn_90($dir_list[1]),
        $pos_list[1] - 0.5*radii_list[2] * turn_90($dir_list[1])
    ] )

    left_fin_direction = @lift( turn_θ( $dir_list[2], 4*π/5 ) )
    left_fin_orth = @lift( turn_90( $left_fin_direction ) )

    right_fin_direction = @lift( turn_θ( $dir_list[2], -4*π/5 ) )
    right_fin_orth = @lift( turn_90( $right_fin_direction ) )

    center_fin_direction = @lift( - sum( $dir_list[1:5] ) / 5 )
    center_fin_orth = @lift( turn_90( $center_fin_direction ) )

    back_fin_direction = @lift( normalize( $pos_list[end] - $pos_list[end-3] ) )
    back_fin_orth = @lift( turn_90( $back_fin_direction ) )

    a_left = 1.8
    a_right = 1.8
    a_center = 1.2
    a_back = 2.1

    e_left = 0.95
    e_right = 0.95
    e_center = 0.99
    e_back = 0.96

    fins_pos = @lift( [
        $pos_list[2] + ( - $left_fin_direction*cos(θ) + $left_fin_orth*sin(θ) ) * a_left * (1-e_left^2) / (1+e_left*cos(θ))
        for θ in 0:0.15:2*π
    ] )

    @lift( push!( $fins_pos, Point2f(NaN) ) )

    @lift( push!( 
        $fins_pos,
        [
            $pos_list[2] + ( - $right_fin_direction*cos(θ) + $right_fin_orth*sin(θ) ) * a_right * (1-e_right^2) / (1+e_right*cos(θ))
            for θ in 0:0.15:2*π
        ]... 
    ) )

    center_fin_pos = @lift( [
            $pos_list[2] + ( - $center_fin_direction*cos(θ) + $center_fin_orth*sin(θ) ) * a_center * (1-e_center^2) / (1+e_center*cos(θ))
            for θ in 0:0.15:2*π
    ] )

    back_fin_pos = @lift( [
            $pos_list[end-3] + ( - $back_fin_direction*cos(θ) + $back_fin_orth*sin(θ) ) * a_back * (1-e_back^2) / (1+e_back*cos(θ))
            for θ in 0:0.15:2*π
    ] )
    ###

    ### displaying different parts
    mesh!( ax, fins_pos, color=:salmon, shading=NoShading )
    lines!( ax, fins_pos, color=ax.backgroundcolor )
    mesh!( ax, back_fin_pos, color=:salmon, shading=NoShading )
    lines!( ax, back_fin_pos, color=ax.backgroundcolor )
    mesh!( ax, disp_list, color=:indianred, shading=NoShading )
    lines!( ax, disp_list, color=ax.backgroundcolor )
    scatter!( ax, eyes_pos, color=:black, markersize=0.7, markerspace=:data )
    mesh!( ax, center_fin_pos, color=:salmon, shading=NoShading )
    lines!( ax, center_fin_pos, color=ax.backgroundcolor )

    display( fig )
    ###

    t = time()

    while ax.scene.events.window_open[]
        ### make head follow pointed direction
        mp = mouseposition(ax.scene)

        aim_pos = Point2f( mp[1], mp[2] )
        aim_dir = normalize( aim_pos - pos_list[][1] )

        pos_list[][1] += aim_dir * ΔposΔt * (time() - t)
        notify(pos_list)

        t = time()
        ###

        ### correct over-bending of spine
        for i in 1:nb_anchors-1
            if i > 1
                if θ_list[][i-1] < 4*π/5 
                    pos_list[][i+1] -= ( dir_list[][i-1] - dir_list[][i] ) * 0.3
                    notify(pos_list)
                end
            end
            
            pos_list[][i+1] = pos_list[][i] - dir_list[][i] * dist_bw_anchors
            notify(pos_list)
        end
        ###

        sleep(0)
    end
    
    return
end

function lizard()
    fig = Figure( )
    ax = Axis( fig[1,1], aspect = AxisAspect(1), limits=(-20, 20, -20, 20), backgroundcolor=:cadetblue3 )
    hidedecorations!( ax )

    ### lizard shape 
    nb_anchors = 10
    Δanchor = [1.0, 0]
    ΔposΔt = 20

    radii_list = [ 1.5, 2.0, 2.5, 2.5, 2.0, 1.5, 1.0, 1.0, 0.5 ] * 0.5
    ###

    ### main shape set-up
    start_pos = Point2f( 0.0, 0.0 )

    pos_list, dir_list, θ_list, dist_bw_anchors = make_spine( start_pos, nb_anchors, Δanchor )

    disp_list = @lift(
        push!( 
            push!(
                push!(
                    [$pos_list[1] + radii_list[1] * $dir_list[1] ],
                    ($pos_list[1:end-1] .+ radii_list .* turn_90.($dir_list))...
                ),
                $pos_list[end]
            ), (reverse($pos_list[1:end-1]) .- reverse(radii_list) .* reverse(turn_90.($dir_list)))...
        )
    )

    @lift( push!( $disp_list, $disp_list[1] ) )
    ###

    ### lizard legs and eyes
    eyes_pos = @lift( [ 
        $pos_list[1] + 0.5*radii_list[2] * turn_90($dir_list[1]),
        $pos_list[1] - 0.5*radii_list[2] * turn_90($dir_list[1])
    ] )

    FRleg_pos_list = @lift( [
        $pos_list[2],
        $pos_list[2] - radii_list[2] * $dir_list[2] - 1.5*radii_list[2] * turn_90($dir_list[2]),
        $pos_list[2] - 3*radii_list[2] * turn_90($dir_list[2])
    ] )
    ###

    ### displaying different parts
    mesh!( ax, fins_pos, color=:salmon, shading=NoShading )
    lines!( ax, fins_pos, color=ax.backgroundcolor )
    mesh!( ax, back_fin_pos, color=:salmon, shading=NoShading )
    lines!( ax, back_fin_pos, color=ax.backgroundcolor )
    mesh!( ax, disp_list, color=:indianred, shading=NoShading )
    lines!( ax, disp_list, color=ax.backgroundcolor )
    scatter!( ax, eyes_pos, color=:black, markersize=0.7, markerspace=:data )
    mesh!( ax, center_fin_pos, color=:salmon, shading=NoShading )
    lines!( ax, center_fin_pos, color=ax.backgroundcolor )

    display( fig )
    ###

    t = time()

    while ax.scene.events.window_open[]
        ### make head follow pointed direction
        mp = mouseposition(ax.scene)

        aim_pos = Point2f( mp[1], mp[2] )
        aim_dir = normalize( aim_pos - pos_list[][1] )

        pos_list[][1] += aim_dir * ΔposΔt * (time() - t)
        notify(pos_list)

        t = time()
        ###

        ### correct over-bending of spine
        for i in 1:nb_anchors-1
            if i > 1
                if θ_list[][i-1] < 4*π/5 
                    pos_list[][i+1] -= ( dir_list[][i-1] - dir_list[][i] ) * 0.3
                    notify(pos_list)
                end
            end
            
            pos_list[][i+1] = pos_list[][i] - dir_list[][i] * dist_bw_anchors
            notify(pos_list)
        end
        ###

        sleep(0)
    end
    
    return
end

function main()
    fish()
end

main()

#return

