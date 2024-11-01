#include<iostream>
#include"string_shear.h"
using namespace std;

int main() {
    
    char str[MAX_LENGTH];

    cout << "Type in a string to shear: ";
    cin.getline( str, MAX_LENGTH );

    no_repetitions( str );

    cout << "The sheared string is: " << str << endl;

    return 0;
}

