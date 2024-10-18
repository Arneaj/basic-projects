#include<iostream>
#include"inf_precision.h"
using namespace std;

class inf_float {
    public:
        uint length;
        
        int e_exp;

        uint8_t* digit_pairs;

        inf_float( uint len, int exp ) {
            length = len;
            e_exp = exp;

            digit_pairs = new uint8_t[length]();
        }

        void print() {
            cout << digit_pairs[0] << ".";
            for (int i = 1; i < length / 2; i++) {
                cout << digit_pairs[i];
            }
            cout << endl;
        }

        inf_float add( inf_float other_nb ) {
            int exp = max( e_exp, other_nb.e_exp );

            int len = 1;

            inf_float new_nb( exp, len );

            bool even = length % 2 == 0;

            for (int i = length / 2 - 1 + even; i >= 0; i--) {

            }

            return new_nb;
        }
};


