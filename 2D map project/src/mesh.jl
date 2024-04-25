using CoherentNoise
using LinearAlgebra
using GLMakie, ImageCore, Colors

function mesh_plane( resolution::Int64 )
    points::Vector{Point3f} = [ Point3f(i%resolution, i÷resolution, 0) * 2/(resolution-1) - Point3f(1,1,0)  for i in 0:resolution^2-1 ]

    triangles = zeros( Int32, 2*(resolution-1)^2, 3 )

    for x in 1:resolution-1
        for y in 1:resolution-1
            triangles[2*(x+(y-1)*(resolution-1))-1, :] = [(y-1)*resolution+x, y*resolution+x, (y-1)*resolution+x+1]
            triangles[2*(x+(y-1)*(resolution-1)), :] = [y*resolution+x+1, (y-1)*resolution+x+1, y*resolution+x]
        end
    end

    return points, triangles
end

function mesh_cube( resolution::Int64 )
    up, down, left, right, front, back = 1:6
    faces = [ mesh_plane( resolution ) for _ in 1:6 ]

    R90y = [0 0 1; 0 1 0; -1 0 0]
    Rm90y = [0 0 -1; 0 1 0; 1 0 0]
    R180y = [-1 0 0; 0 1 0; 0 0 -1]
    R90z = [1 0 0; 0 0 -1; 0 1 0]
    Rm90z = [-1 0 0; 0 0 1; 0 1 0]

    faces[left] = ( [ Point3f(R90y * p) for p in faces[left][1] ], faces[left][2] )
    faces[right] = ( [ Point3f(Rm90y * p) for p in faces[right][1] ], faces[right][2] )
    faces[front] = ( [ Point3f(Rm90z * p) for p in faces[front][1] ], faces[front][2] )
    faces[back] = ( [ Point3f(R90z * p) for p in faces[back][1] ], faces[back][2] )
    faces[up] = ( [ Point3f(R180y * p) for p in faces[up][1] ], faces[up][2] )

    faces[up][1] .+= Point3f( 0,0,1 )
    faces[down][1] .-= Point3f( 0,0,1 )
    faces[left][1] .-= Point3f( 1,0,0 )
    faces[right][1] .+= Point3f( 1,0,0 )
    faces[front][1] .-= Point3f( 0,1,0 )
    faces[back][1] .+= Point3f( 0,1,0 )

    for i in 1:6
        faces[i][2] .+= (i-1)*(resolution)^2
    end

    points::Vector{Point3f} = Vector{Point3f}( undef, 6*resolution^2 )
    triangles = zeros( Int32, 6*2*(resolution-1)^2, 3 )

    for i in 1:6
        #push!( points, faces[i][1]... )
        points[1+(i-1)*resolution^2:i*resolution^2] = faces[i][1]
        triangles[1+(i-1)*2*(resolution-1)^2:i*2*(resolution-1)^2, :] = faces[i][2]
    end

    i = 1
    while i <= length(points)
        j = i+1
        while j <= length(points)
            if norm(points[i]-points[j]) <= 0.01
                deleteat!(points, j)
                triangles[triangles.==j] .= i
                triangles[triangles.>j] .-= 1
            end
            j+=1
        end
        i+=1
    end

    """
    @show 6*resolution^2
    @show 2*resolution^2 + 4*(resolution-2)*(resolution-1)
    @show length(points)
    """

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

function mesh_ball( resolution::Int64 )
    points, triangles = mesh_cube( resolution )

    points = equalize_grid.(points)

    return points, triangles
end

function noisy_ball( resolution::Int64 )
    points, triangles = mesh_ball( resolution )

    sphere_normals = normalize.(points)

    points += sphere_normals .* rand(length(points)) * 0.1

    return points, triangles
end

function nice_ball( resolution::Int64 )

    points, triangles = mesh_ball( resolution )
    sphere_normals = normalize.(points)

    sampler = opensimplex_3d(seed=nothing, smooth=true)
    frac = fbm_fractal_3d(seed=nothing,        # seed if you want reproductible results
                        source=sampler,        # source sampler
                        frequency=1.5,         # base frequency of first noise 1.5
                        octaves=10,            # number of noise freq
                        persistence=0.5,       # how quickly the amp diminishes between octaves 0.5
                        lacunarity=2.0)        # how quickly the freq increases between octaves 2.0
    
    
    """weird_map = gen_image( frac, w=dim, h=dim )    
    height_map::Array{Float64} = collect( reinterpret(Float64, Gray.(weird_map)) )
    height_map = (height_map .- 0.3)./0.9"""

    noise::Array{Float64} = [ sample( frac, p... ) for p in points ]
    noise = (noise .- 0.3)./9

    points += sphere_normals .* noise  
    #colored_map = color_map( height_map )

    return points, triangles
end

function main()
    resolution = 64
    points, triangles = nice_ball( resolution )

    """
    @show points
    @show triangles
    @show length(points)
    """

    fig = Figure()
    pl = PointLight(Point3f(5), RGBf(2, 2, 2))
    al = AmbientLight(RGBf(0.2, 0.2, 0.2))
    ax = LScene( fig[1,1], show_axis=false, scenekw = (lights = [pl, al], backgroundcolor=:black, clear=true) ) #Axis3( fig[1,1], aspect=:equal )

    mesh!( ax, points, triangles, color=:gray)#, shading=NoShading )

    #scatter!( ax, points, color=:blue) #, overdraw=true )

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