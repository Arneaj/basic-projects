using Symbolics, LinearAlgebra, Latexify

function main()
    @variables O_1 O_2 O_3 L_1 L_2 L_3 alpha beta gamma delta epsilon mu E_1 S_1 I_1 E_2 S_2 I_2 E_3 S_3 I_3 A_1 B_1 C_1 D_1 A_2 B_2 C_2 D_2 A_3 B_3 C_3 D_3

    A = [-cos(O_1*L_1) -sin(O_1*L_1) -cosh(O_1*L_1) -sinh(O_1*L_1) 1 0 1 0 0 0 0 0;
        0 0 0 0 -cos(O_2*L_2) -sin(O_2*L_2) -cosh(O_2*L_2) -sinh(O_2*L_2) 1 0 1 0 ;
        1 0 1 0 0 0 0 0 -cos(O_3*L_3) -sin(O_3*L_3) -cosh(O_3*L_3) -sinh(O_3*L_3);
        O_1*sin(O_1*L_1) -O_1*cos(O_1*L_1) -O_1*sinh(O_1*L_1) -O_1*cosh(O_1*L_1) 0 O_2 0 O_2 0 0 0 0;
        0 0 0 0 O_2*sin(O_2*L_2) -O_2*cos(O_2*L_2) -O_2*sinh(O_2*L_2) -O_2*cosh(O_2*L_2) 0 beta*O_3 0 beta*O_3 ;
        0 alpha*O_1 0 alpha*O_1 0 0 0 0 O_3*sin(O_3*L_3) -O_3*cos(O_3*L_3) -O_3*sinh(O_3*L_3) -O_3*cosh(O_3*L_3);
        E_1*I_1*O_1^2*cos(O_1*L_1) E_1*I_1*O_1^2*sin(O_1*L_1) -E_1*I_1*O_1^2*cosh(O_1*L_1) -E_1*I_1*O_1^2*sinh(O_1*L_1) E_2*I_2*O_2^2 0 E_2*I_2*O_2^2 0 0 0 0 0;
        0 0 0 0 E_2*I_2*O_2^2*cos(O_2*L_2) E_2*I_2*O_2^2*sin(O_2*L_2) -E_2*I_2*O_2^2*cosh(O_2*L_2) -E_2*I_2*O_2^2*sinh(O_2*L_2) delta*E_3*I_3*O_3^2 0 delta*E_3*I_3*O_3^2 0 ;
        gamma*E_1*I_1*O_1^2 0 gamma*E_1*I_1*O_1^2 0 0 0 0 0 E_3*I_3*O_3^2*cos(O_3*L_3) E_3*I_3*O_3^2*sin(O_3*L_3) -E_3*I_3*O_3^2*cosh(O_3*L_3) -E_3*I_3*O_3^2*sinh(O_3*L_3);
        -E_1*I_1*O_1^3*sin(O_1*L_1) E_1*I_1*O_1^3*cos(O_1*L_1) -E_1*I_1*O_1^3*sinh(O_1*L_1) -E_1*I_1*O_1^3*cosh(O_1*L_1) 0 E_2*I_2*O_2^3 0 E_2*I_2*O_2^3 0 0 0 0;
        0 0 0 0 -E_2*I_2*O_2^3*sin(O_2*L_2) E_2*I_2*O_2^3*cos(O_2*L_2) -E_2*I_2*O_2^3*sinh(O_2*L_2) -E_2*I_2*O_2^3*cosh(O_2*L_2) 0 mu*E_3*I_3*O_3^3 0 mu*E_3*I_3*O_3^3 ;
        0 epsilon*E_1*I_1*O_1^3 0 epsilon*E_1*I_1*O_1^3 0 0 0 0 -E_3*I_3*O_3^3*sin(O_3*L_3) E_3*I_3*O_3^3*cos(O_3*L_3) -E_3*I_3*O_3^3*sinh(O_3*L_3) -E_3*I_3*O_3^3*cosh(O_3*L_3)]

    @variables k_1, k_2, k_3

    A1 = Matrix{Num}(
        substitute(
                A,
                Dict([  cos(O_1*L_1)=>(-1)^k_1, sin(O_1*L_1)=>0,
                        cos(O_2*L_2)=>(-1)^k_2, sin(O_2*L_2)=>0,
                        cos(O_3*L_3)=>(-1)^k_3, sin(O_3*L_3)=>0
                ])
        ),
    )

    L1,U1 = lu(A1)
    
    B1 = simplify(U1)*[A_1, B_1, C_1, D_1, A_2, B_2, C_2, D_2, A_3, B_3, C_3, D_3]

    BB1 = Vector{Num}(
        substitute(
                B1,
                Dict([  C_1=>0, D_1=>0,
                        C_2=>0, D_2=>0,
                        C_3=>0, D_3=>0
                ])
        ),
    )

    return latexify(simplify(BB1))

end

main()
