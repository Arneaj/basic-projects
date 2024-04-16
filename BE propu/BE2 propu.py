import numpy as np
import matplotlib.pyplot as plt

gamma = 1.4
gamma_etoile=1.33

r =  287
r_etoile = 291.6

Pk=141860000

F_visee = 21000

ksi_e = 0.98
ksi_cc = 0.95
ksi_tuy = 0.98

#Lambda = 11 # m_point_s / m_point_p

rend_m = 0.98 # rend de l'arbre
rend_c = 0.9 # rend_pol du compresseur
rend_f = 0.92 # rend_pol du fan
rend_turb_HP = 0.89 # rend_pol_HP
rend_turb_BP = 0.9 # rend_pol_BP
rend_comb = 0.99 # rend combustion
"""
taux_comp_cF = 1.45 # taux comp fan
taux_comp_cHP = 22 # Pt3/Pt25
taux_comp_cTOT = 40 # Pt3/Pt2 -> fan + BP + HP
taux_comp_cBP = taux_comp_cTOT / (taux_comp_cHP*taux_comp_cF)
"""
M0 = 0.8
h = 35000
P0 = 22700
T0 = 217

Tt4 = 1600

## BASIC FUNCTIONS

def Tt(T, M):
    return T*(1+(gamma-1)/2 * M**2)

def T(Tt, M, gamma_loc):
    return Tt / (1+(gamma_loc-1)/2 * M**2)

def Pt(P, M):
    return P*(1+(gamma-1)/2 * M**2)**(gamma/(gamma-1))

def V(T, M, gamma_loc, r_loc):
    return np.sqrt(gamma_loc*r_loc*T) * M

def Cp_calc(gamma, r):
    return (gamma*r)/(gamma-1)

Cp = Cp_calc(gamma, r)
Cp_etoile = Cp_calc(gamma_etoile, r_etoile)

def m_R_point(M, gamma_loc):
    return np.sqrt(gamma_loc) * M * (1 + (gamma_loc-1)/2 * M**2)**((gamma_loc+1)/(2-2*gamma_loc))

def A(m_point, m_R_point, Tt, Pt):
    return m_point / m_R_point * np.sqrt(r*Tt) / Pt

def M(Pt, P, gamma_loc):
    return np.sqrt( 2/(gamma_loc-1) * ( (Pt/P)**((gamma_loc-1)/gamma_loc) -1 ) )

def alpha(Tt4, Tt3):
    return (Cp*Tt3 - Cp_etoile*Tt4)/(Cp_etoile*Tt4 - rend_comb*Pk)

def F_mot_spec(alpha, V9, V0):
    return (1+alpha)*V9 - V0


## FUNCTIONS

def entreedair(Tt0, Pt0, ksiE):
    Tt2 = Tt0
    Pt2 = ksiE * Pt0
    return Tt2, Pt2

def compresseur(Tt2, Pt2, taux_comp, rend_pol):
    Pt3 = Pt2 * taux_comp
    Tt3 = Tt2 * taux_comp**((gamma-1)/(gamma*rend_pol))
    return Tt3, Pt3

def combustion(TET, Pt3, ksiCC):
    Pt4 = ksiCC * Pt3
    Tt4 = TET
    return Tt4, Pt4

def turbine_1(Tt4, Pt4, rend_pol, rend_m, deltaTt, alpha):
        
    Tt5 = Tt4 - (Cp*deltaTt)/((1+alpha)*Cp_etoile*rend_m)
    
    taux_comp_turb = (Tt5/Tt4)**(gamma_etoile/(rend_pol*(gamma_etoile-1)))
    
    Pt5 = taux_comp_turb*Pt4
    return Tt5, Pt5

def turbine_2(Tt4, Pt4, rend_pol, rend_m, deltaTtBP, deltaTtfan, alpha, Lambda):
        
    Tt5 = Tt4 - Cp/(Cp_etoile*rend_m*(1+alpha)) * ( deltaTtBP + (1+Lambda)*deltaTtfan)
    
    taux_comp_turb = (Tt5/Tt4)**(gamma_etoile/(rend_pol*(gamma_etoile-1)))
    
    Pt5 = taux_comp_turb*Pt4
    return Tt5, Pt5

def tuyere(Tt5, Pt5, ksi_tuy):
    Tt9 = Tt5
    Pt9 = ksi_tuy*Pt5
    return Tt9, Pt9

## MAIN FUNCTIONS

