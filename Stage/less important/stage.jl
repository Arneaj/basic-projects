using GLMakie
using LinearAlgebra

function f(x)
    return -(x-0.4)*(x+0.3)*(x-1.5)    
end

function g(x)
    return f(-x)   
end

function fig19()
    fig = Figure( )

    axs = Vector(undef, 2)
    axs[1] = Axis(fig[1, 1], aspect=AxisAspect(2), limits=(-1, 1, -0.5, 1.5), title=L"$a > 0$", titlesize=50, ylabel=L"$P(\chi)$", ylabelsize=50, xlabel=L"$\chi$", xlabelsize=50, yticklabelsvisible=false, ylabelrotation=0)
    axs[2] = Axis(fig[1, 2], aspect=AxisAspect(2), limits=(-1, 1, -0.5, 1.5), title=L"$a < 0$", titlesize=50, ylabel=L"$P(\chi)$", ylabelsize=50, xlabel=L"$\chi$", xlabelsize=50, yticklabelsvisible=false, ylabelrotation=0)

    #hidexdecorations!(axs[1], grid = false)
    #hidexdecorations!(axs[2], grid = false)

    X = -1:0.01:1

    F = f.(X)
    G = g.(X)

    lines!( axs[1], X, F, color=:black )
    lines!( axs[2], X, G, color=:black )

    lines!( axs[1], [0.4, 0.4], [-0.5, 2], linestyle=:dash, color=:red )
    lines!( axs[2], [0.3, 0.3], [-0.5, 2], linestyle=:dash, color=:red )

    lines!( axs[1], [-0.3, -0.3], [-0.5, 2], linestyle=:dash, color=:red )
    lines!( axs[2], [-0.4, -0.4], [-0.5, 2], linestyle=:dash, color=:red )

    lines!( axs[1], [-1, 1], [0, 0], color=:gray )
    lines!( axs[2], [-1, 1], [0, 0], color=:gray )

    text!( axs[1], [-0.6, 0.45], [-0.4, -0.4], text=[L"$\chi_{inf}", L"$\chi_{sup}"], fontsize=50 )
    text!( axs[2], [-0.7, 0.35], [-0.4, -0.4], text=[L"$\chi_{inf}", L"$\chi_{sup}"], fontsize=50 )

    display( fig )

    return
end

f2(x) = 1.5-sqrt(abs(sin(3*pi*x)))

function fig20()
    fig = Figure( )

    axs = Vector(undef, 2)
    axs[1] = Axis(fig[1, 1], aspect=AxisAspect(2), limits=(0, 1, 0, 2), ylabel=L"$\theta$", ylabelsize=50, xlabel=L"$\psi$", xlabelsize=50, yticklabelsvisible=false, xticklabelsvisible=false, ylabelrotation=0)

    #hidexdecorations!(axs[1], grid = false)
    #hidexdecorations!(axs[2], grid = false)

    X = 0:0.0001:1

    F = f2.(X)

    lines!( axs[1], X, F, color=:black )

    lines!( axs[1], [0, 1], [1.5, 1.5], linestyle=:dash, color=:red )

    lines!( axs[1], [0, 1], [0.5, 0.5], linestyle=:dash, color=:red )

    text!( axs[1], [0.1, 0.1], [0.2, 1.52], text=[L"$\theta_{inf}", L"$\theta_{sup}"], fontsize=50 )

    display( fig )

    return
end

function f3(t) 
    return Point2f( sin(-2*t) + t + 0.5, cos(-2*t) + 1 )
end

