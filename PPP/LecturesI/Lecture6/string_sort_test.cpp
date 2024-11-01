#include<iostream>
#include"string_sort.h"
using namespace std;

int main() {
    
    const int MAX_LENGTH = 80;

    char str[MAX_LENGTH];

    cout << "Type in a string: ";
    cin.getline(str, MAX_LENGTH);

    string_sort( str );

    cout << "The sorted string is: " << str << endl;

    return 0;
}

