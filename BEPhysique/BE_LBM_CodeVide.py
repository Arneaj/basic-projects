# -*- coding: utf-8 -*-
import numpy as np
import matplotlib.pyplot as plt

#*************************************************%
#NE PAS MODIFIER LE CODE SAUF AUX LIGNES DEMANDEES%
#*************************************************%

# Paramètres des phonons du silicium @300K
v = 6400.0  # Vitesse des phonons (norme)
vx = v / np.sqrt(3)  # Composante de vitesse selon x
lpm = 41.6e-9  # Libre parcours moyen
tau = 6.5e-12  # Durée de relaxation
Cv = 1.66e6  # Capacité calorifique à volume constant à 300K
kappa = 1/3 * Cv * v * lpm  # Conductivité thermique à 300K
alpha = 8.8e-5  # Diffusivité thermique à 300K

# Paramètres de simulation
Kn = 0.005  # Nombre de Knudsen (A MODIFIER SELON LES SIMULATIONS A EFFECTUER)
L = 1 / Kn * lpm  # Longueur de la chaine
N = 1001  # Nombre de points du réseau
dx = L / (N - 1)  # Discretisation selon x
dt = dx / vx  # Pas de discrétisation temporelle
w = dt / tau  # Paramètre pour le terme de collision du modèle LBM
x = np.linspace(0, L, N)  # Position
X = x / L  # Coordonnées normalisées
taudiff = L ** 2 / alpha  # Durée caractéristique de diffusion

Nt = 20000  # Nombre d'itérations temporelles (A MODIFIER SELON LES SIMULATIONS A EFFECTUER)
tmax = Nt * dt  # durée du calcul (obligatoirement un multiple de dt)

# Températures appliquées
Ti = 300.0  # Température initiale dans tout le matériau
T1 = 301.0  # Température fixée en x=0
T2 = 300.0  # Température fixée en x=L

#*********************
# Solution analytique*
#*********************

# initialisations
sommeT = np.zeros(N)
sommeP = np.zeros(N)
taun = tau / dt
tpmax = (1 - 1 / (2 * taun)) * tmax
imax = 30

# Calcul de la somme
for id in range(1, imax+1):
    sommeT = sommeT + 1 / id * np.sin(id * np.pi * X) * np.exp(-Kn**2 * id**2 * np.pi**2 / 3 * tpmax / tau)
    sommeP = sommeP + np.cos(id * np.pi * X) * np.exp(-Kn**2 * id**2 * np.pi**2 / 3 * tpmax / tau)

Theta = 1 - X - 2 / np.pi * sommeT  # Température normalisée
Q = 1 + 2 * sommeP  # Flux de chaleur normalisé
Ta = (T1 - T2) * Theta + T2  # Température analytique
P = kappa * Q * (T1 - T2) / L  # Flux analytique

#************************
# Solution numérique LBM*
#************************

e0 = np.zeros(N) # Energie interne à l'équilibre local
e1 = np.zeros(N) # Energie des phonons de la famille 1
e2 = np.zeros(N) # Energie des phonons de la famille 2
e1_0 = np.zeros(N) # Energie à l'équilibre local des phonons de la famille 1
e2_0 = np.zeros(N) # Energie à l'équilibre local des phonons de la famille 2

# Conditions initiales
# La température est uniforme dans tout le matériau et égale à Ti
e0 = Cv * Ti * np.ones(N)
e1 = e0 / 2 #A COMPLETER
e2 = e0 / 2 #A COMPLETER
e1_0 = e0 / 2 #A COMPLETER
e2_0 = e0 / 2 #A COMPLETER


#*****************#
#Boucle temporelle#
#*****************#
for i in range(Nt):
    print(i)
    #collision pour les deux familles de phonons
    e1coll = e1 + w * (e1_0 - e1)
    e1 = e1coll
    
    e2coll = e2 + w * (e2_0 - e2)
    e2 = e2coll
    
    #Transport le long de la chaine pour les deux familles de phonons
    for j in range(N-1):
        e2[j] = e2[j+1]
    for j in range(1, N):
        e1[N-j] = e1[N-j-1]
        
    #Conditions aux limites permettant de fixer les températures aux deux
    #bords et de thermaliser les phonons
    e2[0] = Cv * T1 / 2.0 
    e1[0] = Cv * T1 / 2.0 
    e1[N-1] = Cv * T2 / 2.0 
    e2[N-1] = Cv * T2 / 2.0 
    e = e1 + e2 #Energie calculée le long de la chaine

    e1_0 = e / 2.0 # Energie à l'équilibre local pour la famille 1
    e2_0 = e / 2.0 # Energie à l'équilibre local pour la famille 2
		
# Température
T = e / Cv # A COMPLETER
TN = (T - T2) / (T1 - T2)  # Température normalisée

plt.figure(1)
plt.plot(X, TN, X, Theta)
plt.xlabel('X=x/L (coordonnée normalisée)')
plt.ylabel('T* (Température normalisée)')
plt.legend(['LBM', 'Fourier'])

# Flux de chaleur
Phi = - kappa * np.diff(T)/dx  # A COMPLETER
Phi[0] = Phi[1]
Phi[N - 1] = Phi[N - 2]
PhiN = L * Phi / (kappa * (T1 - T2))  # Flux de chaleur normalisé
plt.figure(2)
plt.plot(X[1:N - 1], PhiN[1:N - 1], X, Q)
plt.xlabel('X=x/L (coordonnée normalisée)')
plt.ylabel('Phi* (Flux de chaleur normalisé)')
plt.legend(['LBM', 'Fourier'])

# Récupération des données
Data = np.column_stack((X, Theta, TN, Q, PhiN))
np.savetxt('Data.txt', Data, fmt='%6.3f %12.8f %12.8f %12.8f %12.8f', header='X T Fourier T LBM Flux Fourier Flux LBM')
