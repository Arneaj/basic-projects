using GLMakie, Images
using LinearAlgebra

function main()

    map = rotr90( load("data/rgb.png") )

    dim = size(map)

    lat = Base._linspace(51.4083, 51.5775, dim[2])
    lon = Base._linspace(-0.4012, 0.0929, dim[1])

    fig = Figure()
    ax = GLMakie.Axis( fig[1,1], aspect=DataAspect() )

    image!( ax, map )

    display( fig )

    return
end

main()




