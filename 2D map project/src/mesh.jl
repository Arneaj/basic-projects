using CoherentNoise
using .Threads
using LinearAlgebra
using GLMakie, ImageCore, Colors

function mesh_ball()
    Theta = 0:0.1:2*pi
    Phi = 0:0.1:pi
    R = 1

    #X = [ R*cos(theta) for theta in Theta ]
    #Y = [ R*sin(theta) for theta in Theta ]

    X = [ R*cos(theta)*cos(phi) for theta in Theta, phi in Phi ]
    Y = [ R*sin(theta)*cos(phi) for theta in Theta, phi in Phi ]
    Z = [ R*sin(phi) for theta in Theta, phi in Phi ]

    points = []

    for i in 1:length(Theta), j in 1:length(Phi)
        push!( points, GLMakie.Point3f( X[i,j], Y[i,j], Z[i,j] ) )
    end

    return points
end

function plane()
    
end

function main()

    fig = Figure()
    ax = Axis( fig[1,1], aspect = DataAspect() )
    mesh!( ax, mesh_ball(), color=:gray, shading = NoShading )

    display( fig )

    return
end

main()