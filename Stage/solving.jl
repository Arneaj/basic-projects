using GLMakie
using NonlinearSolve
using LinearAlgebra

f(u, p) = [-u[1] - u[3] + p[1]*cos(u[5])*u[1] + p[1]*sin(u[5])*u[2] + p[1]*cosh(u[5])*u[3] + p[1]*sinh(u[5])*u[4],
           -u[2] - u[2] -p[2]*sin(u[5])*u[1] + p[2]*cos(u[5])*u[2] + p[2]*sinh(u[5])*u[3] + p[2]*cosh(u[5])*u[4],
           u[1] - u[3] -p[3]*cos(u[5])*u[1] - p[3]*sin(u[5])*u[2] + p[3]*cosh(u[5])*u[3] + p[3]*sinh(u[5])*u[4],
           u[2] - u[4] + p[4]*sin(u[5])*u[1] - p[4]*cos(u[5])*u[2] + p[4]*sinh(u[5])*u[3] + p[4]*cosh(u[5])*u[4]]

determinant(u, p) = 4*p[1]*p[2]*p[3]*p[4] - 2*p[1]*p[2]*p[3]*cosh(u) - 2*p[1]*p[2]*p[3]*cos(u) - 2*p[1]*p[2]*p[4]*cosh(u) - 2*p[1]*p[2]*p[4]*cos(u) + 2*p[1]*p[2] + 2*p[1]*p[2]*cos(u)*cosh(u) - 2*p[1]*p[3]*p[4]*cosh(u) - 2*p[1]*p[3]*p[4]*cos(u) + 4*p[1]*p[3]*cos(u)*cosh(u) + 2*p[1]*p[4] + 2*p[1]*p[4]*cos(u)*cosh(u) - 2*p[1]*cos(u) - 2*p[1]*cosh(u) - 2*p[2]*p[3]*p[4]*cosh(u) - 2*p[2]*p[3]*p[4]*cos(u) + 2*p[2]*p[3] + 2*p[2]*p[3]*cos(u)*cosh(u) + 4*p[2]*p[4]*cos(u)*cosh(u) - 2*p[2]*cos(u) - 2*p[2]*cosh(u) + 2*p[3]*p[4] + 2*p[3]*p[4]*cos(u)*cosh(u) - 2*p[3]*cos(u) - 2*p[3]*cosh(u) - 2*p[4]*cos(u) - 2*p[4]*cosh(u) + 4 

g(u, p) = det(reshape([-1+p[1]*cos(u), p[1]*sin(u), p[1]*cosh(u)-1,  p[1]*sinh(u),
                -p[2]*sin(u),  p[2]*cos(u)-1, p[2]*sinh(u), p[2]*cosh(u)-1,
                1-p[3]*cos(u), - p[3]*sin(u), p[3]*cosh(u)-1, p[3]*sinh(u),
                p[4]*sin(u), - p[4]*cos(u)+1, p[4]*sinh(u), p[4]*cosh(u)-1], (4, 4)))

function main1()
    del = 1
    eps = 1
    gam = 1
    zet = 1

    omega = 2*pi

    u0 = [1.0, 1.0, 1.0, 1.0, 7.0]
    p = [del, eps, gam, zet]

    prob = NonlinearProblem(f, u0, p)

    sol = solve(prob)

    @show sol

    return
end

function main2()
    Del = 1#[0.01, 0.05, 0.15, 0.3, 0.5, 0.75, 1.0, 2.0, 3.0, 4.0, 5.0, 7.5, 10.0]
    Eps = [0.01, 0.05, 0.15, 0.3, 0.4, 0.5, 0.75, 1.0, 2.0, 3.0, 4.0, 5.0, 7.5, 10.0]
    Gam = [0.01, 0.05, 0.15, 0.3, 0.4, 0.5, 0.75, 1.0, 2.0, 3.0, 4.0, 5.0, 7.5, 10.0]
    Zet = [0.01, 0.05, 0.15, 0.3, 0.4, 0.5, 0.75, 1.0, 1.5, 2.0, 2.1, 2.2, 2.5, 3.0, 3.5, 4.0, 5.0, 7.5, 10.0, 12.0, 15.0, 17.5, 20.0]

    solutions = Array{Float64}(undef, (length(Del), length(Eps), length(Gam), length(Zet)))

    k = 0

    for del in Del
        k += 1
        l = 0
        for eps in Eps
            l += 1
            m = 0
            for gam in Gam
                m += 1
                n = 0
                for zet in Zet
                    n += 1 
                    
                    u0 = 7

                    p = [del, eps, gam, zet]

                    prob = NonlinearProblem(determinant, u0, p)

                    sol = solve(prob)

                    solutions[k, l, m, n] = sol.u

                end                        
            end
        end
    end

    fig = Figure()

    ax = Axis( fig[1,1] )

    #lines!( ax, Del, solutions[:,6,6,6], label = "delta" ) # blue
    #lines!( ax, Eps, solutions[1,:,6,6], label = "varepsilon" ) # yellow
    #lines!( ax, Gam, solutions[1,6,:,6], label = "gamma" ) # green
    [ lines!( ax, Zet, solutions[1,6,b,:], label = "zeta") for b in 1:6 ] # pink
    lines!( ax, [i for i in 2:0.1:20], 2*pi .+ (([i for i in 2:0.1:20] .- 2)./(3*[i for i in 2:0.1:20])).^(1/2), label = "aaaa" )

    #atan.(([i for i in 1:0.1:10] .- 2) ./(0.01.+[i for i in 1:0.1:10].+ 1))

    fig[1,2] = Legend( fig, ax )

    display( fig )

    return
end

return main2()






