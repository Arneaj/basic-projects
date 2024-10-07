using GLMakie
using LinearAlgebra

function main()
    fig = Figure( )
    ax = Axis( fig[1,1], aspect = AxisAspect(1), limits=(-2, 8, -5, 5) )
    hidedecorations!( ax )

    ### different modes
    leg_placing_mode = false
    ###

    ### base set-up
    nb_anchors = Observable( 3 )
    Δanchor = Observable( 1.0 )
    Δpos = 0.3
    eye_distance = Observable( 0.5 )

    radii_list = Observable( [ 1.0 for _ in 1:nb_anchors[]-1 ] )

    pos_list = @lift( [ Point2f( i * $Δanchor, 0 ) for i in 0:nb_anchors[]-1 ] )

    disp_list = @lift(
        push!( 
            push!(
                push!(
                    [$pos_list[1] + [-$radii_list[1], 0] ],
                    ($pos_list[1:end-1] .+ Vec2.( 0, $radii_list ) )...
                ),
                $pos_list[end]
            ), (reverse($pos_list[1:end-1]) .- Vec2.( 0, reverse($radii_list) ) )...
        )
    )

    disp_list = @lift( push!($disp_list, $disp_list[1] ) )

    eyes_pos = @lift( [ 
        $pos_list[1] + $eye_distance * Point2f( 0, $radii_list[1]),
        $pos_list[1] - $eye_distance * Point2f( 0, $radii_list[1])
    ] )

    leg_spine = Observable( [ Point2f(NaN) ] )
    permanent_leg_spine = Observable( [ Point2f(NaN) ] )
    ###

    ### menu
    add_anchor = Button( fig, label="Add anchor" )
    remove_anchor = Button( fig, label="Remove anchor" )
    current_nb_anchors = Label( fig, @lift( "Currently $($nb_anchors) anchors" ) )

    color_menu = Menu( 
        fig, options=["red", "salmon", "grey", "beige", "gold", "seagreen"], default="red"
    )

    eye_slider = Slider( fig, range=0:0.01:1, startvalue=eye_distance[] )

    Δanchor_slider = Slider( fig, range=0:0.01:2.0, startvalue=Δanchor[] )

    leg_button = Button( fig, label="Place a leg" )

    save_button = Button( fig, label="Save" )

    fig[1,2] = vgrid!( 
        current_nb_anchors, add_anchor, remove_anchor,
        Label(fig, "Color : "), color_menu,
        Label(fig, "Eye distance : "), eye_slider,
        Label(fig, "Δanchor : "), Δanchor_slider,
        leg_button,
        save_button
    )
    ###

    ### menu interactions
    on( add_anchor.clicks ) do c
        nb_anchors[] += 1

        push!( radii_list[], 1.0 )

        push!( pos_list[], Point2f( (nb_anchors[]-1) * Δanchor[], 0) )
        #pos_list[] = [ pos_list[][i] - Point2f( 0, Δanchor/2 ) for i in 1:nb_anchors[]-1 ]

        notify( nb_anchors )
        notify( radii_list )
        notify( pos_list )
    end

    on( remove_anchor.clicks ) do c
        if nb_anchors[] <= 3 return end

        nb_anchors[] -= 1

        pop!( radii_list[] )

        pop!( pos_list[] )

        notify( nb_anchors )
        notify( radii_list )
        notify( pos_list )
    end

    on( save_button.clicks ) do c
        println( "Current iteration : " )
        @show nb_anchors[]
        @show Δanchor[]
        @show Δpos
        @show radii_list[]
        println( " " )
    end

    on( leg_button.clicks ) do c
        leg_placing_mode = true
    end

    on( eye_slider.value ) do v
        eye_distance[] = v
    end

    on( Δanchor_slider.value ) do v
        Δanchor[] = v
    end

    deactivate_interaction!( ax, :rectanglezoom )

    closest_point_index = Inf

    on( ax.scene.events.mouseposition ) do mp
        mb = ax.scene.events.mousebutton[]

        mp = mouseposition(ax.scene)

        if !leg_placing_mode && (mb.button == Mouse.left) && (mb.action == Mouse.press) && (mp[1] < ax.limits[][2])

            closest_point_index = clamp( Int64( round( 1 + mp[1] / Δanchor[] ) ), 1, nb_anchors[]-1 )

            radii_list[][closest_point_index] = abs( mp[2] )
            
            notify(radii_list)
        end

        if leg_placing_mode
            new_closest_point_index = clamp( Int64( round( 1 + mp[1] / Δanchor[] ) ), 1, nb_anchors[]-1 )

            if new_closest_point_index != closest_point_index
                closest_point_index = new_closest_point_index
                empty!( leg_spine[] )
                @lift( push!(
                    leg_spine[],
                    $pos_list[closest_point_index] + Point2f(0, 3.0),
                    $pos_list[closest_point_index] + Point2f(-1, 2.0),
                    $pos_list[closest_point_index],
                    $pos_list[closest_point_index] + Point2f(-1, -2.0),
                    $pos_list[closest_point_index] + Point2f(0, -3.0)
                ) )
                notify( leg_spine )
            end

            if mb.button == Mouse.left && mb.action == Mouse.press
                leg_placing_mode = false
                closest_point_index = Inf

                push!( leg_spine[], Point2f(NaN) )

                push!( permanent_leg_spine[], leg_spine[]... )

                empty!( leg_spine[] )
                push!( leg_spine[], Point2f(NaN) )

                notify( leg_spine )
                notify( permanent_leg_spine )
            end
        end
    end
    ###

    ### plot
    lines!( ax, leg_spine; color=:black)
    lines!( ax, permanent_leg_spine; color=:black)
    mesh!( ax, disp_list, color=color_menu.selection, shading=NoShading )
    lines!( ax, disp_list, color=:black )
    scatterlines!( ax, pos_list, color=:white, markersize=15, markerspace=:data )
    scatter!( ax, eyes_pos, color=:black, markersize=0.7, markerspace=:data )

    display( fig )
    ###
end

main()