import numpy as np
import matplotlib.pyplot as plt
import noise
from datetime import datetime

mu = 1.0
sigma = 1.0

DEEP_WATER = (15.0/255,94.0/255,156.0/255)
WATER = (35.0/255,137.0/255,218.0/255)
BEACH = (194.0/255, 178.0/255, 128.0/255)
GRASS = (80.0/255, 120.0/255, 10.0/255)
FOREST = (36.0/255, 52.0/255, 7.0/255)
ROCKS = (146.0/255, 142.0/255, 133.0/255)
SNOW = (255.0/255, 250.0/255, 250.0/255)

dim = 320

shape = (dim,dim)
wavelength = 0.5      # the base wavelength I think
octaves = 6           # the number of noises added
persistence = 0.5     # the number by which wavelength is multiplied every octave iteration
lacunarity = 2.0
seed = np.random.randint(0,100)


world = np.zeros(shape)

x_idx = np.linspace(0, 1, shape[0])
y_idx = np.linspace(0, 1, shape[1])
world_x, world_y = np.meshgrid(x_idx, y_idx)


world = np.vectorize(noise.pnoise2)(world_x/wavelength,
                        world_y/wavelength,
                        octaves=octaves,
                        persistence=persistence,
                        lacunarity=lacunarity,
                        repeatx=1024,
                        repeaty=1024,
                        base=seed)

min_height = 1000
max_height = -1000
for x in range(shape[0]):
    for y in range(shape[1]):
        nx = x/shape[0]
        ny = y/shape[1]
        d = 1 - (1-(nx - 0.5)**2) * (1-(ny - 0.5)**2)
        world[x,y] -= (d)**(1/2) + (1+1/3)
        max_height = max(max_height, world[x,y])
        min_height = min(min_height, world[x,y])
     
world = (1+1/3)*world - min_height
world /= ((1+1/3)*max_height-min_height)  


def biome(terrain,
          deep_water_level=0.02,
          water_level=0.1,
          beach_level=0.15,
          grass_level=0.4,
          forest_level=0.7,
          rocks_level=0.9):
    
    if terrain < deep_water_level: return DEEP_WATER
    if terrain < water_level: return WATER
    if terrain < beach_level: return BEACH
    if terrain < grass_level: return GRASS
    if terrain < forest_level: return FOREST
    if terrain < rocks_level: return ROCKS
    return SNOW

def color_world(some_world):
    colored_world = np.empty((shape[0], shape[1], 3))
    
    for x in range(shape[0]):
        for y in range(shape[1]):
            colored_world[x,y,:] = biome(some_world[x,y])
    
    return colored_world

colored_world = color_world(world)

'''
plt.figure
plt.imshow(colored_world)
plt.show()
'''

np.savetxt("height_map.txt", world)
np.savetxt("colored_map_r.txt", colored_world[:,:,0])
np.savetxt("colored_map_g.txt", colored_world[:,:,1])
np.savetxt("colored_map_b.txt", colored_world[:,:,2])

#########################

def diagonal(xL, yL, 
             xP, yP, 
             dl, maxl = 1):
    
    lamb_list = np.arange(dl,maxl+dl,dl)
    
    pos_list = np.empty((np.size(lamb_list), 2))
    
    for i in range(np.size(lamb_list)):
        pos_list[i,0] = round(lamb_list[i]*(xL-xP) + xP)
        pos_list[i,1] = round(lamb_list[i]*(yL-yP) + yP)
    
    pos_list = np.unique(pos_list, axis=0)
    
    return pos_list
      
      
def dP(xP, yP, 
       x, y):
    
    return np.sqrt((xP-x)**2 + (yP-y)**2) / shape[0]


def shade(some_colored_world, 
          some_height_map, 
          xL, yL, hL, dl):
    
    shaded_world = np.copy(some_colored_world)
    
    ## code to be made in GLSL
    
    for xP in range(shape[0]):
        for yP in range(shape[1]):
            if (xP == xL and yP == yL): continue
            
            hP = some_height_map[xP,yP]
            if hP<0.1: continue
            
            dPL = dP(xP,yP, xL,yL)
            
            maxl = (1-hP) / (hL-hP)
            
            pos_list = diagonal(xL,yL, xP,yP, dl, maxl)
            
            for i in range(np.size(pos_list, axis=0)) :
                
                x = int(pos_list[i,0])
                y = int(pos_list[i,1])
                
                if (x == xP and y==yP): continue
                
                hX = some_height_map[x, y]
                dPX = dP(xP,yP, x,y)
                
                if (hX > hP and (hL-hP)/dPL < (hX-hP)/dPX ):
                    shaded_world[xP,yP,:] *= 0.7
                    break
            
    ## end of code to be made in GLSL
    
    return shaded_world


"""
time_right = datetime.now()
shaded_world_top_right = shade(colored_world, world, 0, 256, 3, 0.001)
time_right = datetime.now() - time_right
time_left = datetime.now()
shaded_world_top_left = shade(colored_world, world, 0, 0, 3, 0.001)
time_left = datetime.now() - time_left

fig, axs = plt.subplots(1,2)

axs[0].imshow(shaded_world_top_right)
axs[0].set_title(time_right)

axs[1].imshow(shaded_world_top_left)
axs[1].set_title(time_left)
plt.show()
"""