#include<iostream>
#include"inf_precision.h"
using namespace std;

class inf_precision_number {
    public:
        int length;
        int floating_point_pos;

        u_int8_t* digit_pairs;

        inf_precision_number( int len, int fpp ) {
            length = len;
            floating_point_pos = fpp;

            digit_pairs = new u_int8_t[length / 2 + 1];

            for (int i = 0; i < length / 2 + 1; i++) {
                digit_pairs[i] = 0;
            }
        }

        void set_digits( u_int8_t d_pairs[] ) {
            for (int i = 0; i < length / 2 + 1; i++) {
                digit_pairs[i] = d_pairs[i];
            }
        }

        inf_precision_number add( inf_precision_number other_nb ) {
            inf_precision_number new_nb( max( length, other_nb.length ), floating_point_pos );

            
        }
};
