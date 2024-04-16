module MapSandbox

using CoherentNoise
using .Threads
using GLMakie, ImageCore, Colors
using LinearAlgebra

println("done importing packages")

global const dim::Int64 = 256
global const shape = ( dim, dim )

global const DEEP_WATER = RGB{Float64}(25.0/255,105.0/255,176.0/255)
global const WATER = RGB{Float64}(35.0/255,137.0/255,218.0/255)
global const BEACH = RGB{Float64}(194.0/255, 178.0/255, 128.0/255)
global const GRASS = RGB{Float64}(80.0/255, 120.0/255, 10.0/255)
global const FOREST = RGB{Float64}(36.0/255, 52.0/255, 7.0/255)
global const ROCKS = RGB{Float64}(146.0/255, 142.0/255, 133.0/255)
global const SNOW = RGB{Float64}(255.0/255, 250.0/255, 250.0/255)

## main functions

function biome(height,
            deep_water_level=0.01,
            water_level=0.1,
            beach_level=0.15,
            grass_level=0.3,
            forest_level=0.5,
            rocks_level=1.2)
    
    if height < deep_water_level return DEEP_WATER end
    if height < water_level return WATER end
    if height < beach_level return BEACH end
    if height < grass_level return GRASS end
    if height < forest_level return FOREST end
    if height < rocks_level return ROCKS end
    return SNOW
end

function color_map(some_height_map, some_dim=dim)
    colored_world = Array{RGB{Float64}}(undef, (some_dim, some_dim))
    
    for x in (1:some_dim)
        for y in (1:some_dim)
            colored_world[x,y] = biome( some_height_map[x,y] )
        end
    end
    
    return colored_world
end

function color_map_advanced(some_height_map, k_x::Float64, k_y::Float64, c::Float64, t, some_dim=dim)
    colored_world = Array{RGB{Float64}}(undef, (some_dim, some_dim))
    
    for x in (1:some_dim)
        for y in (1:some_dim)
            colored_world[x,y] = biome( some_height_map[x,y], 0., (0.1+0.02*sin(k_x*x + k_y*y - c*t)) )
        end
    end
    
    return colored_world
end  

function diagonal(xL, yL, 
                xP, yP, 
                dl, maxl = 1)

    lamb_list::Array{Float64} = dl:dl:maxl

    pos_list::Array{Int64} = zeros((size(lamb_list)[1], 2))

    for i in 1:size(lamb_list)[1]
        xi = round(lamb_list[i]*(xL-xP) + xP)
        yi = round(lamb_list[i]*(yL-yP) + yP)

        if xi >= 1 && yi >= 1 && xi <= dim && yi <= dim
            pos_list[i,1] = xi
            pos_list[i,2] = yi
        else 
            pos_list[i,1] = xP
            pos_list[i,2] = yP
        end

    end

    pos_list = unique(pos_list, dims=0)

    return pos_list
end   

function dP(xP, yP, 
            x, y, some_dim=dim)
    return sqrt((xP-x)^2 + (yP-y)^2) / some_dim
end

function shade_region_threaded_simple(some_colored_world, 
    some_height_map, 
    xL, yL, hL, dl,
    x_range, y_range)

    shaded_world = copy(some_colored_world)
    
    @threads for xP in x_range
        for yP in y_range
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
    ## end of code to be made in GLSL
    
    return shaded_world
end

function sub_shade(some_colored_world, 
                some_height_map, 
                xL, yL, hL, dl, 
                x_range,
                shaded_world,
                some_dim=dim)

    for xP in x_range
        for yP in (1:some_dim)
            if xP == xL && yP == yL continue end

            hP = some_height_map[xP,yP]
            if (hP < 0.1) continue end

            dPL = dP(xP,yP, xL,yL, some_dim)

            #maxl = (1-hP) / (hL-hP)
            maxl = (1.5-hP) / (hL-hP)

            pos_list = diagonal(xL,yL, xP,yP, dl, maxl)

            for i in (1:size(pos_list)[1]) 
                
                x = pos_list[i,1]
                y = pos_list[i,2]
                
                if (x == xP && y==yP) continue end
                
                hX = some_height_map[x, y]
                dPX = dP(xP,yP, x,y, some_dim)
                
                if (hX > hP && (hL-hP)/dPL < (hX-hP)/dPX )
                    shaded_world[xP,yP] *= 0.7
                    break
                end
            end
        end
    end  
