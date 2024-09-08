using Symbolics, LinearAlgebra, Latexify, GLMakie, DelimitedFiles

function main()

    @variables O_1 O_2 O_2p O_3 L_1 L_2 L_2p L_3 epsilon delta mu eta E_1 S_1 E_2 S_2 E_2p S_2p E_3 S_3 Omega

    A = [
        1 0 0 0 0 0 -cos(O_3*L_3) -sin(O_3*L_3); 
        0 E_1*S_1*O_1*epsilon 0 0 0 0 E_3*S_3*O_3*sin(O_3*L_3) -E_3*S_3*O_3*cos(O_3*L_3); 
        cos(O_1*L_1) sin(O_1*L_1) -1 0 0 0 0 0; 
        E_1*S_1*O_1*sin(O_1*L_1) -E_1*S_1*O_1*cos(O_1*L_1) 0 E_2*S_2*O_2 0 0 0 0; 
        0 0 cos(O_2*L_2) sin(O_2*L_2) -mu 0 0 0; 
        0 0 E_2*S_2*O_2*sin(O_2*L_2) -E_2*S_2*O_2*cos(O_2*L_2) 0 E_2p*S_2p*O_2p*eta 0 0; 
        0 0 0 0 cos(O_2p*L_2p) sin(O_2p*L_2p) -1 0; 
        0 0 0 0 -E_2p*S_2p*O_2p*sin(O_2p*L_2p) E_2p*S_2p*O_2p*cos(O_2p*L_2p) 0 -E_3*S_3*O_3*delta
    ]

    heh = simplify(
        substitute(
            det(A),
            Dict([ 
                L_1 => (5.21+2.00)*1e-3, L_2 => 0.33*16.86e-3, L_2p => 0.66*16.86e-3, L_3 => 3.541e-3,
                #L_1 => 6.0e-3, L_2 => 0, L_2p => 15.0e-3, L_3 => 3.0e-3,
                O_1 => Omega, O_2 => Omega, O_2p => Omega, O_3 => Omega,
                E_1 => 2.0e3, E_2 => 2.0e3, E_2p => 2.0e3, E_3 => 2.0e3,
                S_1 => 1.40e-6, S_2 => 0.11e-6, S_2p => 0.11e-6, S_3 => 0.52e-6,
                #delta => 2, epsilon => 0.5, eta => etaa, mu => muu
            ])
        )
    )

    d_eta_mu = 0.02

    ETA = -0.1:d_eta_mu:0.1

    MU = -0.1:d_eta_mu:0.1 # [1.0] #

    HEHEHE = Array{Vector{Float64}}( undef, (length(ETA), length(MU)) )

    ZEROSSS = Array{Vector{Int}}( undef, (length(ETA), length(MU)) )

    OOmega = 0.000001:1:14000

    BASE_HEHEHE = readdlm( "data_bis_bis/eta0.0_mu0.0.txt" )[:,1]

    for etaa_i in 1:length(ETA), muu_i in 1:length(MU)

        is_defined = false

        etaa = ETA[etaa_i]
        muu = MU[muu_i]

        if isfile( "data_bis_bis/eta$(etaa)_mu$(muu).txt" )
            HEHEHE[etaa_i, muu_i] = readdlm( "data_bis_bis/eta$(etaa)_mu$(muu).txt" )[:,1]
            is_defined = true
        end

        if !isfile( "zeros_bis_bis/eta$(ETA[etaa_i])_mu$(MU[muu_i]).txt" )
            find_zeros(d_eta_mu)
        end

        ZEROSSS[etaa_i, muu_i] = readdlm( "zeros_bis_bis/eta$(ETA[etaa_i])_mu$(MU[muu_i]).txt" )[:,1]

        if is_defined 
            continue 
        end

        hehe = simplify(
            substitute(
                heh,
                Dict([ 
                    #L_1 => 6.0e-3, L_2 => 5.0e-3, L_2p => 10.0e-3, L_3 => 3.0e-3,
                    #L_1 => 6.0e-3, L_2 => 0, L_2p => 15.0e-3, L_3 => 3.0e-3,
                    #O_1 => Omega, O_2 => Omega, O_2p => Omega, O_3 => Omega,
                    #E_1 => 2.25e9, E_2 => 2.25e9, E_2p => 2.25e9, E_3 => 2.25e9,
                    #S_1 => 1.1e-6, S_2 => 0.1e-6, S_2p => 0.1e-6, S_3 => 0.7e-6,
                    delta => 0.5, epsilon => 2.0, eta => etaa, mu => muu
                ])
            )
        )

        function blbl(Omeg::Float64)::Float64
            return Symbolics.unwrap( substitute( hehe, Dict([Omega=>Omeg]) ) )
        end

        HEHE::Vector{Float64} = [ blbl(Omeg) for Omeg in OOmega ]

        HEHEHE[etaa_i, muu_i] = HEHE

        writedlm( "data_bis_bis/eta$(etaa)_mu$(muu).txt", HEHE )
    end

    ZEROSSS *= sqrt(2) / (2*pi)
    OOmega *= sqrt(2) / (2*pi)

    etaa_i = Observable( length(ETA) )
    muu_i = Observable( length(MU) )

    fig = Figure()

    ax = Axis( 
        fig[1:4,1], aspect = AxisAspect(2), height=800, 
        title=@lift(  "First 10 Natural Frequencies : " * string( round.(ZEROSSS[$etaa_i, $muu_i][2:min(end-1, 12)], digits=1 ) ) ), titlealign=:left,
        subtitle=@lift( "Total Number of Natural Frequencies : " * string( length(ZEROSSS[$etaa_i, $muu_i][2:end-1]) ) ),
        #subtitlefont = "Latin Modern",
        subtitlesize = 23,
        #titlefont = "Latin Modern",
        titlesize = 25,
        xlabel = L"f \, (Hz)",
        xlabelsize = 20,
        ylabel = L" \log( \left| \det( M_{\eta = 0, \mu = 0} ) \right| ) - \log( \left| \det( M ) \right| ) ",
        ylabelsize = 20
    )

    """toggles = [ Toggle( fig ) for i in 1:4 ]
    labels = [ L"1", L"2", L"2'", L"3" ]

    [ Label( fig[i,2], labels[i] ) for i in 1:4 ]
    
    fig[1:4, 3] = toggles"""

    Label( fig[0,2], L"\eta" )
    sl_eta = Slider( fig[1:4, 2], range = ETA, startvalue = maximum(ETA), horizontal = false )
    Box( fig[5,2], color=:white, strokevisible=false, cornerradius = 20, width = 40 )
    Label( fig[5,2], @lift("$(ETA[$etaa_i])") )

    Label( fig[0,3], L"\mu" )
    sl_mu = Slider( fig[1:4, 3], range = MU, startvalue = maximum(MU), horizontal = false )
    Box( fig[5,3], color=:white, strokevisible=false, cornerradius = 20, width = 40 )
    Label( fig[5,3], @lift("$(MU[$muu_i])") )

    DET = lines!( ax, OOmega, @lift( log.(abs.(BASE_HEHEHE)) .- log.(abs.(HEHEHE[$etaa_i, $muu_i])) .- minimum(log.(abs.(BASE_HEHEHE)) .- log.(abs.(HEHEHE[$etaa_i, $muu_i]))) ), color=:black )

    on( sl_eta.value ) do val
        etaa_i[] = findall( x->x==val, ETA )[1]
    end

    on( sl_mu.value ) do val
        muu_i[] = findall( x->x==val, MU )[1]
    end

    ylims!( ax, -2.5, 12.5 )

    LL = [ 6.0e-3, 5.0e-3, 10.0e-3, 3e-3 ]

    """linesss = [[], [], [], []]

    [
        [ 
            begin
                push!( linesss[i], lines!( ax, [k*pi / LL[i], k*pi / LL[i]], [-1e2, 1e2], color=:red, alpha=0.3 ) )
                if i == 4 
                    push!( linesss[i], lines!( ax, [(k+0.5)*pi / LL[i], (k+0.5)*pi / LL[i]], [-1e2, 1e2], color=:blue, alpha=0.3 ) )
                    #push!( linesss[i], lines!( ax, [(k+0.5637)*pi / LL[i], (k+0.5637)*pi / LL[i]], [-1e2, 1e2], color=:blue, alpha=0.3 ) )
                end
            end
            for k in 0:maximum( OOmega ) * LL[i] / pi 
        ]
        for i in 1:4
    ]

    [
        [ 
            connect!(line.visible, toggles[i].active) 
            for line in linesss[i]
        ]
        for i in 1:4
    ]"""

    display(fig)

    return
