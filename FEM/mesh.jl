using LinearAlgebra
using GLMakie, ImageCore, Colors

### caractéristiques physiques

global const conduc = 230
global const chal_spe = 880
global const rho = 2.7e3
global const young = 69e9
global const poisson = 0.346

### functions

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

function AB( points, triangle )
    return points[triangle[2]]-points[triangle[1]]
end

function AC( points, triangle )
    return points[triangle[3]]-points[triangle[1]]
end

function BC( points, triangle )
    return points[triangle[3]]-points[triangle[2]]
end

function triangle_surface( points, triangle )
    return norm( cross(AB(points, triangle), AC(points, triangle)) ) / 2
end

function A_K( points, triangle, K )
    mult = conduc / (4 * K) 

    A = zeros( Float64, 3, 3 )

    A[1, 1] = norm( BC(points, triangle) )^2
    A[1, 2] = dot( BC(points, triangle), -AC(points, triangle) )
    A[1, 3] = dot( BC(points, triangle), AB(points, triangle) )

    A[2, 1] = A[1, 2]
    A[2, 2] = norm( AC(points, triangle) )^2
    A[2, 3] = dot( -AC(points, triangle), AB(points, triangle) )

    A[3, 1] = A[1, 3]
    A[3, 2] = A[2, 3]
    A[3, 3] = norm( AB(points, triangle) )^2

    return mult * A
end

function A( points, triangles, K, N_points, N_triangles )
    AA = [ A_K( points, triangles[i, :], K ) for i in 1:N_triangles ]

    global_A = zeros( Float64, N_points, N_points )

    for i in 1:N_triangles
        global_A[ triangles[i,:], triangles[i,:] ] += AA[i]
    end

    return global_A
end

function L_K( triangle, K, F )
    mult = K / 12

    L = zeros( Float64, 3 )

    L[1] = 2*F[triangle[1]] + F[triangle[2]] + F[triangle[3]]
    L[2] = F[triangle[1]] + 2*F[triangle[2]] + F[triangle[3]]
    L[3] = F[triangle[1]] + F[triangle[2]] + 2*F[triangle[3]]

    return mult * L
end

function L( triangles, K, N_points, N_triangles, F )
    LL = [ L_K( triangles[i, :], K, F ) for i in 1:N_triangles ]

    global_L = zeros( Float64, N_points )

    for i in 1:N_triangles
        global_L[ triangles[i,:] ] += LL[i]
    end

    return global_L
end

function M_K( K )
    mult = rho * chal_spe * K / 12

    M = [ 2 1 1; 1 2 1; 1 1 2 ]

    return mult * M
end

function M( triangles, K, N_points, N_triangles )
    MM = [ M_K( K ) for i in 1:N_triangles ]

    global_M = zeros( Float64, N_points, N_points )

    for i in 1:N_triangles
        global_M[ triangles[i,:], triangles[i,:] ] += MM[i]
    end

    return global_M
end

function find_intersec( ax, intersec )
    inv_view_proj = inv(camera(ax.scene).projectionview[])
    area = viewport(ax.scene)[]
    xy = ax.scene.events.mouseposition[]

    mp = 2f0 .* xy ./ widths(area) .- 1f0

    ### SHITTY CORRECTION
    mp = mp - [ 0.05, 0.05 ]

    v = inv_view_proj * [0, 0, -10, 1]
    reversed = v[3] < v[4]
    near = reversed ? 1f0 - 1e-6 : 0f0
    far = reversed ? 0f0 : 1f0 - 1e-6

    origin = inv_view_proj * [mp[1], mp[2], near, 1f0]
    origin = origin[1:3] ./ origin[4]

    p = inv_view_proj * [mp[1], mp[2], far, 1f0]
    p = p[1:3] ./ p[4]

    dir = normalize(p .- origin)

    mins = ([-1.0, -1.0, -0.1] - origin) ./ dir
    maxs = ([1.0, 1.0, 0.0] - origin) ./ dir
    x, y, z = min.(mins, maxs)
    possible_hit = max(x, y, z)
    if possible_hit < minimum(max.(mins, maxs))
        intersec = origin + possible_hit * dir
    end

    return intersec
end

function main()

    ### maillage

    resolution = 16

    points, triangles = mesh_plane( resolution )

    N_points = resolution^2 + (resolution-1)^2
    N_triangles = 4*(resolution-1)^2
    @show N_points
    @show N_triangles

    K = triangle_surface( points, triangles[1, :] )

    ### propriétés physiques

    intersec = Observable( Point3f(0,0,0) )

    bit_vec = @lift( norm.( points .- $intersec ) .< 0.2 )

    F_points = @lift( $bit_vec * 30 / K )
    #F_points = zeros( Float64, N_points )
    #F_points[ (resolution^2 + resolution) ÷ 2 ] = 10e3

    ### matrices

    global_A = A( points, triangles, K, N_points, N_triangles )
    global_L = @lift( L( triangles, K, N_points, N_triangles, $F_points ) )
    global_M = M( triangles, K, N_points, N_triangles )

    global_A_corrected = global_A #copy( global_A )
    global_L_corrected = global_L #copy( global_L )

    for i in 1:resolution
        global_A_corrected[i, :] = zeros( Float64, N_points )
        global_A_corrected[:, i] = zeros( Float64, N_points )
        global_A_corrected[i, i] = 1

        global_A_corrected[resolution^2 + 1 - i, :] = zeros( Float64, N_points )
        global_A_corrected[:, resolution^2 + 1 - i] = zeros( Float64, N_points )
        global_A_corrected[resolution^2 + 1 - i, resolution^2 + 1 - i] = 1

        global_A_corrected[resolution*(i-1) + 1, :] = zeros( Float64, N_points )
        global_A_corrected[:, resolution*(i-1) + 1] = zeros( Float64, N_points )
        global_A_corrected[resolution*(i-1) + 1, resolution*(i-1) + 1] = 1

        global_A_corrected[resolution*(i-1) + resolution, :] = zeros( Float64, N_points )
        global_A_corrected[:, resolution*(i-1) + resolution] = zeros( Float64, N_points )
        global_A_corrected[resolution*(i-1) + resolution, resolution*(i-1) + resolution] = 1

        global_L_corrected[][i] = 0
        global_L_corrected[][resolution^2 + 1 - i] = 0
        global_L_corrected[][resolution*(i-1) + 1] = 0
        global_L_corrected[][resolution*(i-1) + resolution] = 0
    end

    ### solve

    #U = inv( global_A_corrected ) * global_L_corrected

    #for i in 1:N_points
    #    points[i] += Point3f(0, 0, U[i])
    #end 

    ### plot

    fig = Figure()
    ax = LScene( fig[1,1] )

    display( fig )

    dt = 10
    obs_points = Observable( points )
    U = Observable( zeros(Float64, N_points) )

    mesh!( ax, obs_points, triangles, color=U )

    #meshscatter!( ax, intersec )

    while events(ax.scene).window_open[]
        U[] = inv(global_M/dt + global_A_corrected/2) * ( (global_M/dt - global_A_corrected/2) * U[] + global_L_corrected[] )

        obs_points[] = points .+ Point3f.(0, 0, U[])

        intersec[] = find_intersec( ax, intersec[] )

        notify(U)
        notify(obs_points)

        sleep(0.05)
    end

    return 
end







