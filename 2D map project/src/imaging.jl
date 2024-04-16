module MapSun

using GLMakie, ImageCore, Colors
using DelimitedFiles
using .Threads

println("done importing packages")

global const dim::Int64 = 256
global const shape = ( dim, dim )

## main functions

function diagonal(xL, yL, 
                xP, yP, 
                dl, maxl = 1)

    lamb_list::Array{Float64} = dl:dl:maxl+dl

    pos_list::Array{Float64} = zeros((size(lamb_list)[1], 2))

    for i in 1:size(lamb_list)[1]
        pos_list[i,1] = round(lamb_list[i]*(xL-xP) + xP)
        pos_list[i,2] = round(lamb_list[i]*(yL-yP) + yP)
    end

    pos_list = unique(pos_list, dims=0)

    return pos_list
end   

function dP(xP, yP, 
            x, y)

    return sqrt((xP-x)^2 + (yP-y)^2) / shape[1]
end

function sub_shade(some_colored_world, 
                some_height_map, 
                xL, yL, hL, dl, 
                x_range,
                shaded_world)

    for xP in x_range
        for yP in (1:shape[2])
            if xP == xL && yP == yL continue end

            hP = some_height_map[xP,yP]
            if (hP < 0.1) continue end

            dPL = dP(xP,yP, xL,yL)

            maxl = (1-hP) / (hL-hP)

            pos_list = diagonal(xL,yL, xP,yP, dl, maxl)

            for i in (1:size(pos_list)[1]) 
                
                x = Int64(pos_list[i,1])
                y = Int64(pos_list[i,2])
                
                if (x == xP && y==yP) continue end
                
                hX = some_height_map[x, y]
                dPX = dP(xP,yP, x,y)
                
                if (hX > hP && (hL-hP)/dPL < (hX-hP)/dPX )
                    shaded_world[xP,yP] *= 0.7
                    break
                end
            end
        end
    end  
end

function shade_threaded_better(some_colored_world, 
                                some_height_map, 
                                xL, yL, hL, dl)

    shaded_world = copy(some_colored_world)

    nb_threads::Int64 = Threads.nthreads()
    nb_arrays::Int64 = dim/nb_threads
    i_ranges = reshape( (1:dim), (nb_arrays, nb_threads) )

    tasks = map( (1:nb_threads) ) do k
        @spawn sub_shade(some_colored_world, some_height_map, xL, yL, hL, dl, i_ranges[:,k], shaded_world)
    end

    wait.(tasks)
    return shaded_world
end

## plotting functions

function mk_animate_auto(tmax::Float64, some_colored_world, some_height_map)
    println("running")

    img = Observable( shade_threaded_better(some_colored_world, some_height_map, 0, 0, 3, 0.001) )

    imgplot = image( img )

    hidedecorations!( imgplot.axis )
    display( imgplot )

    t0 = time()

    while time()-t0 < tmax

        xL::Int64 = round(dim/2 * cos(time()-t0) + dim/2)
        yL::Int64 = round(dim/2 * sin(time()-t0) + dim/2)

        img[] = shade_threaded_better(some_colored_world, some_height_map, xL, yL, 3, 0.001)
        sleep(0)
    end
end

function mk_animate_mouse(tmax::Float64, some_colored_world, some_height_map)
    println("running")

    img = Observable( shade_threaded_better(some_colored_world, some_height_map, 0, 0, 3, 0.001) )

    fig = Figure()
    ax1 = Axis( fig[1,1] )
    imgplot = image!( ax1, img, fxaa=false )

    hidedecorations!( ax1 )
    display( fig )

    t0 = time()

    while time()-t0 < tmax

        mouse_pos = Makie.mouseposition( ax1.scene )
        xL::Int64 = round( mouse_pos[1] )
        yL::Int64 = round( mouse_pos[2] )

        img[] = shade_threaded_better( some_colored_world, some_height_map, xL, yL, 3, 1/dim )
        sleep( 0 )
    end
end

## main

function main()

    height_map = readdlm("data/height_map.txt", ' ', Float64, '\n')

    colored_map = Array{ RGB{Float64} }( undef, dim, dim )
    colored_map_r = readdlm("data/colored_map_r.txt", ' ', Float64, '\n')
    colored_map_g = readdlm("data/colored_map_g.txt", ' ', Float64, '\n')
    colored_map_b = readdlm("data/colored_map_b.txt", ' ', Float64, '\n')

    for ix in (1:dim)
        for iy in (1:dim)
            colored_map[ix, iy] = RGB{Float64}( colored_map_r[ix, iy], colored_map_g[ix, iy], colored_map_b[ix, iy] ) 
        end
    end
    
    mk_animate_mouse(30., colored_map, height_map)
end


main() 
end # module

