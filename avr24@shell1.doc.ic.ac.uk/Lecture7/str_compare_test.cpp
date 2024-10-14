#include<iostream>
#include"str_compare.h"
using namespace std;

int main() {
    
    int MAX_LENGTH = 80;

    char str1[MAX_LENGTH] = "camille";
    char str2[MAX_LENGTH] = "camomille";

    cout << str1 << " is ";
    if ( str_less_than(str1, str2) ) cout << "smaller";
    else cout << "bigger";
    cout << " than " << str2 << endl;

    cout << "I repeat, " << str1 << " is ";
    if ( str_less_than_ptr(str1, str2) ) cout << "smaller";
    else cout << "bigger";
    cout << " than " << str2 << endl;
    
    return 0;
}

