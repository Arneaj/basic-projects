using GLMakie
using LinearAlgebra

global const energy = 1.602#e-19

struct Particle
    pos::Vector{Real}
    v::Vector{Real}
    q::Real
end

function Lorentz( q::Real, v::Vector{Real}, E_loc::Vector{Real}, B_loc::Vector{Real} )
    return q * ( E_loc + cross(v, B_loc) )
end

function Lorentz( particle::Particle, E::Vector{Real}, B::Vector{Real} )
    return particle.q * ( E + cross(particle.v, B) )
end

function Lorentz( particle::Particle, E::Array{Vector{Real}}, B::Array{Vector{Real}} )
    return particle.q * ( E[particle.pos] + cross(particle.v, B[particle.pos]) )
end

function create_particle_field( dx::Real, V::Vector{Real} )
    particle_field = [ Particle([x,y,z], V, energy) 
                        for x in -1:dx:1, y in -1:dx:1, z in -1:dx:1 ]

    return particle_field
end

function main()
    E::Vector{Real} = [0.0, 0.0, 0.0]
    B::Vector{Real} = [0.0, 0.0, 0.1]

    V::Vector{Real} = [10.0, 0.0, 0.0]

    particle_field = create_particle_field( 0.5, V )

    positions = [ Point3f(particle.pos...) for particle in particle_field ]
    forces = [ Lorentz( particle, E, B ) for particle in particle_field ]

    @show positions
    @show forces

    fig = Figure()
    ax = LScene( fig[1,1] )

    arrows!( ax, positions, forces, fxaa=true, # turn on anti-aliasing
                color=:white,
                linewidth = 0.1, arrowsize = Vec3f(0.3, 0.3, 0.4),
                align = :center )

    display( fig )

    return
end 

main()

return