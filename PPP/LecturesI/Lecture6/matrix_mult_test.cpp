#include<iostream>
#include"matrix_mult.h"
using namespace std;

int main() {
    
    int mat1[M][N];
    int mat2[N][R];
    int mat_res[M][R];

    cout << "INPUT FIRST (" << M << "x" << N
         << ") MATRIX: " << endl;
    
    for (int m = 0; m < M; m++) {
        cout << "Type in " << N 
             << " values for row " << m 
             << " separated by spaces: ";
    
        for (int n = 0; n < N; n++) {
            cin >> mat1[m][n];
        }
    }

    cout << "INPUT SECOND (" << N << "x" << R
         << ") MATRIX: " << endl;
    
    for (int n = 0; n < N; n++) {
        cout << "Type in " << R 
             << " values for row " << n 
             << " separated by spaces: ";
    
        for (int r = 0; r < R; r++) {
            cin >> mat2[n][r];
        }
    }

    cout << endl;

    print_matrix1( mat1 );
    
    cout << "TIMES" << endl;

    print_matrix2( mat2 );

    cout << "EQUALS" << endl;

    matrix_mult( mat1, mat2, mat_res );

    print_matrix3( mat_res );

    return 0;
}

