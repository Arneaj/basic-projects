using PyPlot
using BenchmarkTools
using .Threads

## global variables and constants

global const x_dim::Int64 = 1024*4
global const y_dim::Int64 = x_dim
global const shape = (x_dim, y_dim)

global const x_resolution::Float64 = (x_dim*0.25)*1.5 
global const y_resolution::Float64 = (y_dim*0.25)*1.5 

global nb_clicks::Int64 = 0
global zoom::Float64 = 1.0
global current_center::Complex{Float64} = 3/4 * x_dim/x_resolution + 1/2 * y_dim/y_resolution * im 

## core functions

function mandelbrot(explosion_param::Float64, max_iter::Int64)

    pixels::Array{Float64} = ones(shape)
    
    for i in (1:x_dim)
        for j in (1:y_dim)
            x::Float64 = (i-3*x_dim/4)/x_resolution
            y::Float64 = (j-y_dim/2)/y_resolution
            c = x + y*im
            z = 0.0 + 0.0im

            iterations = 0

            while abs(z) < explosion_param && iterations < max_iter
                z = z^2 + c

                iterations += 1
            end

            pixels[i,j] = 1 - iterations * (1/max_iter)
        end
    end

    return transpose(pixels)
end

function sub_mandelbrot(explosion_param::Float64, max_iter::Int64, x_range, pixels::Array{Float64} )
    
    for i in x_range
        for j in (1:y_dim)
            x::Float64 = (i-3*x_dim/4)/x_resolution
            y::Float64 = (j-y_dim/2)/y_resolution
            c = x + y*im
            z = 0.0 + 0.0im

            iterations = 0

            while abs(z) < explosion_param && iterations < max_iter
                z = z^2 + c

                iterations += 1
            end

            pixels[i,j] = 1 - iterations * (1/max_iter)
        end
    end

    return true
end

function mandelbrot_threaded(explosion_param::Float64, max_iter::Int64)

    pixels::Array{Float64} = ones(shape)
    
    @threads for i in (1:x_dim)
        for j in (1:y_dim)
            x::Float64 = (i-3*x_dim/4)/x_resolution
            y::Float64 = (j-y_dim/2)/y_resolution
            c = x + y*im
            z = 0.0 + 0.0im

            iterations = 0

            while abs(z) < explosion_param && iterations < max_iter
                z = z^2 + c

                iterations += 1
            end

            pixels[i,j] = 1 - iterations * (1/max_iter)
        end
    end

    return transpose(pixels)
end


function mandelbrot_threaded_better(explosion_param::Float64, max_iter::Int64)

    # pixels::Array{Float64} = Array{Float64}(undef, shape)
    pixels::Array{Float64} = zeros(shape)

    nb_threads::Int64 = Threads.nthreads()
    nb_arrays::Int64 = x_dim/nb_threads
    i_ranges = reshape( (1:x_dim), (nb_arrays, nb_threads) )

    tasks = map((1:nb_threads)) do k
        @spawn sub_mandelbrot(explosion_param, max_iter, i_ranges[:,k], pixels)
    end

    wait.(tasks)
    return transpose(pixels)
end


function mandelbrot_threaded_click(explosion_param::Float64, max_iter::Int64, zoom::Float64)

    pixels::Array{Float64} = ones(shape)
    
    @threads for i in (1:x_dim)
        for j in (1:y_dim)
            c = i/x_resolution + j/y_resolution * im
            c /= zoom
            c -= current_center
            z = 0.0 + 0.0im

            iterations = 0

            while abs(z) < explosion_param && iterations < max_iter
                z = z^2 + c

                iterations += 1
            end

            pixels[i,j] = 1 - iterations * (1/max_iter)
        end
    end

    return transpose(pixels)
end


function on_mouse_click(event)

    x = event.xdata
    y = event.ydata

    x = x < 0 ? 0 : x
    x = x > x_dim ? x_dim : x

    y = y < 0 ? 0 : y
    y = y > y_dim ? y_dim : y

    x -= x_dim/2
    y -= y_dim/2

    global current_center -= x/zoom/x_resolution + y/zoom/y_resolution * im
    global nb_clicks += 1

    println(current_center)
    println(nb_clicks)
end

## plot functions

function plot_graph()

    fig = plt.figure()
    ax1 = fig.add_subplot(1,2,1)
    ax2 = fig.add_subplot(1,2,2)


    ax1.imshow(mandelbrot_threaded_better(20.0, 50))
    ax2.imshow(mandelbrot_threaded(20.0, 50))

    plt.show()

end


function animated_plot_graph(dt::Float64)

    plt.ion()

    fig = plt.figure()
    ax = fig.add_subplot(1,1,1)

    ax.imshow(mandelbrot(20.0, 50, 4.0+0.1im), cmap="gray")

    for t in (dt:dt:1000)

        temp_pixels = mandelbrot_threaded(20.0, 50, 3.0 + cos(t) + 0.0im)

        ax.clear()
        ax.imshow(temp_pixels, cmap="gray")

        fig.canvas.draw()
        fig.canvas.flush_events()

    end
end

function on_click_animated_plot()

    plt.ion()

    fig = plt.figure()
    ax = fig.add_subplot(1,1,1)

    ax.imshow(mandelbrot(20.0, 50, 2.0+0.0im))

    thing = fig.canvas.mpl_connect("button_press_event", on_mouse_click)

    fig.canvas.draw()
    fig.canvas.flush_events()

    while true
        global zoom = 1.9^nb_clicks

        temp_pixels = mandelbrot_threaded_click(20.0, (nb_clicks+1)*50, zoom)

        ax.clear()
        ax.imshow(temp_pixels)

        fig.canvas.draw()
        fig.canvas.flush_events()
    end

    fig.canvas.mpl_disconnect(thing)
end


## main

println(Threads.nthreads())


# @btime mandelbrot(20.0, 50)

# @btime mandelbrot_threaded(20.0, 50)

# @btime mandelbrot_threaded_better(20.0, 50)


# plot_graph()

# animated_plot_graph(0.1)

on_click_animated_plot()

# mandelbrot_threaded_better(1.0, 1)





