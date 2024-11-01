#include<iostream>
#include"gcd.h"
using namespace std;

int gcd( int m, int n ) {
    
    int big = max(m, n);
    int small = min(m, n);

    if ( small == 0 ) return big;
    if ( small == 1 ) return 1;
    
    return gcd( small, big-small );
}
