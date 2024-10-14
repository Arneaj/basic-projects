#include<iostream>
#include"matrix_mult.h"
using namespace std;

void matrix_mult( int mat1[][N], int mat2[][R], int mat_res[][R]) {

    for (int m = 0; m < M; m++) {
        for (int r = 0; r < R; r++) {
            mat_res[m][r] = 0; 

            for (int n = 0; n < N; n++) {
                mat_res[m][r] += mat1[m][n] * mat2[n][r];
            }
        }
    }
}

void print_matrix1( int mat[][N] ) {
    
    for (int m = 0; m < M; m++) {
        cout.width(20);

        for (int n = 0; n < N; n++)
            cout << mat[m][n] << ' ';

        cout << endl;
    }
}

void print_matrix2( int mat[][R] ) {
    
    for (int n = 0; n < N; n++) {
        cout.width(20);

        for (int r = 0; r < R; r++)
            cout << mat[n][r] << ' ';

        cout << endl;
    }
}


void print_matrix3( int mat[][R] ) {
    
    for (int m = 0; m < M; m++) {
        cout.width(20);

        for (int r = 0; r < R; r++)
            cout << mat[m][r] << ' ';

        cout << endl;
    }
}