end

function shade_threaded_better(some_colored_world, 
                    some_height_map, 
                    xL, yL, hL, dl,
                    some_dim=dim)

    shaded_world = copy(some_colored_world)

    nb_threads::Int64 = Threads.nthreads()
    nb_arrays::Int64 = round( some_dim/nb_threads )
    left_over = some_dim/nb_threads - nb_arrays
    i_ranges = reshape( (1:some_dim), (nb_arrays, nb_threads) )

    tasks = map( (1:nb_threads) ) do k
        @spawn sub_shade(some_colored_world, some_height_map, xL, yL, hL, dl, i_ranges[:,k], shaded_world, some_dim)
    end

    wait.(tasks)
    return shaded_world
end

function generate_island()
    println("running")

    sampler = opensimplex_2d(seed=nothing, smooth=true)
    frac = fbm_fractal_2d(seed=nothing,        # seed if you want reproductible results
                        source=sampler,        # source sampler
                        frequency=1.5,         # base frequency of first noise
                        octaves=10,            # number of noise freq
                        persistence=0.5,       # how quickly the amp diminishes between octaves
                        lacunarity=2.0)        # how quickly the freq increases between octaves
    
    wierd_map = gen_image( frac, w=dim, h=dim )
    
    height_map::Array{Float64} = collect( reinterpret(Float64, Gray.(wierd_map)) )
    
    d_max = 1 - (1-0.5^2) * (1-0.5^2)
    d_semi_max = 1 - (1-0.5^2)
    min_height = 1000
    max_height = -1000
    for x in (1:dim)
        for y in (1:dim)
            nx = x/dim
            ny = y/dim
            d = 1 - (1 - (nx - 0.5)^2) * (1 - (ny - 0.5)^2)
            height_map[x,y] -= (d)^(1/3) + (1+1/3)
            height_map[x,y] *= (1 - (d/(1.5*d_max))^10) 
            max_height = max(max_height, height_map[x,y])
            min_height = min(min_height, height_map[x,y])
        end
    end

    height_map = (1+1/3)*height_map .- min_height
    height_map /= ((1+1/3)*max_height - min_height)

    colored_map = color_map( height_map )

    shaded_map = shade_threaded_better( colored_map, height_map, 0, 0, 3, 0.001 )

    img = Observable( shaded_map )
    imgplot = image( img )
    
    hidedecorations!( imgplot.axis )
    display( imgplot )
    
    sleep( 30 )
end

##################

function generate_mound(radius_mound::Int64, height_mound::Float64)
    sampler_mound = opensimplex_2d(seed=nothing, smooth=true)
    frac_mound = fbm_fractal_2d(seed=nothing,        # seed if you want reproductible results
                        source=sampler_mound,        # source sampler
                        frequency=5,         # base frequency of first noise
                        octaves=4,            # number of noise freq
                        persistence=0.5,       # how quickly the amp diminishes between octaves
                        lacunarity=2.0)        # how quickly the freq increases between octaves
    
    wierd_mound = gen_image( frac_mound, w=2*radius_mound, h=2*radius_mound )

    array_mound::Array{Float64} = collect( reinterpret(Float64, Gray.(wierd_mound)) )
    array_mound = array_mound ./ 20

    for ix in (1:2*radius_mound)
        for iy in (1:2*radius_mound)
            x::Float64 = ix/radius_mound - 1
            y::Float64 = iy/radius_mound - 1

            xy_height_factor = 1 - ( x^2 + y^2 )
            array_mound[ix, iy] = max( 0, xy_height_factor ) * ( array_mound[ix, iy] + height_mound )
        end
    end

    return array_mound
end

function build_mode()
    return "build"
end

function dig_mode()
    return "dig"
end

function sun_mode()
    return "sun"
end

