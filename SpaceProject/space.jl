using GLMakie, ImageCore, Colors

global const G::Float64 = 6.67

mutable struct StellarBody 
    pos::Point2f
    v::Vector{Float64}
    m::Float64
    density::Float64
end

Base.copy(S::StellarBody) = StellarBody(S.pos, S.v, S.m, S.density)

function gravity(dt, body::StellarBody, other_body::StellarBody)
    r::Vector{Float64} = other_body.pos - body.pos
    d = norm(r)
    if d<0.3 d=0.3 end

    body.v += dt * G * other_body.m / (d^3) * r
    body.pos += body.v * dt
end

function update(dt, t_max, bodies, moving_bodies, trajectories, nb_moving_bodies)
    
    for k in 2:nb_moving_bodies
        moving_bodies[k] = copy(bodies[k])
        trajectories[k-1][] = [moving_bodies[k].pos]
    end

    for t in 0:dt:t_max
        for i in 2:nb_moving_bodies
            for j in 1:nb_moving_bodies
                if moving_bodies[i] == moving_bodies[j] continue end
                gravity( dt, moving_bodies[i], moving_bodies[j] )
            end
            push!( trajectories[i-1][], moving_bodies[i].pos )
        end
        
    end

    for k in 2:nb_moving_bodies
        notify( trajectories[k-1] )
    end
end

function update_animated(dt, t_max, bodies, moving_bodies, trajectories, nb_moving_bodies)
    
    for k in 2:nb_moving_bodies
        moving_bodies[k] = copy(bodies[k])
        trajectories[k-1][] = [moving_bodies[k].pos]
    end

    for t in 0:dt:t_max
        for i in 2:nb_moving_bodies
            for j in 1:nb_moving_bodies
                if moving_bodies[i] == moving_bodies[j] continue end
                gravity( dt, moving_bodies[i], moving_bodies[j] )
            end
            push!( trajectories[i-1][], moving_bodies[i].pos )
            notify( trajectories[i-1] )
        end
        sleep(dt)
    end
end

function main()
    dt = 0.01
    fig = Figure()

    #axis
    dim = 10
    ax = Axis( fig[1,1], aspect=AxisAspect(1), limits=(-dim, dim, -dim, dim) )
    deactivate_interaction!( ax, :rectanglezoom )
    #end of axis

    #menu
    t_max = 10.
    sl_tmax = Slider( fig, range = 0:0.1:300., startvalue = 60. )
    sl_speed = Slider( fig, range = 0:0.001:2., startvalue = 1. )
    button_add_body = Button(fig, label = "Add a body ")
    button_anim = Button(fig, label = "Play animation ")

    fig[1,2] = vgrid!( button_add_body,
                       button_anim,
                       Label(fig, "Max time : "), sl_tmax,
                       Label(fig, "Tangential speed : "), sl_speed,
                       tellheight = false, width = 100 )
    #end of menu

    display( fig )

    #create bodies
    body1 = StellarBody( Point2f(0.,0.), [0.,0.], 1., 1. )
    body2 = StellarBody( Point2f(3.,0.), [0.,1.], 0.1, 1. )
    bodies = [ body1, body2 ]

    #showing traj
    moving_body2 = copy( body2 )
    moving_bodies = [ body1, moving_body2 ]
    traj2 = Observable( [moving_body2.pos] )

    trajectories = [ traj2 ]

    poly!( Circle(body1.pos, 0.4), color=:pink )
    poly!( Circle(body2.pos, 0.2) )

    for t in 0:dt:t_max
        gravity( dt, moving_body2, body1 )
        push!( trajectories[1][], moving_body2.pos )
    end

    lines!( ax, trajectories[1], linestyle=:dot )
    #end of showing traj

    on(sl_speed.value) do speed
        bodies[2].v = [0.,speed]

        moving_bodies[2] = copy(bodies[2])
        trajectories[1][] = [moving_bodies[2].pos]
        
        update(dt, t_max, bodies, moving_bodies, trajectories, button_add_body.clicks[]+2)
    end

    on(sl_tmax.value) do t
        t_max = t
        
        update(dt, t_max, bodies, moving_bodies, trajectories, button_add_body.clicks[]+2)
    end

    on(button_add_body.clicks) do nb
        new_body = StellarBody( Point2f(nb+3.,0.), [0.,1.], 0.1, 1. )
        new_moving_body = copy( new_body )
        push!( bodies, new_body )
        push!( moving_bodies, new_moving_body )
        poly!( Circle(last(bodies).pos, 0.2) )

        push!( trajectories, [new_moving_body.pos] )
        lines!( ax, last(trajectories), linestyle=:dot )

        update(dt, t_max, bodies, moving_bodies, trajectories, button_add_body.clicks[]+2)
    end

    on(button_anim.clicks) do nb
        update_animated(dt, t_max, bodies, moving_bodies, trajectories, button_add_body.clicks[]+2)
    end

end


main()