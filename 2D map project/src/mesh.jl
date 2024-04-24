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

    faces[left] = ( [ Point3f(-R90y * p) for p in faces[left][1] ], faces[left][2] )
    faces[right] = ( [ Point3f(R90y * p) for p in faces[right][1] ], faces[right][2] )
    faces[front] = ( [ Point3f(R90z * p) for p in faces[front][1] ], faces[front][2] )
    faces[back] = ( [ Point3f(-R90z * p) for p in faces[back][1] ], faces[back][2] )

    faces[up][1] .+= Point3f( 0,0,1 )
    faces[down][1] .-= Point3f( 0,0,1 )
    faces[left][1] .-= Point3f( 1,0,0 )
    faces[right][1] .+= Point3f( 1,0,0 )
    faces[front][1] .-= Point3f( 0,1,0 )
    faces[back][1] .+= Point3f( 0,1,0 )

    for i in 1:6
        faces[i][2] .+= (i-1)*(resolution)^2
    end

    points::Vector{Point3f} = []
    triangles = zeros( Int32, 6*2*(resolution-1)^2, 3 )

    for i in 1:6
        push!( points, faces[i][1]... )
        triangles[1+(i-1)*2*(resolution-1)^2:i*2*(resolution-1)^2, :] = faces[i][2]
    end

    i = 1
    while i <= length(points)
        j = i+1
        while j <= length(points)
            if points[i] == points[j] 
                deleteat!(points, j)
                triangles[triangles.==j] .= i
                triangles[triangles.>j] .-= 1
            end
            j+=1
        end
        i+=1
    end

    return points, triangles
end

function equalize_grid( p::Point3f ) 
    x2 = p[1]^2
    y2 = p[2]^2
    z2 = p[3]^2

    x = p[1] * sqrt( 1 - y2/2 - z2/2 + y2*z2/3 )
    y = p[2] * sqrt( 1 - x2/2 - z2/2 + x2*z2/3 )
    z = p[3] * sqrt( 1 - y2/2 - x2/2 + y2*x2/3 )

    return Point3f( x, y, z )
end

function mesh_ball( resolution )
    points, triangles = mesh_cube( resolution )

    points = equalize_grid.(points)

    return points, triangles
end

function main()
    resolution = 16
    points, triangles = mesh_ball( resolution )

    """
    @show points
    @show triangles
    @show length(points)
    """

    fig = Figure()
    ax = Axis3( fig[1,1], aspect=:equal ) #LScene( fig[1,1] )

    mesh!( ax, points, triangles, color=:red) #shading=NoShading )

    scatter!( ax, points, color=:blue) #, overdraw=true )

    """
    for i in 1:6*2*(resolution-1)^2
        p::Vector{Point3f} = [points[triangles[i,:]]..., points[triangles[i,1]] ]
        lines!( ax, p, color=:blue) #, overdraw=true ) 
    end
    """

    display( fig )
    return
end

main()