function generate_3d_tile(xL::Int64=0, yL::Int64=0)
    println("running")

    now = Observable( time() )

    sampler = opensimplex_2d(seed=nothing, smooth=true)
    frac = fbm_fractal_2d(seed=nothing,        # seed if you want reproductible results
                        source=sampler,        # source sampler
                        frequency=1.5,         # base frequency of first noise
                        octaves=10,            # number of noise freq
                        persistence=0.5,       # how quickly the amp diminishes between octaves
                        lacunarity=2.0)        # how quickly the freq increases between octaves
    
    weird_map = gen_image( frac, w=dim, h=dim )
    
    height_map::Array{Float64} = collect( reinterpret(Float64, Gray.(weird_map)) )

    height_map = (height_map .- 0.3)./1.1

    surface_map::Array{Float64} = zeros(dim, dim)

    for x in (1:dim), y in (1:dim)     
        surface_map[x,y] = max( height_map[x,y], 0.1 )
    end

    colored_map = color_map_advanced( height_map, 2. / dim, 2. / dim, 1., now[] )

    shaded_map = shade_threaded_better( colored_map, height_map, xL, yL, 3, 0.001 )

    srf = Observable( surface_map )
    img = Observable( shaded_map )

    fig = Figure()
    ax1 = Axis3( fig[1,1], aspect=(10,10,1) )
    srfplot = surface!( ax1, srf, color=img, shading=NoShading )

    hidedecorations!( ax1 )

    display( fig )

end

function generate_tile_sandbox_gui(xL::Int64=0, yL::Int64=0)
    println("running")

    now = Observable( time() )

    current_xL = Observable( xL )
    current_yL = Observable( yL )

    sampler = opensimplex_2d(seed=nothing, smooth=true)
    frac = fbm_fractal_2d(seed=nothing,        # seed if you want reproductible results
                        source=sampler,        # source sampler
                        frequency=1.5,         # base frequency of first noise
                        octaves=10,            # number of noise freq
                        persistence=0.5,       # how quickly the amp diminishes between octaves
                        lacunarity=2.0)        # how quickly the freq increases between octaves
    
    
    weird_map = gen_image( frac, w=dim, h=dim )    
    height_map::Array{Float64} = collect( reinterpret(Float64, Gray.(weird_map)) )
    height_map = (height_map .- 0.3)./1.1

    colored_map = color_map_advanced( height_map, 2. / dim, 2. / dim, 0.5, now[] )
    shaded_map = shade_threaded_better( colored_map, height_map, current_xL[], current_yL[], 3, 0.001 )

    srf = Observable( height_map )
    img = Observable( shaded_map )

    fig = Figure( size = (900, 400) )

    ax1 = Axis( fig[1,1], aspect=AxisAspect(1), width=400 )
    imgplot = image!( ax1, img, fxaa=false )

    hidedecorations!( ax1 )

    deactivate_interaction!( ax1, :rectanglezoom )
    
    funcs = [ build_mode, dig_mode, sun_mode ]
    labels = [ "Build", "Dig", "Sun" ]

    menu = Menu( fig, options = zip(labels, funcs) )
    
    current_mode::String = "build"
    current_radius::Int64 = round( dim/20 )
    current_height::Float64 = 0.03

    max_sl_height = 0.1
    max_sl_radius = 20
    
    sl_height = Slider( fig, range = 0:0.001:max_sl_height, startvalue = 0.03 )
    sl_radius = Slider( fig, range = 0:1:max_sl_radius, startvalue = round(dim/20) )

    sub_fig = GridLayout()

    sub_fig[1,1] = vgrid!( menu,
                        Label(fig, "Brush height : ", width = nothing), sl_height, 
                        Label(fig, "Brush radius : ", width = nothing), sl_radius,
                        tellheight = false, width = 100 )

    radius_ratio = max_sl_radius * 4
    sub_fig[2,1] = ax2 = Axis( fig, aspect=AxisAspect(1), 
                                limits=(-radius_ratio, radius_ratio, -radius_ratio, radius_ratio),
                                width = 100 )
    

    arc = arc!( (0,0), sl_radius.value, -π, π)

    deactivate_interaction!( ax2, :rectanglezoom )
    hidedecorations!( ax2 )
    
    fig[1,2] = sub_fig
    
    ax3 = Axis3( fig[1, 3], aspect=(10,10,1), perspectiveness=1., width=400 )
    srfplot = surface!( ax3, srf, color=img, shading=NoShading )

    hidedecorations!( ax3 )
    
    colsize!(fig.layout, 1, Relative(2/5))
    colsize!(fig.layout, 2, Relative(1/5))
    colsize!(fig.layout, 3, Relative(2/5))
    
    on(menu.selection) do selected_func
        current_mode = selected_func()
    end    
    
    on(sl_height.value) do height
        current_height = height
    end

    on(sl_radius.value) do radius
        current_radius = radius
    end
    
    on(events(ax1.scene).mouseposition) do event
        now[] = time()
        
        mb = events( ax1.scene ).mousebutton[]

        if (mb.button == Mouse.left || mb.button == Mouse.right) && (mb.action == Mouse.press || mb.action == Mouse.repeat)
            mouse_pos = Makie.mouseposition( ax1.scene )
            xM::Int64 = round( mouse_pos[1] )
            yM::Int64 = round( mouse_pos[2] )

            radius_mound = current_radius
            height_mound = current_height
            array_mound = generate_mound( radius_mound, height_mound )

            x_range = max(1, 1+xM-radius_mound):min(dim, xM+radius_mound)
            y_range = max(1, 1+yM-radius_mound):min(dim, yM+radius_mound)

            oob_left = 1+xM-radius_mound - max(1, 1+xM-radius_mound)
            oob_right = xM+radius_mound - min(dim, xM+radius_mound)

            oob_bottom = 1+yM-radius_mound - max(1, 1+yM-radius_mound)
            oob_top = yM+radius_mound - min(dim, yM+radius_mound)

            x_range_mound = (1-oob_left):(2*radius_mound-oob_right)
            y_range_mound = (1-oob_bottom):(2*radius_mound-oob_top)

            if current_mode == "build"
                height_map[x_range, y_range] += array_mound[x_range_mound, y_range_mound]
            end
            if current_mode == "dig"
                height_map[x_range, y_range] -= array_mound[x_range_mound, y_range_mound]
            end
            if current_mode == "sun"
                current_xL[] = xM
                current_yL[] = yM
            end

            #x_range_shade = 1+xM-5*radius_mound:xM+5*radius_mound
            #y_range_shade = 1+yM-5*radius_mound:yM+5*radius_mound

            colored_map = color_map( height_map )
            shaded_map = shade_threaded_better( colored_map, height_map, current_xL[], current_yL[], 3, 0.001 )
            #shaded_map[x_range, y_range] = shaded_zone[x_range, y_range]

            img[] = shaded_map
            srf[] = height_map
        end
    end
    
    display( fig )
