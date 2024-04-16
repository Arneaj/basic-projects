import numpy as np
import matplotlib.pyplot as plt

M0 = 0.8
P0 = 22700
T0 = 217

gamma = 1.4
r =  287.1
Pk = 42.8*10**6
h = 0

# 1)

def Tt(T, M):
    return T*(1+(gamma-1)/2 * M**2)

def Pt(P, M):
    return P*(1+(gamma-1)/2 * M**2)**(gamma/(gamma-1))

def V(T, M):
    return np.sqrt(gamma*r*T) * M

Tt0 = Tt(T0, M0)
Pt0 = Pt(P0, M0)
V0 = V(T0, M0)

print("--- 1) ---")
print(Tt0)
print(Pt0)
print(V0)
print()

### 2) on fixe
taux_compression = 40
Tt4 = 1600

### 3)
# compresseur
Pt3 = taux_compression * Pt0
Tt3 = Tt0 * taux_compression**((gamma-1)/gamma)

print("--- 3) ---")
print(Pt3)
print(Tt3)
print()

# combustion
Pt4 = Pt3
Tt4 = Tt4
Cp = (gamma*r)/(gamma-1)
alpha  = Cp/Pk * (Tt4 - Tt3)

print(Pt4)
print(Tt4)
print(alpha)
print()

# turbine
Tt5 = Tt4 + (Tt0-Tt3)/(1+alpha)
Pt5 = Pt4 * (Tt5/Tt4)**((gamma)/(gamma-1))

print(Pt5)
print(Tt5)
print()

### 4)
P9 = P0
Pt9 = Pt5
Tt9 = Tt5

M9 = np.sqrt( 2/(gamma-1) * ( (Pt9/P9)**((gamma-1)/gamma) -1 ) )

T9 = Tt9 / (1+(gamma-1)/2 * M9**2)

V9 = V(T9, M9)
Fmot_spec = ((1+alpha)*V9 - V0) # F_mot / m_point

print("--- 4) ---")
print(Fmot_spec)
print()

### 5) à 7)
# spécifique <=> divisé par m_point
W_point_chim_sp = alpha*Pk
W_point_cy_sp = V9**2 / 2 - V0**2 / 2
W_point_pr_sp = Fmot_spec * V0

print("--- 5) à 7) ---")
print(W_point_chim_sp)
print(W_point_cy_sp)
print(W_point_pr_sp)
print()

### 8)
rend_th = W_point_cy_sp / W_point_chim_sp
rend_pr = W_point_pr_sp / W_point_cy_sp
rend_thpr = rend_th * rend_pr

print("--- 8) ---")
print(rend_th)
print(rend_pr)
print(rend_thpr)
print()

### 9) et 10)
Fnet = 21000
m_point = Fnet / Fmot_spec

rapp_moyeu = 0.35
Pt2 = Pt0
Tt2 = Pt0
M2 = 0.6
m_r_point = np.sqrt(gamma) * M2 * (1 + (gamma-1)/2 * M2**2)**((gamma+1)/(2-2*gamma))
A2 = m_point / m_r_point * np.sqrt(r*Tt2) / Pt2
diam2 = 2 * np.sqrt( A2 / (np.pi - 0.35**2 * np.pi) )

print("--- 9 et 10 ---")
print(m_point)
print()
print(diam2)
print()

### 11 à 14
#OPR : overall pressure ratio (taux de compression)
#TET : temperature entrée turbine = Tt4

