using CoherentNoise
using LinearAlgebra
using GLMakie, ImageCore, Colors

global const DEEP_WATER = RGB{Float64}(25.0/255,105.0/255,176.0/255)
global const WATER = RGB{Float64}(35.0/255,137.0/255,218.0/255)
global const BEACH = RGB{Float64}(194.0/255, 178.0/255, 128.0/255)
global const GRASS = RGB{Float64}(80.0/255, 120.0/255, 10.0/255)
global const FOREST = RGB{Float64}(56.0/255, 82.0/255, 8.0/255)
global const DENSE_FOREST = RGB{Float64}(36.0/255, 52.0/255, 7.0/255)
global const ROCKS = RGB{Float64}(146.0/255, 142.0/255, 133.0/255)
global const SNOW = RGB{Float64}(255.0/255, 250.0/255, 250.0/255)

global const COLORS::Vector{RGB{Float64}} = [DEEP_WATER, WATER, BEACH, GRASS, FOREST, DENSE_FOREST, ROCKS, SNOW]

function sigmoid( x, a, b )
    return 1 / ( 1 + exp(-a*(x-b)) )
end

function height_discriminant_water( height )
    return sigmoid(height, 2, -2)
end

function height_discriminant_land( height )
    return sigmoid(height, 100, 1.3) + sigmoid(height, 10, 2.5) + sigmoid(height, 10, 4) + sigmoid(height, 10, 6) + sigmoid(height, 100, 8)
end

function biome( height )
    total_probs = zeros( 8 )

    discriminant = height_discriminant_land( 90*(height) + rand() )

    heights = 0:5

    dist = abs.( heights .- discriminant )

    probs = 1 .- dist ./ sum(dist)

    total_probs[3:8] = probs

    color::RGB{Float64} = COLORS[argmax(total_probs)] #
    
    return color
end

function biome_poles( height, point )
    if abs(point[3]) + 0.2*rand() > 1 return SNOW end

    total_probs = zeros( 8 )

    discriminant = height_discriminant_land( 90*(height) + rand() )

    heights = 0:5

    dist = abs.( heights .- discriminant )

    dist_sum = sum(dist)

    probs = 1 .- dist ./ dist_sum

    total_probs[3:8] = probs

    color::RGB{Float64} = COLORS[argmax(total_probs)] #
    
    return color
end

function mesh_plane( resolution::Int64 )
    points::Vector{Point3f} = Vector{Point3f}( undef, resolution^2 + (resolution-1)^2 )
    points[1:resolution^2] = [ Point3f(i%resolution, i÷resolution, 0) * 2/(resolution-1) - Point3f(1,1,0)  for i in 0:resolution^2-1 ]
    points[1+resolution^2:resolution^2 + (resolution-1)^2] = [ Point3f(i%(resolution-1), i÷(resolution-1), 0) * 2/(resolution-1) - Point3f(1-1/(resolution-1),1-1/(resolution-1),0)  for i in 0:(resolution-1)^2-1 ]

    triangles = zeros( Int32, 4*(resolution-1)^2, 3 )

    for x in 1:resolution-1
        for y in 1:resolution-1
            triangles[4*(x+(y-1)*(resolution-1))-3, :] = [(y-1)*resolution+x+1, resolution^2+(y-1)*(resolution-1)+x, (y-1)*resolution+x]
            triangles[4*(x+(y-1)*(resolution-1))-2, :] = [y*resolution+x, resolution^2+(y-1)*(resolution-1)+x, y*resolution+x+1]
            triangles[4*(x+(y-1)*(resolution-1))-1, :] = [(y-1)*resolution+x+1, y*resolution+x+1, resolution^2+(y-1)*(resolution-1)+x]
            triangles[4*(x+(y-1)*(resolution-1)), :] = [y*resolution+x, (y-1)*resolution+x, resolution^2+(y-1)*(resolution-1)+x]
        end
    end

    return points, triangles
end

function nice_plane( resolution::Int64 )
    points, triangles = mesh_plane( resolution )

    sampler = opensimplex_3d(seed=nothing, smooth=true)
    frac = fbm_fractal_3d(seed=nothing,        # seed if you want reproductible results
                        source=sampler,        # source sampler
                        frequency=1.5,         # base frequency of first noise 1.5
                        octaves=10,            # number of noise freq
                        persistence=0.5,       # how quickly the amp diminishes between octaves 0.5
                        lacunarity=2.0)        # how quickly the freq increases between octaves 2.0
    
    noise::Array{Float64} = [ sample( frac, p... ) for p in points ]
    noise = noise ./ 7

    points += Point3f.( 0, 0, noise )

    display( mesh( points, triangles, color=RGB(0.0, 0.3, 0.0), 
                   shininess=10.0, specular=Vec3f(0.1), ssao=true ) )

    return #points, triangles