end

function generate_tile_sandbox(xL::Int64=0, yL::Int64=0)
    println("running")

    sampler = opensimplex_2d(seed=nothing, smooth=true)
    frac = fbm_fractal_2d(seed=nothing,        # seed if you want reproductible results
                        source=sampler,        # source sampler
                        frequency=1.5,         # base frequency of first noise
                        octaves=10,            # number of noise freq
                        persistence=0.5,       # how quickly the amp diminishes between octaves
                        lacunarity=2.0)        # how quickly the freq increases between octaves
    
    
    weird_map = gen_image( frac, w=dim, h=dim )    
    height_map::Array{Float64} = collect( reinterpret(Float64, Gray.(weird_map)) )
    height_map = (height_map .- 0.3)./1.1

    colored_map = color_map( height_map )
    shaded_map = shade_threaded_better( colored_map, height_map, xL, yL, 3, 0.001 )

    srf = Observable( height_map )
    img = Observable( shaded_map )

    fig = Figure( size = (900, 400) )

    ax1 = Axis( fig[1,1], aspect=AxisAspect(1) )
    imgplot = image!( ax1, img, fxaa=false )

    hidedecorations!( ax1 )

    deactivate_interaction!( ax1, :rectanglezoom )
    
    current_mode::String = "build"
    current_radius::Int64 = round( dim/20 )
    current_height::Float64 = 0.03

    max_sl_height = 0.1
    max_sl_radius = 20
    
    ax3 = Axis3( fig[1, 2], aspect=(10,10,1), perspectiveness=1. )
    srfplot = surface!( ax3, srf, color=img, shading=NoShading )

    hidedecorations!( ax3 )
    
    on(events(ax1.scene).mouseposition) do event
        mb = events(ax1.scene).mousebutton[]

        if (mb.button == Mouse.left || mb.button == Mouse.right) && (mb.action == Mouse.press || mb.action == Mouse.repeat)
            mouse_pos = Makie.mouseposition( ax1.scene )
            xM::Int64 = round( mouse_pos[1] )
            yM::Int64 = round( mouse_pos[2] )

            radius_mound = current_radius
            height_mound = current_height
            array_mound = generate_mound( radius_mound, height_mound )

            x_range = max(1, 1+xM-radius_mound):min(dim, xM+radius_mound)
            y_range = max(1, 1+yM-radius_mound):min(dim, yM+radius_mound)

            oob_left = 1+xM-radius_mound - max(1, 1+xM-radius_mound)
            oob_right = xM+radius_mound - min(dim, xM+radius_mound)

            oob_bottom = 1+yM-radius_mound - max(1, 1+yM-radius_mound)
            oob_top = yM+radius_mound - min(dim, yM+radius_mound)

            x_range_mound = (1-oob_left):(2*radius_mound-oob_right)
            y_range_mound = (1-oob_bottom):(2*radius_mound-oob_top)

            if current_mode == "build"
                height_map[x_range, y_range] += array_mound[x_range_mound, y_range_mound]
            end
            if current_mode == "dig"
                height_map[x_range, y_range] -= array_mound[x_range_mound, y_range_mound]
            end

            #x_range_shade = 1+xM-5*radius_mound:xM+5*radius_mound
            #y_range_shade = 1+yM-5*radius_mound:yM+5*radius_mound

            colored_map = color_map( height_map )
            shaded_map = shade_threaded_better( colored_map, height_map, xL, yL, 3, 0.001 )
            #shaded_map[x_range, y_range] = shaded_zone[x_range, y_range]

            img[] = shaded_map
            srf[] = height_map
        end
    end
    
    display( fig )
