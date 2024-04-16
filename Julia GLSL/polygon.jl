using ModernGL, GLAbstraction, GLFW
using GeometryTypes

const GLA = GLAbstraction

window = GLFW.Window( name="GLSL", resolution=(512, 512) )
GLA.set_context!( window )

vertex_shader = GLA.vert"""
# version 150

in vec2 position;
in vec3 color;

out vec3 Color;

void main()
{
    Color = color;

    gl_Position = vec4(position, 0.0, 1.0) + sin(time);
}
"""

fragment_shader = GLA.frag"""
# version 150

in vec3 Color;

out vec4 outColor;

void main(){
    outColor = vec4(Color, 1.0);
}
"""

prog = GLA.Program( vertex_shader, fragment_shader )

# The positions of the vertices in our triangles
vertex_positions = Point{2,Float32}[(-0.5,  0.5),     
                                    ( 0.5,  0.5),     
                                    ( 0.5, -0.5),     
                                    (-0.5, -0.5)]     

# The colors assigned to each vertex
vertex_colors = Vec3f0[(1, 0, 0),                     
                       (0, 1, 0),                     
                       (0, 0, 1),                     
                       (1, 1, 1)]

# Specify how vertices are arranged into faces
# Face{N,T,O} type specifies a face with N vertices, with index type
# T (you should choose UInt32), and index-offset O. If you're
# specifying faces in terms of julia's 1-based indexing, you should set
# O=0. (If you instead number the vertices starting with 0, set
# O=-1.)

t0 = time()

elements = Face{3,UInt32}[(0,1,2),
                          (2,3,0)]

# Here you put the variables that go in the vertex shader (I think)
buffers = GLA.generate_buffers(prog, position = vertex_positions, 
                                     color = vertex_colors,
                                     time = time() - t0 )

vao = GLA.VertexArray(buffers, elements)
glClearColor(0.1, 0.1, 0.1, 1)

while !GLFW.WindowShouldClose(window)

    # Render here
    glClear(GL_COLOR_BUFFER_BIT)
    GLA.bind(prog)
    GLA.bind(vao)
    GLA.draw(vao)
    
    GLA.unbind(vao) #optional in this case
    GLA.unbind(prog) #optional in this case

    # Swap front and back buffers
    GLFW.SwapBuffers(window)

    # Poll for and process events
    GLFW.PollEvents()

    if GLFW.GetKey(window, GLFW.KEY_ESCAPE) == GLFW.PRESS
        GLFW.SetWindowShouldClose(window, true)
    end
end

GLFW.DestroyWindow(window)








return