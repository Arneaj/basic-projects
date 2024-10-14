#include<iostream>
#include"dichotomy.h"
using namespace std;

void print_list( int list[], int length ) {
    
    cout << "[ ";

    for (int i = 0; i < length; i++) cout << list[i] << ' ';

    cout << "]" << endl;
}

int main() {

    int length = 10;

    int list[length] = { 1, 2, 3, 4, 7, 8, 9, 13, 19, 22 };

    print_list( list, length );

    int start, end;

    cout << "Enter the first index to search in: ";
    cin >> start;

    cout << "Enter the last index to search in: ";
    cin >> end;

    for (int i = list[start]; i <= list[end]; i++)
        cout << "Index of " << i << " = " << dichotomy( i, list, start, end ) << endl;

    return 0;
}

