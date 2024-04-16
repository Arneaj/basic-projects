import numpy as np
from math import *
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import axes3d
import cmath
#import imageio.v2 as iio
import matplotlib.animation as animation
from matplotlib import rc

#(certains modules sont sans doute inutilisés mais j'ai trop peur d'en enlever un et de détruire l'entiereté de mon code :( )

##################################################################
##MODELE DE VICSEK
##################################################################

#Déclaration des variables
pi = acos(-1)

N = 1024       # N > 800 : prend toute une vie pour calculer sur mon ordi
nt = 100
v0 = 0.03    # v0 > 0.03 pour accélérer la simulation
dt = 1
a = 1
l = 16
rho = N/(l**2)
tf = nt*dt
t = [i*dt for i in range(nt)]
ic = complex(0,1)
eta = 0.1
tot = 0

print('rho = ', rho)

#Conditions initiales
x = np.random.uniform(size = (nt,N))*l
y = np.random.uniform(size = (nt,N))*l
teta = np.random.uniform(-pi,pi,(nt,N))
phi = np.zeros(nt)

#Calcul aux instants suivants
for i in range (1,nt):
    tot = 0
    for j in range(N):
        # Initialisation
        somme = 0.
        ksi = np.random.uniform(-pi,pi)
       
        for k in range (j):
            # r_nm
            rnm = 10*l
            for epsx in ([-1,0,1]):
                for epsy in ([-1,0,1]):
                    r = sqrt((x[i-1][j]-(x[i-1][k] + epsx*l))**2 + (y[i-1][j]-(y[i-1][k] + epsy*l))**2)
                    if (rnm > r) :
                        rnm = r  
                    #print(rnm)
                   
            # Calcul somme
            if (rnm < a):
                somme += cos(teta[i-1][k]) + ic*sin(teta[i-1][k])
                #print("somme = ", somme)
               
        for k in range (j+1, N):
            # r_nm
            rnm = 10*l
            for epsx in ([-1,0,1]):
                for epsy in ([-1,0,1]):
                    r = sqrt((x[i-1][j]-(x[i-1][k] + epsx*l))**2 + (y[i-1][j]-(y[i-1][k] + epsy*l))**2)
                    if (rnm > r) :
                        rnm = r    
                    #print(rnm)
                   
            # Calcul somme
            if (rnm < a):
                somme += cos(teta[i-1][k]) + ic*sin(teta[i-1][k])
                #print("somme = ", somme)
                   
        # Calcul teta
        teta[i][j] = cmath.phase(somme) + eta*ksi
        #print("teta = ", teta)
       
        # Calcul de x et y
        x[i][j] = x[i-1][j] + v0*dt*cos(teta[i][j])
        y[i][j] = y[i-1][j] + v0*dt*sin(teta[i][j])
       
        # Condition aux bords
        if (x[i][j] > l) :
            x[i][j] = x[i][j] - l
           
        if (x[i][j] < 0) :
            x[i][j] = x[i][j] + l
           
        if (y[i][j] > l):
            y[i][j] = y[i][j] - l
           
        if (y[i][j] < 0):
            y[i][j] = y[i][j] + l
       
        #Stationnarité, implémentation
        tot += cos(teta[i][j]) + ic*sin(teta[i][j])
       
    # Paramètre vol stationnaire
    phi[i] = abs(tot)/N

#position
position = (x**2 + y**2)**(1/2)

#print("teta = ", teta)
#print(cmath.phase(cos(2)+ic*sin(2)))

#################################################################
#MARCHE ALEATOIRE
#################################################################

# #Moyenne
# moy = np.mean(position[-1] - position[0])

# #Variance
# var = np.zeros(nt)
# for i in range (nt):
#     var[i] = np.var(position[i] - position[0])


#Coefficient de diffusion
dh = dt*v0
D = dh**2/(2*dt)

print("D = ", D)


##################################################################
#VOLS AVEC EFFETS COLLECTIFS PARFAITS
##################################################################


##################################################################
#VOLS PERTURBES : EFFETS COLLECTIFS ET STOCHASTIQUES
##################################################################

#Moyenne de phi aux temps longs
moy_phi = np.mean(phi)
print('moyenne de phi pour eta = ', eta,', N = ',N,',l = ',l,':', moy_phi)

# Les différentes valeurs de eta testées
eta_absc = np.array([0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9])


##### rho = 0.4 #####
# N=40, l=10
phi_infini_1 = np.array([0.67498, 0.41686, 0.32476, 0.22054, 0.19389, 0.19235, 0.17067, 0.14714, 0.14135])

# plt.plot(eta_absc, phi_infini_1, label = 'N=40, l=10')
# plt.xlabel('eta')
# plt.ylabel('moyenne temporelle de phi')
# plt.title('rho = 0.4')
# plt.legend()
# plt.show()

# N=100, l=15.8
phi_infini_2 = np.array([0.67350, 0.33732, 0.30748, 0.20488, 0.13264, 0.13588, 0.11667, 0.10103, 0.09383])

# plt.plot(eta_absc, phi_infini_2, label = 'N=100, l=15.8')
# plt.xlabel('eta')
# plt.ylabel('moyenne temporelle de phi')
# plt.title('rho = 0.4')
# plt.legend()
# plt.show()

# N=500, l=35.4
phi_infini_3 = np.array([])

# plt.plot(eta_absc, phi_infini_3, label = 'N=500, l=35.4')
# plt.xlabel('eta')
# plt.ylabel('moyenne temporelle de phi')
# plt.title('rho = 0.4')
# plt.legend()
# plt.show()

# N=1000, l=50
phi_infini_4 = np.array([])

# plt.plot(eta_absc, phi_infini_5, label = 'N=1000, l=50')
# plt.xlabel('eta')
# plt.ylabel('moyenne temporelle de phi')
# plt.title('rho = 0.4')
# plt.legend()
# plt.show()

##### rho = 4 #####
# N=1024, l=16
phi_infini_5 = np.array([])

# plt.plot(eta_absc, phi_infini_5, label = 'N=1024, l=16')
# plt.xlabel('eta')
# plt.ylabel('moyenne temporelle de phi')
# plt.title('rho = 4.')
# plt.legend()
# plt.show()