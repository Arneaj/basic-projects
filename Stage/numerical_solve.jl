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
                L_1 => 6.0e-3, L_2 => 5.0e-3, L_2p => 10.0e-3, L_3 => 3.0e-3,
                #L_1 => 6.0e-3, L_2 => 0, L_2p => 15.0e-3, L_3 => 3.0e-3,
                O_1 => Omega, O_2 => Omega, O_2p => Omega, O_3 => Omega,
                E_1 => 2.25e9, E_2 => 2.25e9, E_2p => 2.25e9, E_3 => 2.25e9,
                S_1 => 1.1e-6, S_2 => 0.1e-6, S_2p => 0.1e-6, S_3 => 0.7e-6,
                #delta => 2, epsilon => 0.5, eta => etaa, mu => muu
            ])
        )
    )

    d_eta_mu = 0.1

    ETA = -1:d_eta_mu:1
    #push!( ETA, -1:d_eta_mu:-d_eta_mu... )
    #push!( ETA, d_eta_mu:d_eta_mu:1... )

    MU = -1:d_eta_mu:1
    #push!( MU, -1:d_eta_mu:-d_eta_mu... )
    #push!( MU, d_eta_mu:d_eta_mu:1... )

    HEHEHE = Array{Vector{Float64}}( undef, (length(ETA), length(MU)) )

    OOmega = 0.000001:1:4000

    for etaa_i in 1:length(ETA), muu_i in 1:length(MU)

        etaa = ETA[etaa_i]
        muu = MU[muu_i]

        if isfile( "data/eta$(etaa)_mu$(muu).txt" )
            HEHEHE[etaa_i, muu_i] = readdlm( "data/eta$(etaa)_mu$(muu).txt" )[:,1]
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
                    delta => 2, epsilon => 0.5, eta => etaa, mu => muu
                ])
            )
        )

        function blbl(Omeg::Float64)::Float64
            return Symbolics.unwrap( substitute( hehe, Dict([Omega=>Omeg]) ) )
        end

        HEHE::Vector{Float64} = [ blbl(Omeg) for Omeg in OOmega ]

        HEHEHE[etaa_i, muu_i] = HEHE

        writedlm( "data/eta$(etaa)_mu$(muu).txt", HEHE )
    end

    fig = Figure()
    ax = Axis( fig[1:4,1], aspect = AxisAspect(2), height=800 )

    toggles = [ Toggle( fig ) for i in 1:4 ]
    labels = [ L"1", L"2", L"2'", L"3" ]

    [ Label( fig[i,2], labels[i] ) for i in 1:4 ]
    
    fig[1:4, 3] = toggles

    Label( fig[0,4], L"\eta" )
    sl_eta = Slider( fig[1:4, 4], range = ETA, startvalue = 1, horizontal = false )

    Label( fig[0,5], L"\mu" )
    sl_mu = Slider( fig[1:4, 5], range = MU, startvalue = 1, horizontal = false )

    etaa_i = length(ETA)
    muu_i = length(MU)

    DET = lines!( ax, OOmega, log.(abs.(HEHEHE[etaa_i, muu_i])), color=:black )

    on( sl_eta.value ) do val
        etaa_i = findall( x->x==val, ETA )[1]

        delete!( ax, DET )

        DET = lines!( ax, OOmega, log.(abs.(HEHEHE[etaa_i, muu_i])), color=:black )
    end

    on( sl_mu.value ) do val
        muu_i = findall( x->x==val, MU )[1]

        delete!( ax, DET )

        DET = lines!( ax, OOmega, log.(abs.(HEHEHE[etaa_i, muu_i])), color=:black )
    end

    ylims!( ax, 0, 80 )

    LL = [ 6.0e-3, 5.0e-3, 10.0e-3, 3e-3 ]

    linesss = [[], [], [], []]

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
    ]

    display(fig)

    return
end


main()