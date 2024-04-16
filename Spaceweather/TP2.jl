using GLMakie
using DelimitedFiles
using LinearAlgebra
using .Threads

######## basic functions

### derivatives

function der_x( F::Array, dx::Float64, i, j )
    return (F[i+1,j]-F[i-1,j])/dx
end

function der_y( F::Array, dy::Float64, i, j )
    return (F[i,j+1]-F[i,j-1])/dy
end

function der_x_2( F::Array, dx::Float64, i, j )
    return (F[i+1,j]-2*F[i,j]+F[i-1,j])/dx
end

function der_y_2( F::Array, dy::Float64, i, j )
    return (F[i,j+1]-2*F[i,j]+F[i,j-1])/dy
end

### equations

function eq2_next_t( A, Bz, alpha, beta, dx, dy, dt, Nx, Ny )
    next_A = copy(A)

    for i in 2:(Nx-1)
        for j in 2:(Ny-1)
            next_A[i, j] += dt*( alpha[i,j]*Bz[i,j] + beta*(der_x_2(A, dx, i, j) + der_y_2(A, dy, i, j)) )
        end
    end

    return next_A
end

function eq3_next_t( A, Bz, V, beta, dx, dy, dt, Nx, Ny )
    next_Bz = copy(Bz)

    for i in 2:(Nx-1)
        for j in 2:(Ny-1)
            next_Bz[i, j] += dt*( der_x(V, dx, i, j)*der_y(A, dy, i, j) - der_y(V, dy, i, j)*der_x(A, dx, i, j) + beta*(der_x_2(Bz, dx, i, j)+der_y_2(Bz, dy, i, j)) )
        end
    end

    return next_Bz
end



######## main

function main()
    x_min = y_min = -1 
    x_max = y_max = 1
    dx = dy = 0.03
    Nx = Ny = Int64( round((x_max - x_min)/dx) )

    B0 = 1e4
    V0 = 15
    alpha0 = 5
    beta = 7    #dx = 0.04 => beta ~ 7.5 ?
                #dx = 0.1 => beta ~ 6
                #dx = 0.02 => beta ~ 6.9 ?

    tmax = 10
    dt = 0.5*min(dx, dy) / (V0*x_max)
    Nt = Int64( round(tmax / dt))

    A = zeros( Float32, (Nx, Ny, Nt) )
    Bz = zeros( Float32, (Nx, Ny, Nt) )
    V = zeros( Float16, (Nx, Ny) )
    alpha = zeros( Float16, (Nx, Ny) )

    @show Nt
    @show Nx

    for i in 1:Nx
        for j in 1:Ny
            x = x_min + i*dx
            y = y_min + j*dy

            V[i, j] = V0 * x * sin( pi*(y+1)/2 )
            alpha[i, j] = alpha0 * cos( pi*(y+1)/2 )

            A[i, j, 1] = (x-dx-x_min)*(x-x_max)*(y-dy-y_min)*(y-y_max)
        end
    end

    for n in 2:Nt
        alpha = alpha ./ ( 1 .+ (Bz[:,:,n-1] / B0).^2 )
        A[:,:,n] = eq2_next_t( A[:,:,n-1], Bz[:,:,n-1], alpha, beta, dx, dy, dt, Nx, Ny )
        Bz[:,:,n] = eq3_next_t( A[:,:,n-1], Bz[:,:,n-1], V, beta, dx, dy, dt, Nx, Ny )
    end

    
    fig = Figure( fontsize=20 )
    ax1 = Axis( fig[1,1], title=L"A at $t_{max}$"  )
    ax2 = Axis( fig[1,2], title=L"$B_z$ at $t_{max}$" )
    ax3 = Axis( fig[2,1], title=L"A at arbitrary point$$" )
    ax4 = Axis( fig[2,2], title=L"$B_z$ at arbitrary point" )
    title = Label(fig[0, :], L"$B_z$ with $N_x = 67$, $N_t = 10000$, $\beta = 7.0$, $\alpha_0 = 5$, with $\alpha$-quenching", fontsize = 20)

    
    image!( ax1, A[:,:,Nt], colormap=:managua )
    image!( ax2, Bz[:,:,Nt], colormap=:managua )

    lines!( ax3, A[5,5,:].^2 )
    lines!( ax4, Bz[5,5,:].^2 )

    display( fig )
    
    
    #fig = Figure( fontsize=20 )
    #ax1 = Axis( fig[1,1], title=L"Butterfly diagram of $B_z$ as function of $y$ and $t$", aspect=AxisAspect(0.5)  )
    #title = Label(fig[0, 1], L"$B_z$ with $N_x = 20$, $N_t = 6000$, $\beta = 5.9$, $\alpha_0 = -5$", fontsize = 20)

    #image!( ax1, Bz[5,:,:], colormap=:managua )

    #display( fig )
    
    """
    obs_A = Observable( A[:,:,1] )
    obs_Bz = Observable( Bz[:,:,1] )

    fig_rec = Figure( )
    ax1_rec = Axis( fig_rec[1,1], title="A" )
    ax2_rec = Axis( fig_rec[1,2], title="Bz" )

    title = Label(fig_rec[0, :], "A and Bz with Nx = 100, Nt = 30000, beta = 7.5", fontsize = 15)
    
    image!( ax1_rec, obs_A )
    image!( ax2_rec, obs_Bz )

    framerate = 30
    timestamps = 0.1:1/30:tmax

    record(fig_rec, "aaa.mp4", timestamps;
        framerate = framerate) do t

        n_rec = Int64( round(t * Nt / tmax))

        obs_A[] = A[:,:,n_rec]
        obs_Bz[] = Bz[:,:,n_rec]
    end
    """
    
    
    return
end

main()






