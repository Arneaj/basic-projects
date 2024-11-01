#include<iostream>
using namespace std;

int fib( int n ) {
    if (n < 1) {
        cout << "OOB error !" << endl;
        return -1;
    }

    if (n == 1 || n == 2) {
        return 1;
    }

    return fib( n-1 ) + fib( n-2 );
}

int main() {
    
    for (int i = 1; i < 10; i++)
        cout << fib(i) << endl;
    
    return 0;
}