function fig21()
    fig = Figure( )

    axs = Vector(undef, 2)
    axs[1] = Axis(fig[1, 1], aspect=AxisAspect(2), limits=(0, 8, -0.5, 2.5), ylabel=L"$\theta$", ylabelsize=50, xlabel=L"$\psi$", xlabelsize=50, yticklabelsvisible=false, xticklabelsvisible=false, ylabelrotation=0)

    #hidexdecorations!(axs[1], grid = false)
    #hidexdecorations!(axs[2], grid = false)

    T = -5:0.01:10

    XY = f3.(T)

    #@show XY

    lines!( axs[1], XY, color=:black )

    lines!( axs[1], [0, 8], [2, 2], linestyle=:dash, color=:red )

    lines!( axs[1], [0, 8], [0, 0], linestyle=:dash, color=:red )

    text!( axs[1], [0.1, 0.1], [-0.45, 2.05], text=[L"$\theta_{inf}", L"$\theta_{sup}"], fontsize=50 )

    display( fig )

    return
end

function f4(t)
    return 0.1 * sin(3*pi*t) + 0.5
end

function fig22()
    fig = Figure( )

    axs = Vector(undef, 2)
    axs[1] = Axis(fig[1, 1], aspect=AxisAspect(2), limits=(0, 1, 0, 1), ylabel=L"$\theta$", ylabelsize=50, xlabel=L"$\psi$", xlabelsize=50, yticklabelsvisible=false, xticklabelsvisible=false, ylabelrotation=0)

    #hidexdecorations!(axs[1], grid = false)
    #hidexdecorations!(axs[2], grid = false)

    X = 0:0.0001:1

    F = f4.(X)

    lines!( axs[1], X, F, color=:black )

    lines!( axs[1], [0, 1], [0.6, 0.6], linestyle=:dash, color=:red )

    lines!( axs[1], [0, 1], [0.4, 0.4], linestyle=:dash, color=:red )

    text!( axs[1], [0.1, 0.1], [0.25, 0.62], text=[L"$\theta_{inf}", L"$\theta_{sup}"], fontsize=50 )

    display( fig )

    return
end

function f27(x)
    return exp(-0.5 * x) * cos( 10*pi*x)
end

function fig27()
    fig = Figure( )

    axs = Vector(undef, 2)
    axs[1] = Axis(fig[1, 1], aspect=AxisAspect(2), limits=(0, 1, -1.5, 1.5), ylabel=L"$x (t)$", ylabelsize=50, xlabel=L"$t$", xlabelsize=50, yticklabelsvisible=false, xticklabelsvisible=false, ylabelrotation=0)

    #hidexdecorations!(axs[1], grid = false)
    #hidexdecorations!(axs[2], grid = false)

    X = 0:0.0001:1

    F = f27.(X)

    lines!( axs[1], X, F, color=:black )

    display( fig )

    return
end

function f28(x, zeta)
    return 1 / sqrt( ( 1 - x^2 )^2 + ( 2*zeta*x )^2 )
end

function fig28()
    fig = Figure( )

    axs = Vector(undef, 2)
    axs[1] = Axis(fig[1, 1], aspect=AxisAspect(2), limits=(0, 4, -0.5, 2.5), ylabel=L"$|| DAF ||$", ylabelsize=50, xlabel=L"$\gamma_e \equiv \frac{\omega_e}{\omega}$", xlabelsize=50, ylabelrotation=0)

    #hidexdecorations!(axs[1], grid = false)
    #hidexdecorations!(axs[2], grid = false)

    X = 0:0.001:4

    F0 = f28.( X, 0 )
    F03 = f28.( X, 0.3 )
    F1 = f28.( X, 1 )

    l1 = lines!( axs[1], X, F0, color=:black, label = L"$\zeta = 0$" )
    l2 = lines!( axs[1], X, F03, color=:blue, label = L"$\zeta = 0.3$" )
    l3 = lines!( axs[1], X, F1, color=:green, label = L"$\zeta = 1$" )

    #fig[1, 2] = Legend(fig, axs[1], L"$\zeta$", framevisible = true)
    #Legend( fig[1;2], [l1, l2, l3], [L"$\zeta=0$", L"$\zeta=0.3$", L"$\zeta=1$"] )
    axislegend( labelsize=50, linewidth=2 )

    lines!( axs[1], [0, 0.9], [1.747, 1.747], linestyle=:dash, color=:red )

    lines!( axs[1], [1, 1], [-1, 3], linestyle=:dash, color=:red )
    lines!( axs[1], [0.9, 0.9], [-1, 1.747], linestyle=:dash, color=:red )

    text!( axs[1], [0.05, 0.5, 1.05], [1.8, -0.4, -0.4], text=[L"$||DAF||_{max}", L"$\omega_{e} = \Omega", L"\omega_e = \omega"], fontsize=40 )

    display( fig )

    return
