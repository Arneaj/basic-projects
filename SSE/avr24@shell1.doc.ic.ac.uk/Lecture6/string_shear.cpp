#include<iostream>
#include<cstring>
#include"string_shear.h"
using namespace std;

void no_repetitions(char str[]) {
    
    for (int i = strlen(str); i > 0; i--) {
        if ( is_present_before( str, i ) ) 
            remove_char( i, str );
    }

}

bool is_present_before( char str[], int pos ) {
    
    char character = str[pos];

    for (int i = 0; i < pos; i++) {
        if ( character == str[i] ) return true; 
    }

    return false;
}

void remove_char( int pos, char str[] ) {
    
    for (int i = pos; str[i] != '\0' ; i++) str[i] = str[i+1];

}