end

function find_zeros(d_eta_mu)

    ETA = -1.0:d_eta_mu:15.0

    MU = [1.0] #-1.0:d_eta_mu:1.0

    for etaa in ETA, muu in MU

        if !isfile( "data_bis_bis/eta$(etaa)_mu$(muu).txt" ) || isfile( "zeros_bis_bis/eta$(etaa)_mu$(muu).txt" )
            continue
        end

        HEHE = readdlm( "data_bis_bis/eta$(etaa)_mu$(muu).txt" )[:,1]

        zeros::Vector{Int32} = [0,0]
        for i in 2:length(HEHE)
            if sign(HEHE[i]) != sign(HEHE[i-1])
                push!( zeros, i-2 )
            end
        end

        writedlm( "zeros_bis_bis/eta$(etaa)_mu$(muu).txt", zeros )
    end
end

function rolling_avg(M, range)
    Mp = copy(M)

    for k in 1:size(M)[2]
        for i in 1+range:size(M)[1]-range
            for j in -range:range
                if j == 0 continue end
                Mp[i,k] += M[i+j,k] / abs(j)
            end
        end
    end

    return Mp
end

function plot_zeros()
    d_eta_mu = 0.1

    find_zeros(d_eta_mu)

    ETA = -1.0:d_eta_mu:1.0
    MU = -1.0:d_eta_mu:1.0 # [1.0] #

    ZEROS = Array{Vector{Float64}}( undef, (length(ETA), length(MU)) )

    for etaa_i in 1:length(ETA), muu_i in 1:length(MU)
        ZEROS[etaa_i, muu_i] = readdlm( "zeros_bis_bis/eta$(ETA[etaa_i])_mu$(MU[muu_i]).txt", Int32 )[:,1]
    end

    fig = Figure()
    ax = Axis( fig[1:4,1], aspect = AxisAspect(5), height=800 )

    Label( fig[0,2], L"\mu" )
    sl_mu = Slider( fig[1:4, 2], range = MU, startvalue = 1, horizontal = false )

    on( sl_mu.value ) do val
        muu_i[] = findall( x->x==val, MU )[1]
    end

    muu_i = Observable( length(MU) )

    zerr = @lift( ZEROS[:, $muu_i] )

    map = @lift( [
        (omega in $(zerr)[eta_i]) ? 1.0 : 0.0
        for omega in 1:14000, eta_i in 1:length(ETA)
    ] )

    map = @lift( rolling_avg( $map, 100 ) )

    #map = @lift( $map' )

    image!( ax, 1..14000, -1..1, map )

    lines!( ax, [1,14000], [0,0], color=:red )

    display(fig)

    return
end