end

function mesh_cube( resolution::Int64 )
    up, down, left, right, front, back = 1:6

    p::Vector{Vector{Point3f}} = [] 
    t::Vector{Array{Int32}} = []

    for _ in 1:6
        pp,tt = mesh_plane( resolution )
        push!( p, pp )
        push!( t, tt )
    end

    R90y = [0 0 1; 0 1 0; -1 0 0]
    Rm90y = [0 0 -1; 0 1 0; 1 0 0]
    R180y = [-1 0 0; 0 1 0; 0 0 -1]
    R90z = [1 0 0; 0 0 -1; 0 1 0]
    Rm90z = [-1 0 0; 0 0 1; 0 1 0]

    p[left] = [ Point3f(R90y * po) for po in p[left] ]
    p[right] = [ Point3f(Rm90y * po) for po in p[right] ]
    p[front] = [ Point3f(Rm90z * po) for po in p[front] ]
    p[back] = [ Point3f(R90z * po) for po in p[back] ]
    p[up] = [ Point3f(R180y * po) for po in p[up] ]

    p[up] .+= Point3f( 0,0,1 )
    p[down] .-= Point3f( 0,0,1 )
    p[left] .-= Point3f( 1,0,0 )
    p[right] .+= Point3f( 1,0,0 )
    p[front] .-= Point3f( 0,1,0 )
    p[back] .+= Point3f( 0,1,0 )

    t[down] .+= (resolution)^2 + (resolution-1)^2
    t[left] .+= 2*( (resolution)^2 + (resolution-1)^2 )
    t[right] .+= 3*( (resolution)^2 + (resolution-1)^2 )
    t[front] .+= 4*( (resolution)^2 + (resolution-1)^2 )
    t[back] .+= 5*( (resolution)^2 + (resolution-1)^2 )

    points::Vector{Point3f} = []
    #problematic_points::Vector{Int32} = []
    triangles = zeros( Int32, 6*4*(resolution-1)^2, 3 )

    for i in 1:6
        #push!( points, faces[i][1]... )
        push!( points, p[i]... )
        #push!( problematic_points, 1 )
        triangles[1+(i-1)*4*(resolution-1)^2:i*4*(resolution-1)^2, :] = t[i]
    end

    """i = 1
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
    end"""

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
    sphere_normals = normalize.( points )

    sampler = opensimplex_3d(seed=nothing, smooth=true)
    #sampler = worley_3d(seed=nothing, output=:*, metric=:minkowski4)
    frac = fbm_fractal_3d(seed=nothing,        # seed if you want reproductible results
                        source=sampler,        # source sampler
                        frequency=1.5,         # base frequency of first noise 1.5
                        octaves=10,            # number of noise freq
                        persistence=0.5,       # how quickly the amp diminishes between octaves 0.5
                        lacunarity=2.0)        # how quickly the freq increases between octaves 2.0

    noise::Array{Float64} = [ sample( frac, p... ) for p in points ]
    noise = noise ./ 7

    points += sphere_normals .* noise  
    
    color_map = biome_poles.( noise, sphere_normals )

    return points, triangles, color_map
end

function disp_mesh_grid( points, triangles, resolution, ax )
    scatter!( ax, points, color=:blue) #, overdraw=true )

    for i in 1:6*2*(resolution-1)^2
        p::Vector{Point3f} = [points[triangles[i,:]]..., points[triangles[i,1]] ]
        lines!( ax, p, color=:blue) #, overdraw=true ) 
    end
end

function main()
    t0 = time()
    resolution = 256
    points, triangles, color_map = nice_ball( resolution )
    color_map_obs = Observable( color_map )

    water_points, water_triangles = mesh_ball( resolution÷4 )

    fig = Figure()

    t = Observable( time()-t0 )
    sun_pos = @lift( Vec3f( 10*cos($t), 10*sin($t), 2*sin($t)) )
    pl = PointLight( RGBf(1.0, 1.0, 0.9), sun_pos )

    al = AmbientLight(RGBf(0.3))

    ax = LScene( fig[1,1], show_axis=false, scenekw = (lights = [pl, al], backgroundcolor=:black, clear=true) ) #Axis3( fig[1,1], aspect=:equal )

    planet = mesh!( ax, points, triangles, color=color_map_obs, interpolate=false ) 
           #shininess=0.0, specular=Vec3f(1.0), ssao=false )#, shading=NoShading )

    water = mesh!( ax, water_points, water_triangles, color=:dodgerblue4, alpha=0.8 )

    display( fig )

    while events(ax.scene).window_open[]
        t[] = time() - t0
        notify( color_map_obs )

        sleep(0.05)
    end

    return
end

return