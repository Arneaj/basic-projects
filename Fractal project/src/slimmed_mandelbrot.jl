println("loading packages")

using GLMakie, Images
using BenchmarkTools
using .Threads

println("done loading packages")

## global variables and constants

global const x_dim::Int64 = 1024*1
global const y_dim::Int64 = x_dim
global const shape = (x_dim, y_dim)

global const x_resolution::Float64 = (x_dim*0.25)*1.5 
global const y_resolution::Float64 = (y_dim*0.25)*1.5 

## core functions

function sub_mandelbrot(explosion_param::Float64, max_iter, x_range, pixels::Array{Float64} )
    
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

function mandelbrot_threaded_better(explosion_param::Float64, max_iter)

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

## plot functions

function makie_plot()

    println("running")

    img = Observable( mandelbrot_threaded_better(20., 50) )

    imgplot = image(@lift(rotr90($img)),
                    axis = (aspect=DataAspect(),),
                    figure = (figure_padding=0, size= (512, 512) ))

    hidedecorations!(imgplot.axis)

    display(imgplot)

    sleep(10)
end

function makie_animate(tmax::Float64)

    println("running")

    img = Observable( mandelbrot_threaded_better(20., 0.) )

    imgplot = image(@lift(rotr90($img)),
                    axis = (aspect=DataAspect(),),
                    figure = (figure_padding=0, size= (512, 512) ))

    hidedecorations!(imgplot.axis)

    display(imgplot)

    t0 = time()

    while time() - t0 < tmax
        img[] = mandelbrot_threaded_better( 20., 5*(time()-t0) )
        sleep(0)
    end
end

## main

# @btime mandelbrot_threaded(20.0, 50)
# @btime mandelbrot_threaded_better(20.0, 50)

makie_plot()