end

function f29(x, zeta)
    if x <= 1 - zeta || x >= 1 + zeta
        return 1 / ( 1 - x^2 )
    end
    if x >= 1 - zeta && x < 1
        return 1 / ( 1 - (1-zeta)^2 )
    end
    return 1 / ( 1 - (1+zeta)^2 )
end

function fig29()
    fig = Figure( )

    axs = Vector(undef, 2)
    axs[1] = Axis(fig[1, 1], aspect=AxisAspect(1), limits=(0, 4, -3, 3.5), ylabel=L"$DAF$", ylabelsize=50, xlabel=L"$\gamma_e$", xlabelsize=50, ylabelrotation=0, yticklabelsvisible=false, xticklabelsvisible=false)

    X = 0:0.001:4

    F = f29.(X, 0.2)

    lines!( axs[1], X, F, color=:black )
    #lines!( axs[1], [0, 0], [1 / ( 1 - (1-0.3)^2 ), 1 / ( 1 - (1+0.3)^2 )], color=:black )

    display( fig )

    return
end

function f32(x)
    return cos( 4*pi*x)
end

function fig32()
    fig = Figure( )

    axs = Vector(undef, 2)
    axs[1] = Axis(fig[1, 1], aspect=AxisAspect(2), limits=(0, 1, -1.5, 1.5), ylabel=L"$g (t)$", ylabelsize=50, xlabel=L"$t$", xlabelsize=50, yticklabelsvisible=false, xticklabelsvisible=false, ylabelrotation=0)

    #hidexdecorations!(axs[1], grid = false)
    #hidexdecorations!(axs[2], grid = false)

    X = 0:0.0001:1

    F = f32.(X)

    lines!( axs[1], X, F, color=:black )

    display( fig )

    return
end

function f36a(x)
    return (1 - x^2) / ((0.382-x^2)*(2.618-x^2))
end

function f36b(x)
    return 1 / ((0.382-x^2)*(2.618-x^2))
end

function fig36()
    fig = Figure( )

    axs = Vector(undef, 2)
    axs[1] = Axis(fig[1, 1], aspect=AxisAspect(1), limits=(0, 3, -3, 3), ylabel=L"$DAF_{1 \, e1}$", ylabelsize=50, xlabel=L"$\gamma_{e1}$", xlabelsize=50, ylabelrotation=0)
    axs[2] = Axis(fig[1, 2], aspect=AxisAspect(1), limits=(0, 3, -3, 3), ylabel=L"$DAF_{2 \, e1}$", ylabelsize=50, xlabel=L"$\gamma_{e1}$", xlabelsize=50, ylabelrotation=0)

    #hidexdecorations!(axs[1], grid = false)
    #hidexdecorations!(axs[2], grid = false)

    X = 0:0.001:3

    Fa = f36a.(X)
    Fb = f36b.(X)

    lines!( axs[1], X, Fa, color=:black )
    lines!( axs[2], X, Fb, color=:black )

    lines!( axs[1], [0, 3], [0, 0], color=:gray )
    lines!( axs[2], [0, 3], [0, 0], color=:gray )

    text!( axs[1], [0.1, 1.7], [-0.5, 0.1], text=[L"$\Phi - 1$", L"$\Phi \approx 1.618$"], fontsize=30 )
    text!( axs[2], [0.1, 1.7], [-0.5, -0.5], text=[L"$\Phi - 1$", L"$\Phi$"], fontsize=30 )

    display( fig )

    return
end


return