end

#############

function generate_and_disp_cloud( cloud_avg_size, voxel_size )
    n = rand( 13:17 )
    r1 = rand( 0.8:0.1:1.2 ) * cloud_avg_size
    radii = [ r1 * 0.9^k for k in 1:n ]

    X0 = randn( Float32, (3,n) )*0.6*cloud_avg_size
    X0[1,:] = [ X0[1,k]-0.2*cloud_avg_size*k for k in 1:n ]

    A = rand( Float32, (3,n) )
    A[1,:] = 0.5*A[1,:].+0.5
    A[2,:] = 0.2*A[1,:].+0.8
    A[3,:] = 0.2*A[1,:].+0.8
    sqrt_one_over_minA = sqrt(1/minimum(A))

    X0[3,:] = radii[:] ./ sqrt.(A[3,:]) #max.(X0[3,:], 1 ./ A[3,:])

    min_x, max_x = extrema( X0[1,:] )
    min_y, max_y = extrema( X0[2,:] )
    min_z, max_z = extrema( X0[3,:] )

    max_x, max_y, max_z = (max_x, max_y, max_z) .+ r1 * sqrt_one_over_minA
    min_x, min_y, min_z = (min_x, min_y, min_z) .- r1 * sqrt_one_over_minA

    X = min_x:voxel_size:max_x
    Y = min_y:voxel_size:max_y
    Z = min_z:voxel_size:max_z

    Voxels::Vector{Point3f} = []
    for x in X, y in Y, z in Z
        is_in = false
        for k in 1:n
            if (A[1,k]*(x-X0[1,k])^2 + A[2,k]*(y-X0[2,k])^2 + A[3,k]*(z-X0[3,k])^2 <= radii[k]^2)
                is_in = true
                break
            end
        end
        if is_in push!( Voxels, Point3f(x, y, z) ) end
    end

    fig = Figure()
    ax = Axis3( fig[1,1], aspect=:data )
    meshscatter!( ax, Voxels, color=:white, marker=Rect3(Point3f(-0.5), Vec3f(1)), markersize=voxel_size )
    
    display( fig )
end

function generate_cloud( cloud_avg_size, voxel_size )
    n = rand( 13:17 )
    r1 = rand( 0.8:0.1:1.2 ) * cloud_avg_size
    radii = [ r1 * 0.9^k for k in 1:n ]

    X0 = randn( Float32, (3,n) )*0.6*cloud_avg_size
    X0[1,:] = [ X0[1,k]-0.2*cloud_avg_size*k for k in 1:n ]

    A = rand( Float32, (3,n) )
    A[1,:] = 0.5*A[1,:].+0.5
    A[2,:] = 0.2*A[1,:].+0.8
    A[3,:] = 0.2*A[1,:].+0.8
    sqrt_one_over_minA = sqrt(1/minimum(A))

    X0[3,:] = radii[:] ./ sqrt.(A[3,:]) #max.(X0[3,:], radii[:] ./ A[3,:])

    min_x, max_x = extrema( X0[1,:] )
    min_y, max_y = extrema( X0[2,:] )
    min_z, max_z = extrema( X0[3,:] )

    max_x, max_y, max_z = (max_x, max_y, max_z) .+ r1 * sqrt_one_over_minA
    min_x, min_y, min_z = (min_x, min_y, min_z) .- r1 * sqrt_one_over_minA

    X = min_x:voxel_size:max_x
    Y = min_y:voxel_size:max_y
    Z = min_z:voxel_size:max_z

    Voxels::Vector{Point3f} = []
    for x in X, y in Y, z in Z
        is_in = false
        for k in 1:n
            if (A[1,k]*(x-X0[1,k])^2 + A[2,k]*(y-X0[2,k])^2 + A[3,k]*(z-X0[3,k])^2 <= radii[k]^2)
                is_in = true
                break
            end
        end
        if is_in push!( Voxels, Point3f(x, y, z) ) end
    end

    return Voxels
