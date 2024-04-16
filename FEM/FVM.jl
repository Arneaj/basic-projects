using GLMakie
using Meshes

#const g = CartesianGrid(100,100)
#const grid = collect( elements(g) )

# 1D

f_burgers( U::Vector{Float64} ) = 1/2 * U.^2

G_1D( f, U::Vector{Float64}, Up::Vector{Float64}, c, dx, dt ) = 1/2 * c * ( f(U)+f(Up) )

G_LW_1D( f, U::Vector{Float64}, Up::Vector{Float64}, c, dx, dt ) = 1/2 * c * ( f(U)+f(Up) ) - c^2*dt/(2*dx) * (f(Up)-f(U))

function next_U( f, G, U::Vector{Float64}, dx::Float64, dt::Float64, c::Float64 )
    n = length( U )
    Up = zeros( n )
    Um = zeros( n )

    Up[2:n] = U[1:n-1]
    Up[1] = 1

    Um[1:n-1] = U[2:n]
    Um[n] = 1

    return U - c*dt/dx * ( G(f, U, Up, c, dx, dt)-G(f, Um, U, c, dx, dt) )
end

function one_d( dx=0.005, x_max=1, dt=0.01, t_max=10, c=0.5 )
    X::Vector{Float64} = 0:dx:x_max
    T::Vector{Float64} = 0:dt:t_max

    n_x::Int64 = length( X )
    n_t::Int64 = length( T )

    U::Array{Float64} = zeros( (n_t, n_x) )

    U0::Vector{Float64} = exp(1).^(-((X.-x_max/2)*5).^2)

    U[1, :] = U0

    for i_t in 2:n_t
        U[i_t, :] = next_U( f_burgers, G_LW_1D, U[i_t-1, :], dx, dt, c )
    end

    fig = Figure()
    ax = Axis( fig[1,1] )

    obs_U = Observable( U[1, :] )
    plot = lines!( ax, X, obs_U )

    display( fig )

    for i_t in 2:n_t
        sleep(dt)
        
        obs_U[] = U[i_t, :]
    end

end

one_d()










#viz(grid, showfacets=true)
