using GLMakie, ImageCore

mutable struct Tile
    type::Enum
    color::RGB{Float64}
    probabilities::Vector{Float32}
end

@enum Tile_type begin
    empty
    grass
    rock
    sand
    water
    deep_water
end

global const Tiles = [ 
                       Tile( grass, RGB{Float64}(65.0/255, 152.0/255, 10.0/255), [0.97, 0.01, 0.01, 0.01, 0] ),
                       Tile( rock, RGB{Float64}(101.0/255, 83.0/255, 83.0/255), [0.05, 0.9, 0.05, 0, 0] ),
                       Tile( sand, RGB{Float64}(194.0/255, 178.0/255, 128.0/255), [0.01, 0.01, 0.95, 0.3, 0] ),
                       Tile( water, RGB{Float64}(35.0/255, 137.0/255, 218.0/255), [0.01, 0, 0.01, 0.93, 0.05] ),
                       Tile( deep_water, RGB{Float64}(15.0/255, 94.0/255, 156.0/255), [0, 0, 0, 0.05, 0.95] ) 
                     ]

global const total_nb_tiles = length(Tiles)

#################

function chose_tile( tile_type::Enum )
    r = rand( Float32 )

    t=0
    p=0

    while p < r
        t += 1
        p += Tiles[Int(tile_type)].probabilities[t]
    end

    return Tiles[t]
end


function create_tile( tiling::Array{Tile_type}, ix, iy )
    dim = size(tiling)

    adjacent_tiles = fill( 1, (3,3) )
    adjacent_tiles[2,2] = 0

    if (ix == 1) adjacent_tiles = adjacent_tiles[2:3,:] end
    if (ix == dim[1]) adjacent_tiles = adjacent_tiles[1:2,:] end
    if (iy == 1) adjacent_tiles = adjacent_tiles[:,2:3] end
    if (iy == dim[2]) adjacent_tiles = adjacent_tiles[:,1:2] end

    tiles = tiling[max(ix-1,1):min(ix+1,dim[1]), max(iy-1,1):min(iy+1,dim[2])]
    tiles = tiles[adjacent_tiles.==1]
    tiles = tiles[tiles.!=empty]

    nb_tiles = length(tiles)

    r = rand( Float32 ) * nb_tiles

    t = 0
    p = 0

    while p < r
        t += 1
        p += sum( [ Tiles[Int(tile_type)].probabilities[t] for tile_type in tiles ] )
    end

    if (t == 0) t = rand( 1:total_nb_tiles ) end

    return Tiles[t].type
end

function main()
    dim = (128,128)
    tiling = fill( empty, dim )

    for ix in 1:dim[1]
        for iy in 1:dim[2]
            tiling[ix,iy] = create_tile( tiling, ix, iy )
        end
    end

    img = map( t->Tiles[Int(t)].color, tiling )
    srf = [ Point3f( ix, iy, 0 ) for ix in 1:dim[1], iy in 1:dim[2] ]

    fig = Figure()
    #ax = Axis( fig[1,1], aspect=DataAspect() )
    #image!( ax, img, fxaa=false )

    ax = LScene( fig[1,1], show_axis=false )
    meshscatter!( ax, reshape(srf, (:)), color=reshape(img, (:)),
                  marker=Rect3(Point3f(-0.5), Vec3f(1, 1, 2)), 
                  markersize=1, shading=NoShading )

    display( fig )

    return
end

main()



