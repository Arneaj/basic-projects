#include<iostream>
#include<cstring>
#include"str_compare.h"
using namespace std;

bool str_less_than( char str1[], char str2[] ) {
    
    for (int i = 0; ; i++) {
        if ( str1[i] == '\0' ) return true;
        if ( str2[i] == '\0' ) return false;

        if ( str1[i] == str2[i] ) continue;

        return str1[i] < str2[i];
    }
}

bool str_less_than_ptr( char* str1, char* str2 ) {
    
    for (int i = 0; ; i++) {
        if ( *(str1+i) == '\0' ) return true;
        if ( *(str2+i) == '\0' ) return false;

        if ( *(str1+i) == *(str2+i) ) continue;

        return *(str1+i) < *(str2+i);
    }
}
