using CoherentNoise
using .Threads
using LinearAlgebra
using GLMakie, ImageCore, Colors

function mesh_plane( resolution )
    points = [ Point3f(i%resolution, i÷resolution, 0) * 2/(resolution-1) - Point3f(1,1,0)  for i in 0:resolution^2-1 ]

    triangles = zeros( Int32, 2*(resolution-1)^2, 3 )

    for x in 1:resolution-1
        for y in 1:resolution-1
            triangles[2*(x+(y-1)*(resolution-1))-1, :] = [(y-1)*resolution+x, y*resolution+x, (y-1)*resolution+x+1]
            triangles[2*(x+(y-1)*(resolution-1)), :] = [y*resolution+x+1, (y-1)*resolution+x+1, y*resolution+x]
        end
    end

    return points, triangles
end

function mesh_cube( resolution )
    up, down, left, right, front, back = 1:6
    faces = [ mesh_plane( resolution ) for _ in 1:6 ]

    R90y = [0 0 1; 0 1 0; -1 0 0]
    R90z = [1 0 0; 0 0 -1; 0 1 0]

    faces[left][1] = -R90y * faces[left][1]
    faces[right][1] = R90y * faces[right][1]
    faces[front][1] = R90z * faces[front][1]
    faces[back][1] = -R90z * faces[back][1]

    faces[up][1] .+= Point3f( 0,0,0.5 )
    faces[down][1] .-= Point3f( 0,0,0.5 )
    faces[left][1] .-= Point3f( 0.5,0,0 )
    faces[right][1] .+= Point3f( 0.5,0,0 )
    faces[front][1] .-= Point3f( 0,0.5,0 )
    faces[back][1] .+= Point3f( 0,0.5,0 )

    for i in 1:6
        faces[i][2] .+= (i-1)*(resolution)^2
    end

    points::Vector{Point3f} = []
    triangles = zeros( Int32, 6*2*(resolution-1)^2, 3 )

    for i in 1:6
        push!( points, faces[i][1]... )
        triangles[1+(i-1)*2*(resolution-1)^2:i*2*(resolution-1)^2, :] = faces[i][2]
    end

    return points, triangles
end

function main()
    resolution = 3
    points, triangles = mesh_cube( resolution )

    fig = Figure()
    ax = Axis3( fig[1,1] ) #LScene( fig[1,1] )

    mesh!( ax, points, triangles, color=:red, shading=NoShading )

    scatter!( ax, points, color=:blue) #, overdraw=true )

    for i in 1:6*2*(resolution-1)^2
        p::Vector{Point3f} = [points[triangles[i,:]]..., points[triangles[i,1]] ]
        lines!( ax, p, color=:blue) #, overdraw=true ) 
    end

    display( fig )
    return
end

main()