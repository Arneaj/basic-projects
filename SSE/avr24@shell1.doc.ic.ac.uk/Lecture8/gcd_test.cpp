#include<iostream>
#include"gcd.h"
using namespace std;

int main() {
    
    int first, second;

    cout << "Enter the first number : ";
    cin >> first;

    cout << "Enter the second number : ";
    cin >> second;

    cout << "The GCD of " << first 
         << " and " << second 
         << " is : " << gcd( first, second ) << endl;
    
    return 0;
}

