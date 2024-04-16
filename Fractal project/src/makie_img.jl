println("loading packages")

using GLMakie, Images

println("done loading packages")

img = Observable( rand(RGB{N0f8}, 512, 512) )

imgplot = image(@lift(rotr90($img)),
                    axis = (aspect=DataAspect(),),
                    figure = (figure_padding=0, size=size(img[])))

hidedecorations!(imgplot.axis)

display(imgplot)

println("running")

function main()

    nframes = 0
    tmax = 10
    t0 = time()

    while time() - t0 < tmax
        img[] = rand(RGB{N0f8}, 512, 512)
        sleep(0)
        nframes += 1
    end

    println("achieved a fps of $(nframes/tmax)")
end

main()