using DelimitedFiles
using PyPlot
using Dates
using BenchmarkTools
using .Threads

## variables

global xSun::Int64 = 0
global ySun::Int64 = 0

global const dim::Int64 = 256

global const shape = (dim, dim)

global height_map::Matrix{Float64} = zeros(shape)
global colored_map::Array{Float64} = zeros(shape..., 3)

height_map = readdlm("data/height_map.txt", ' ', Float64, '\n')
colored_map[:,:,1] = readdlm("data/colored_map_r.txt", ' ', Float64, '\n')
colored_map[:,:,2] = readdlm("data/colored_map_g.txt", ' ', Float64, '\n')
colored_map[:,:,3] = readdlm("data/colored_map_b.txt", ' ', Float64, '\n')

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
                    shaded_world[xP,yP,:] *= 0.7
                    break
                end
            end
        end
    end  
end

function shade_threaded_better(some_colored_world, 
                            some_height_map, 
                            xL, yL, hL, dl)

    shaded_world::Array{Float64} = copy(some_colored_world)
    
    nb_threads::Int64 = Threads.nthreads()
    nb_arrays::Int64 = dim/nb_threads
    i_ranges = reshape( (1:dim), (nb_arrays, nb_threads) )

    tasks = map((1:nb_threads)) do k
        @spawn sub_shade(some_colored_world, some_height_map, xL, yL, hL, dl, i_ranges[:,k], shaded_world)
    end
    
    wait.(tasks)
    return shaded_world
end

## plot functions

function animated_plot_sun_revolution(dt::Float64, tmax::Float64)

    plt.ion()

    fig = plt.figure()
    ax = fig.add_subplot(1,1,1)

    shaded_world = shade(colored_map, height_map, 0, 0, 3, 0.001)
    ax.imshow(shaded_world)

    for t in (dt:dt:tmax+dt)

        xL::Int64 = round(dim/2 * cos(t) + dim/2)
        yL::Int64 = round(dim/2 * sin(t) + dim/2)

        temp_shaded_world = shade_threaded_better(colored_map, height_map, xL, yL, 3, 0.001)

        ax.clear()
        ax.imshow(temp_shaded_world)

        fig.canvas.draw()
        fig.canvas.flush_events()

    end
end

function mouse_mvmt(event)

    x = event.xdata
    y = event.ydata

    x = x < 0 ? 0 : x
    x = x > dim ? dim : x

    y = y < 0 ? 0 : y
    y = y > dim ? dim : y

    global xSun = Int64(round(x))
    global ySun = Int64(round(y))
end

function animated_plot_mouse_sun()

    plt.ion()

    fig = plt.figure()
    ax = fig.add_subplot(1,1,1)

    shaded_world = shade(colored_map, height_map, 0, 0, 3, 0.001)
    ax.imshow(shaded_world)

    thing = fig.canvas.mpl_connect("motion_notify_event", mouse_mvmt)

    for _ in (1:1000)

        xL = xSun

        yL = ySun

        temp_shaded_world = shade_threaded_better(colored_map, height_map, yL, xL, 3, 0.001)

        ax.clear()
        ax.imshow(temp_shaded_world)

        fig.canvas.draw()
        fig.canvas.flush_events()

    end

    fig.canvas.mpl_disconnect(thing)
end

## main

println(Threads.nthreads())

animated_plot_mouse_sun()

# animated_plot_sun_revolution(0.1, 10.0)

"""
@btime shade(colored_map, height_map, ySun, xSun, 3, 0.001)

@btime shade_threaded_simple(colored_map, height_map, ySun, xSun, 3, 0.001)

@btime shade_threaded_better(colored_map, height_map, ySun, xSun, 3, 0.001)
"""