end

function real_time_water_clouds(xL::Int64=0, yL::Int64=0)
    println("running")

    current_xL = Observable( xL )
    current_yL = Observable( yL )

    sampler = opensimplex_2d(seed=nothing, smooth=true)
    frac = fbm_fractal_2d(seed=nothing,        # seed if you want reproductible results
                        source=sampler,        # source sampler
                        frequency=1.5,         # base frequency of first noise 1.5
                        octaves=10,            # number of noise freq
                        persistence=0.5,       # how quickly the amp diminishes between octaves 0.5
                        lacunarity=2.0)        # how quickly the freq increases between octaves 2.0
    
    
    weird_map = gen_image( frac, w=dim, h=dim )    
    height_map::Array{Float64} = collect( reinterpret(Float64, Gray.(weird_map)) )
    height_map = (height_map .- 0.3)./0.9    # 0.3, 1.1
    apparent_height_map = map( h->max(h,0.1), height_map )
    apparent_height_map = apparent_height_map .* dim*0.12

    #colored_map = color_map_advanced( height_map, 2. / dim, 2. / dim, 0.1, time() )
    colored_map = color_map( height_map )
    shaded_map = shade_threaded_better( colored_map, height_map, current_xL[], current_yL[], 3, 0.001 )

    srf = Observable( apparent_height_map )
    img = Observable( shaded_map )

    fig = Figure()

    ax3 = LScene( fig[1,1], show_axis=false )

    surface!( ax3, srf, color=img, shading=NoShading, fxaa=false )

    voxel_size = 0.01 * dim
    v_cloud = 0.001 * dim
    nb_clouds = 10

    clouds::Vector{Point3f} = []
    for _ in 1:nb_clouds
        push!( clouds, (generate_cloud( 0.02*dim*(1 + rand()), voxel_size ).+ Point3f( dim*rand(), dim*rand(), 0.05*dim*(1+rand()) ))... )
    end
    #clouds = [ Point3f(voxel[1], voxel[2], voxel[3] * 0.5) for voxel in clouds ]
    clouds_obs = Observable( clouds )

    meshscatter!( ax3, clouds_obs, color=:white, 
                  marker=Rect3(Point3f(-0.5), Vec3f(1)), markersize=voxel_size )

    display( fig )

    t0 = time()
    while true
        #colored_map = color_map_advanced( height_map, 2. / dim, 2. / dim, 0.05, time()-t0 )
        #shaded_map = shade_threaded_better( colored_map, height_map, current_xL[], current_yL[], 3, 0.001 )

        clouds_obs[] = clouds_obs[] .+ Point3f( v_cloud, 0.0, 0.0 )
        
        for k in 1:length(clouds)
            if (clouds_obs[][k][1] > dim) clouds_obs[][k] -= Point3f( dim, 0.0, 0.0) end
            if (clouds_obs[][k][1] < 0) clouds_obs[][k] += Point3f( dim, 0.0, 0.0) end
        end

        #img[] = shaded_map
        sleep(0.01)
    end

    return
end

function get_height( point::Point3f )
    return point[3]
end

function set_height( point::Point3f, height::Float64 )
    return Point3f( point[1], point[2], height )
end

get_x( point::Point3f ) = point[1]

get_xy( point::Point3f ) = [ point[1], point[2] ]

indice( vec_xy ) = vec_xy[2] + dim*(vec_xy[1] - 1)

round_vec( vec ) = Int64.(round.(vec))

