#include<iostream>
#include"dichotomy.h"
using namespace std;

int dichotomy( int value, int list[], int start, int end ) {
    
    if ( value < list[start] || value > list[end] ) return -1;

    int length = end - start;

    if ( length == 2 && value == list[end] ) return end; 

    int half_point = start + length / 2;

    if ( value == list[half_point] ) return half_point;

    if ( length == 1 ) return -1;

    if ( value < list[half_point] ) return dichotomy( value, list, start, half_point );

    if ( value > list[half_point] ) return dichotomy( value, list, half_point, end );

    return -1;
}


