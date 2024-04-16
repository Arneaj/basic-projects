import numpy as np

P_c	= 1.40E+07
r_c	= 5.92E+02
T_c	= 3.60E+03
m_c_point	= 1.00E+03
lambda_c	= 3.50E-01
mu_c	= 6.40E-05
R_c	= 2.60E-01
T_f	= 6.00E+01
Pr_f = 0.7
l	= 1.00E-02
e1	= 2.00E-03
e2	= 2.00E-03
lambda_cu	= 3.84E+02

gamma	= 1.25E+00
T_p	= 7.00E+02
A_lambda	= 2.05E-04
B_lambda	= 1.23E-01
A_mu	= 2.75E-08
B_mu	= 5.00E-07
A_rho	= -3.46E-02
B_rho	= 2.12E+01

# functions

def rho( P, r, T ):
    return P/(r*T)

def V( m_point, rho, R ):
    return m_point/(rho*3.141592*R**2)

def Cp( gamma, r ):
    return gamma*r/(gamma-1)

def Re( rho, V, R, mu ):
    return rho*V*R*2/mu

def Pr( mu, Cp, Lambda ):
    return mu*Cp/Lambda

def Nu( Re, Pr ):
    return 0.023*Re**0.8*Pr**0.43

def h( Lambda, Nu, R ):
    return Lambda*Nu/(2*R)

def Phi( h, Tp, T ):
    return h*(Tp-T)

def A_calc(phi, R):
    return phi*R

def T_e(A, Lambda, e, R, B):
    return A/Lambda * np.log(1+e/R) + B

def Phi_5(eta_f, h_f, T_e2, Tf):
    return -1/2*(1+eta_f)*h_f*(T_e2-Tf)

def D_h(S, P):
    return 4*S/P

def h_bis(phi, T_e2, Tf):
    return -2*phi/(T_e2-Tf)

def Re_bis(h, D_h, Pr, Lambda):
    return (h*D_h/(0.023*Lambda*Pr**(1/3)))**(1/0.8)

def Bi(h, S, Lambda, P):
    return h*S/(Lambda*P)

def m_point(Re, mu, l, e, D_h):
    return Re*mu*l*e/D_h

# main

rho_c = rho(P_c, r_c, T_c)
V_c = V(m_c_point, rho_c, R_c)
C_p_c = Cp(gamma, r_c)

Re_c = Re(rho_c, V_c, R_c, mu_c)
Pr_c = Pr(mu_c, C_p_c, lambda_c)

Nu_c = Nu(Re_c, Pr_c)#; print(Nu_c)
h_c = h(lambda_c, Nu_c, R_c)
phi_c = Phi(h_c, T_p, T_c)#; print(phi_c)

B = 700
A = A_calc(phi_c, R_c)#; print(A)
T_e2 = T_e(A, lambda_cu, e2, R_c, B)#; print(T_e2)

h_f = h_bis(phi_c, T_e2, T_f)#;print(h_f)

T_film = (T_e2 + T_f)/2
mu_f = 2.75*10**(-8)*T_film+5*10**(-7)#; print(mu_f)
lambda_f = 2.05*10**(-4)*T_film + 0.123#; print(lambda_f)

Bi_f = Bi(h_f, e1*l, lambda_cu, 2*(e1+l) )#; print(Bi_f)

D_h_f = D_h(e1*l, 2*(e1+l))#; print(D_h_f)
Re_f = Re_bis(h_f, D_h_f, Pr_f, lambda_f)#; print(Re_f)
m_point_f = m_point(Re_f, mu_f, l, e1, D_h_f)#; print(m_point_f)

N_c = 3.141592*R_c/e1#; print(N_c)
m_point_f_tot = round(N_c) * m_point_f#; print(m_point_f_tot)

F12 = 1
F11 = 0

