function real_time_water_clouds_blocky(xL::Int64=0, yL::Int64=0)
    println("running")

    current_xL = Observable( xL )
    current_yL = Observable( yL )

    sampler = opensimplex_2d(seed=nothing, smooth=true)
    frac = fbm_fractal_2d(seed=nothing,        # seed if you want reproductible results
                        source=sampler,        # source sampler
                        frequency=1.5,         # base frequency of first noise 1.5
                        octaves=10,            # number of noise freq
                        persistence=0.5,       # how quickly the amp diminishes between octaves 0.5
                        lacunarity=2.0)        # how quickly the freq increases between octaves 2.0
    
    
    weird_map = gen_image( frac, w=dim, h=dim )    
    height_map::Array{Float64} = collect( reinterpret(Float64, Gray.(weird_map)) )
    height_map = (height_map .- 0.3)./0.9    # 0.3, 1.1
    apparent_height_map = height_map #map( h->max(h,0.1), height_map )
    apparent_height_map = apparent_height_map .* dim*0.12  #0.12

    #colored_map = color_map_advanced( height_map, 2. / dim, 2. / dim, 0.1, time() )
    colored_map = color_map( height_map )
    shaded_map = shade_threaded_better( colored_map, height_map, current_xL[], current_yL[], 2, 0.001 )

    ground_voxels::Vector{Point3f} = []
    for ix in 1:dim, iy in 1:dim
        push!( ground_voxels, Point3f( ix, iy, apparent_height_map[ix, iy] ) )
    end

    voxel_colors::Vector{RGB{Float64}} = []
    for ix in 1:dim, iy in 1:dim
        push!( voxel_colors, shaded_map[ix, iy] )
    end

    srf = Observable( ground_voxels )
    img = Observable( voxel_colors )

    fig = Figure()

    ax3 = LScene( fig[1,1], show_axis=false )
    
    meshscatter!( ax3, srf, color=img, 
                  marker=Rect3(Point3f(-0.5), Vec3f(1, 1, 2)), markersize=1, shading=NoShading )
    
    voxel_size = 0.007 * dim
    v_cloud = 0.01 * dim
    nb_clouds = 10

    clouds::Vector{Point3f} = []
    cloud_colors::Vector{RGB{Float64}} = []
    for _ in 1:nb_clouds
        cloud_size = 0.02*dim*(1 + rand())

        cloud = generate_cloud( cloud_size, voxel_size )
        cloud_color = [ RGB( 0.5 + (0.5*cloud_voxel[3]/cloud_size)^2 + 0.1*norm(cloud_voxel, 5)/(cloud_size) ) for cloud_voxel in cloud ] #- norm(cloud_voxel-Point3f(0,0,cloud_size), 5)/(8*cloud_size)

        cloud = cloud .+ Point3f( dim*rand(), dim*rand(), 0.05*dim*(1+rand()) )

        push!( clouds, cloud... )
        push!( cloud_colors, cloud_color... )
    end
    clouds_obs = Observable( clouds )

    meshscatter!( ax3, clouds_obs, color=cloud_colors, 
                  marker=Rect3(Point3f(-0.5), Vec3f(1)), markersize=voxel_size, 
                  shading=NoShading)

    display( fig )

    heights = get_height.( ground_voxels )
    to_change = ( heights .<= (0.12 * dim * 0.12) ) #.&& ( heights .>= (0.07 * dim * 0.12) )
    to_change_color = to_change .&& ( heights .>= (0.08 * dim * 0.12) )

    t0 = time()
    t = t0
    while events(ax3.scene).window_open[]

        clouds_obs[] .+= Point3f( v_cloud*(time()-t), 0.0, 0.0 )

        oob_over = get_x.(clouds_obs[]) .> dim
        oob_under = get_x.(clouds_obs[]) .< 1

        clouds_obs[][oob_over] .-= Point3f( dim, 0.0, 0.0)
        clouds_obs[][oob_under] .+= Point3f( dim, 0.0, 0.0)

        notify( clouds_obs )

        water_height = 0.1 * ( 1 + 0.2*sin(0.5*(time()-t0)) )

        srf[][to_change] = set_height.( ground_voxels[to_change], max.( heights[to_change], water_height*dim*0.12 ) )

        notify( srf )

        under_water = heights .<= water_height*dim*0.12
        over_water = .!under_water

        img[][to_change_color .&& under_water] .= WATER
        img[][to_change_color .&& over_water] .= BEACH * 0.7

        notify( img )        

        t = time()
        sleep(0.01)
    end

    return
end
    


end #module 
