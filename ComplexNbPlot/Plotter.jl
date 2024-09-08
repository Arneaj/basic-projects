using GLMakie, LinearAlgebra

global const phi::Complex = (1 + sqrt(5))/2

function binet( x::Complex )::Complex
    return ( (phi)^x - (-1/phi)^x ) / sqrt(5)
end

function marker_size( is_on_1, is_on_2 )
    return [ 
        is_on_1 ? 20 : 10,
        is_on_2 ? 20 : 10
    ]
end

function main()
    fig = Figure()

    ax1 = Axis( fig[1,1], aspect = AxisAspect(1) )
    ax2 = Axis( fig[1,2], aspect = AxisAspect(1) )

    deactivate_interaction!(ax1, :rectanglezoom )

    x1 = Observable( 0.0 )
    y1 = Observable( 0.0 )
    x2 = Observable( 10.0 )
    y2 = Observable( 0.0 )

    is_on_1 = Observable( false )
    is_on_2 = Observable( false )

    scatterlines!( 
        ax1, @lift( [$x1, $x2] ), @lift( [$y1, $y2] ),
        color = :black,
        markercolor = :black,
        markersize = @lift( marker_size( $is_on_1, $is_on_2 ) )
    )

    X = @lift( [ 
        $x1*t + $x2*(1-t) + ( $y1*t + $y2*(1-t) )*1im
        for t in 0:0.01:1
    ] )

    Y = @lift( binet.( $X ) )

    lines!( ax2, @lift( real.($Y) ), @lift( imag.($Y) ), color = :black )

    on( events(ax1).mouseposition ) do mp
        if !ispressed( ax1, Mouse.left )
            is_on_1[] = norm( mouseposition(ax1) - [ x1[], y1[] ] ) < 0.1
            is_on_2[] = norm( mouseposition(ax1) - [ x2[], y2[] ] ) < 0.1
        end

        if is_on_1[] && ispressed( ax1, Mouse.left )
            x1[], y1[] = mouseposition(ax1)
        end

        if is_on_2[] && ispressed( ax1, Mouse.left )
            x2[], y2[] = mouseposition(ax1)
        end
    end

    display( fig )
    
    return
end

main()

return
