#include <iostream>
using namespace std;

struct int_cell {
    int value;

    int_cell* next_cell;
    int_cell* previous_cell;
};

struct int_list {
    int_cell* first_cell;
    int_cell* last_cell;
};

int_list 

int main() {
    
    int number;

    cout << "x = ";
    cin >> number;
    cout << "x^2 = " << number*number << "\n";

    return 0;
}




