def main( OPR=40, TET=1600, FanPR=1.45, BPR=11 ):
    
    V0 = V(T0, M0, gamma, r)
    Tt0 = Tt(T0, M0)
    Pt0 = Pt(P0, M0)
    
    Lambda = BPR # m_point_s / m_point_p
    
    taux_comp_cF = FanPR # taux comp fan
    taux_comp_cHP = 22 # Pt3/Pt25
    taux_comp_cTOT = OPR
    taux_comp_cBP = taux_comp_cTOT / (taux_comp_cHP*taux_comp_cF)
    
    ## primaire
    print("Primaire")

    Tt2, Pt2 = entreedair(Tt0, Pt0, ksi_e)
    print(Tt2, Pt2)

    Tt21, Pt21 = compresseur(Tt2, Pt2, taux_comp_cF, rend_f)
    print(Tt21, Pt21)
    
    Tt25, Pt25 = compresseur(Tt21, Pt21, taux_comp_cBP, rend_c)
    print(Tt25, Pt25)
    
    Tt3, Pt3 = compresseur(Tt25, Pt25, taux_comp_cHP, rend_c)
    print(Tt3, Pt3)
    
    Tt4, Pt4 = combustion(TET, Pt3, ksi_cc)
    alpha_c = alpha(Tt4, Tt3)
    print(Tt4, Pt4, alpha_c)
    
    Tt45, Pt45 = turbine_1(Tt4, Pt4, rend_turb_HP, rend_m, Tt3-Tt25, alpha_c)
    print(Tt45, Pt45)
    
    Tt5, Pt5 = turbine_2(Tt45, Pt45, rend_turb_BP, rend_m, Tt25-Tt21, Tt21-Tt2, alpha_c, Lambda)
    print(Tt5, Pt5)
    
    Tt9, Pt9 = tuyere(Tt5, Pt5, ksi_tuy)
    print(Tt9, Pt9)
    print()
    
    M9 = M(Pt9, P0, gamma_etoile) 
    T9 = T(Tt9, M9, gamma_etoile)  
    V9 = V(T9, M9, gamma_etoile, r_etoile)
    print(M9, T9, V9)
    
    F_mot_spec_1 = F_mot_spec(alpha_c, V9, V0)
    print(F_mot_spec_1)
    print()
    
    # secondaire 
    print("Secondaire")
    
    Tt17, Pt17 = Tt21, Pt21
    
    Tt19, Pt19 = tuyere(Tt17, Pt17, ksi_tuy)  
     
    M19 = M(Pt19, P0, gamma)    
    T19 = T(Tt19, M19, gamma)    
    V19 = V(T19, M19, gamma, r)
    
    print(Pt19, V19, T19, M19) 
    
    F_mot_spec_2 = F_mot_spec(0, V19, V0)
    print(F_mot_spec_2)
    print()
    
    # total
    print("Total")
    
    F_mot_spec_tot = F_mot_spec_1 * 1/(Lambda+1) + F_mot_spec_2 * Lambda/(Lambda+1)
    
    debit_0 = F_visee / F_mot_spec_tot
    debit_p = debit_0 / (1+Lambda)
    debit_s = debit_0 - debit_p
    debit_k = alpha_c * debit_p
     
    print(F_mot_spec_tot)
    print(debit_0, debit_p, debit_s, debit_k)
    print()
    
    # W et rendements
    print("Rendements")
    Pceff = 1/alpha_c * Cp * (Tt4-Tt3)
    
    W_point_cy_sp = 1/(Lambda+1) * ( (alpha_c+1)/2 * V9**2 - 1/2 * V0**2 ) + (Lambda)/(Lambda+1) * ( 1/2 * V19**2 - 1/2 * V0**2 )
    print(W_point_cy_sp)
    W_point_chim_sp = debit_k/debit_0 * Pk
    print(W_point_chim_sp)
    W_point_pr_sp = F_mot_spec_tot * V0
    print(W_point_pr_sp)
    
    rend_th = W_point_cy_sp / W_point_chim_sp
    rend_pr = W_point_pr_sp / W_point_cy_sp
    rend_thpr = rend_th * rend_pr
    
    print(rend_th, rend_pr, rend_thpr)
    print()
    
    # R_max
    print("Rmax en m")
    
    rapport_moyeu = 0.3
    M2 = 0.6
    debit_R = m_R_point( M2, gamma )
    A2 = A( debit_0, debit_R, Tt2, Pt2 )
    R2max = np.sqrt( A2 / (np.pi - rapport_moyeu**2 * np.pi) )
    
    print( R2max )
    print()
    
    # Conso carburant
    print("Conso carburant en kg/N/s")
    
    TSFC = debit_k / F_visee
    print(TSFC)
    print()
    
    # YES
    print("Masse et volume de carburant")
    rho_carburant = 70.973 # kg/m^3
    
    masse_carburant_par_h = debit_k * 3600
    volume_carburant_par_h = masse_carburant_par_h / rho_carburant
    print(masse_carburant_par_h, volume_carburant_par_h)
    print()
    
    return rend_thpr

"""
array_TET = np.linspace( 1200, 2000, 9 )
array_OPR = np.linspace( 15, 60, 100 )

array_rend_th = np.zeros( (100, 9) )

for tet in range(9):
    for opr in range(100):
        array_rend_th[opr, tet] = main( array_OPR[opr], array_TET[tet] )
    plt.plot( array_OPR, array_rend_th[:,tet], label="TET = {} K ".format(array_TET[tet]) )

plt.title("évolution du rendement thermique en fonction de OPR pour différents TET")
plt.xlabel("OPR")
plt.ylabel("rendement thermique")

plt.legend()

plt.show()


array_FanPR = np.linspace( 1.2, 3, 9 )
array_BPR = np.linspace( 0, 30, 100 )

array_rend_thpr = np.zeros( (100, 9) )

for fpr in range(9):
    for bpr in range(100):
        array_rend_thpr[bpr, fpr] = main( 40, 1600, array_FanPR[fpr], array_BPR[bpr] )
    plt.plot( array_BPR, array_rend_thpr[:,fpr], label="taux de fan = {}".format(array_FanPR[fpr]) )

plt.title("évolution du rendement global en fonction de BPR pour différents taux de fan")
plt.xlabel("BPR")
plt.ylabel("rendement global")

plt.legend()

plt.show()
"""

main()