def W_pr_sp(TET, OPR):
    M0 = 0.8
    P0 = 22700
    T0 = 217
    
    Tt0 = Tt(T0, M0)
    Pt0 = Pt(P0, M0)
    V0 = V(T0, M0)

    gamma = 1.4
    r =  287.1
    Pk = 42.8*10**6
    h = 0
    
    Pt3 = OPR * Pt0
    Tt3 = Tt0 * OPR**((gamma-1)/gamma)
    
    Pt4 = Pt3
    Tt4 = TET    
    Cp = (gamma*r)/(gamma-1)
    alpha  = Cp/Pk * (Tt4 - Tt3)
    
    Tt5 = Tt4 + (Tt0-Tt3)/(1+alpha)
    Pt5 = Pt4 * (Tt5/Tt4)**((gamma)/(gamma-1)) 
    
    P9 = P0
    Pt9 = Pt5
    Tt9 = Tt5

    M9 = np.sqrt( 2/(gamma-1) * ( (Pt9/P9)**((gamma-1)/gamma) -1 ) )

    T9 = Tt9 / (1+(gamma-1)/2 * M9**2)

    V9 = V(T9, M9)
    Fmot_spec = ((1+alpha)*V9 - V0) # F_mot / m_point
    
    return Fmot_spec * V0

def rendm_th(TET, OPR):
    M0 = 0.8
    P0 = 22700
    T0 = 217

    gamma = 1.4
    r =  287.1
    Pk = 42.8*10**6
    h = 0
    
    Pt3 = OPR * Pt0
    Tt3 = Tt0 * OPR**((gamma-1)/gamma)
    
    Pt4 = Pt3
    Tt4 = TET
    Cp = (gamma*r)/(gamma-1)
    alpha  = Cp/Pk * (Tt4 - Tt3)
    
    Tt5 = Tt4 + (Tt0-Tt3)/(1+alpha)
    Pt5 = Pt4 * (Tt5/Tt4)**((gamma)/(gamma-1)) 
    
    P9 = P0
    Pt9 = Pt5
    Tt9 = Tt5

    M9 = np.sqrt( 2/(gamma-1) * ( (Pt9/P9)**((gamma-1)/gamma) -1 ) )

    T9 = Tt9 / (1+(gamma-1)/2 * M9**2)

    V9 = V(T9, M9)
    Fmot_spec = ((1+alpha)*V9 - V0) # F_mot / m_point
    
    W_point_chim_sp = alpha*Pk
    W_point_cy_sp = V9**2 / 2 - V0**2 / 2
    
    return W_point_cy_sp / W_point_chim_sp
        
def rendm_pr(TET, OPR):
    M0 = 0.8
    P0 = 22700
    T0 = 217

    gamma = 1.4
    r =  287.1
    Pk = 42.8*10**6
    h = 0
    
    Pt3 = OPR * Pt0
    Tt3 = Tt0 * OPR**((gamma-1)/gamma)
    
    Pt4 = Pt3
    Tt4 = TET
    Cp = (gamma*r)/(gamma-1)
    alpha  = Cp/Pk * (Tt4 - Tt3)
    
    Tt5 = Tt4 + (Tt0-Tt3)/(1+alpha)
    Pt5 = Pt4 * (Tt5/Tt4)**((gamma)/(gamma-1)) 
    
    P9 = P0
    Pt9 = Pt5
    Tt9 = Tt5

    M9 = np.sqrt( 2/(gamma-1) * ( (Pt9/P9)**((gamma-1)/gamma) -1 ) )

    T9 = Tt9 / (1+(gamma-1)/2 * M9**2)

    V9 = V(T9, M9)
    Fmot_spec = ((1+alpha)*V9 - V0) # F_mot / m_point
    
    W_point_chim_sp = alpha*Pk
    W_point_cy_sp = V9**2 / 2 - V0**2 / 2
    
    return W_point_pr_sp / W_point_cy_sp

print("--- 11 à 14 ---")
array_OPR = np.linspace(5, 50, 100)
array_TET = np.linspace(1000, 2000, 5)
array_W_pr_sp = np.zeros((100, 5))

for i in range(5):
    for j in range(100):
        array_W_pr_sp[j, i] = W_pr_sp(array_TET[i], array_OPR[j])

fig = plt.figure()
ax1 = fig.add_subplot(1,1,1)

for i in range(5):
    ax1.plot(array_OPR, array_W_pr_sp[:, i])
    
plt.show()



