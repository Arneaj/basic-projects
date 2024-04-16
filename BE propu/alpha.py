gamma = 1.4
gamma_etoile=1.33

r =  287.1
r_etoile=291.6

Pk=42800
rend_comb = 0.99 # rend combustion

def Cp_calc(gamma, r):
    return (gamma*r)/(gamma-1)

#Cp = Cp_calc(gamma, r)
#Cp_etoile = Cp_calc(gamma_etoile, r_etoile)

Cp=1004.5
Cp_etoile=1175.2

def alpha(Tt4, Tt3):
    return (Cp*Tt3 - Cp_etoile*Tt4)/(Cp_etoile*Tt4 - rend_comb*Pk)


alpha_c = alpha(1600, 787.5)

alpha_d = (Cp*787.5 - Cp_etoile*1600.)/(Cp_etoile*1600. - rend_comb*Pk)

print(alpha_d)