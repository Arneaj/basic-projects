using GLMakie, Images
using LinearAlgebra
using DelimitedFiles

function main()
    lat_max = 51.5775
    lat_min = 51.4083
    lon_max = 0.0929
    lon_min = -0.4012

    map = rotr90( load("data/rgb.png") )

    dim = size( map )
    #dlon = ( lon_max - lon_min ) / dim[1]
    #dlat = ( lat_max - lat_min ) / dim[2]

    #Lon = lon_min:dlon:lon_max
    #Lat = lat_min:dlat:lat_max

    function get_ipos( lon, lat )
        ilon::Int32 = round( dim[1] * (lon - lon_min) / (lon_max - lon_min) )
        ilat::Int32 = round( dim[2] * (lat - lat_min) / (lat_max - lat_min) )
        return Point2f(ilon, ilat)
    end

    #################### setting positions

    ICL_ipos = get_ipos( -0.1769, 51.4983 )

    Circle_line_ipos::Vector{Point2f} = []
    District_line_ipos::Vector{Point2f} = []
    Piccadilly_line_ipos::Vector{Point2f} = []

    stations = readdlm( "data/stations.csv", ',' )
    nb_rows = size(stations)[1]

    for k in 2:nb_rows
        #if stations[k, 9] > 1 end
        if occursin( "Circle", stations[k, 6] ) push!( Circle_line_ipos, get_ipos(stations[k, 9:10]...) ) end
        if occursin( "District", stations[k, 6] ) push!( District_line_ipos, get_ipos(stations[k, 9:10]...) ) end
        if occursin( "Piccadilly", stations[k, 6] ) push!( Piccadilly_line_ipos, get_ipos(stations[k, 9:10]...) ) end
    end

    #################### plot

    fig = Figure()
    ax = GLMakie.Axis( fig[1,1], aspect=DataAspect() )

    image!( ax, map )
    scatter!( ax, ICL_ipos, markersize=15, strokewidth=1.0 )
    scatter!( ax, Circle_line_ipos, markersize=10, strokewidth=0.5, alpha = 0.5 )
    scatter!( ax, District_line_ipos, markersize=10, strokewidth=0.5, alpha = 0.5 )
    scatter!( ax, Piccadilly_line_ipos, markersize=10, strokewidth=0.5, alpha = 0.5 )

    display( fig )

    return
end

main()




