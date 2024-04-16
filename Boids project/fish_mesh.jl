module Fish

using FileIO, MeshIO
using GeometryBasics
using GLMakie

function R3_x( phi )
    return [ 1 0 0;
             0 cos(phi) -sin(phi);
             0 sin(phi) cos(phi) ]
end

function R3_y( theta )
    return [ cos(theta) 0 -sin(theta);
                      0 1 0;
             sin(theta) 0 cos(theta) ]
end

function R3_z( psi )
    return [ cos(psi) -sin(psi) 0;
             sin(psi) cos(psi)  0;
                            0 0 1 ]
end

function main()

    fish = load( "Common_Nase.obj" )
    mesh( fish )

    coord = map(coordinates( fish )) do vec
        vec ./ 10
    end

    new_fish = mesh( coord )

end


end #module