#include <iostream>
using namespace std;

typedef int *IntPtrType;

int main()
{
    IntPtrType ptr_a, ptr_b, *ptr_c;

    ptr_a = new int;
    *ptr_a = 3;
    ptr_b = ptr_a;
    cout << *ptr_a << " " << *ptr_b << "\n";

    ptr_b = new int;
    *ptr_b = 9;
    cout << *ptr_a << " " << *ptr_b << "\n";

    *ptr_b = *ptr_a;
    cout << *ptr_a << " " << *ptr_b << "\n";

    delete ptr_a;
    ptr_a = ptr_b;
    cout << *ptr_a << " " << *&*&*&*&*ptr_b << "\n";

    ptr_c = &ptr_a;
    cout << *ptr_c << " " << **ptr_c << "\n";

    delete ptr_a;
    ptr_a = NULL;

    return 0;
}

