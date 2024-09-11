#include <iostream>
using namespace std;

#include "../src/int_LL.cpp"

// main

int main() {
    
    int_LL LL = create_empty_LL();

    print_LL( LL );
    cout << "\n";

    LL = add_to_beg_LL( 3, LL );
    LL = add_to_beg_LL( 5, LL );
    LL = add_to_beg_LL( 8, LL );

    print_LL( LL );

    LL = add_to_end_LL( 13, LL );

    print_LL( LL );
    cout << "\n";

    LL = tail_LL( LL );

    print_LL( LL );
    cout << "\n";

    LL = add_to_beg_LL( 3, LL );
    LL = add_to_beg_LL( 5, LL );
    LL = add_to_beg_LL( 8, LL );

    print_LL( LL );

    LL = remove_LL( 1, LL );

    print_LL( LL ); 
    print_backwards_LL( LL );
    cout << "\n";

    LL = change_LL( 100, 3, LL );

    print_LL( LL ); 
    print_backwards_LL( LL );
    cout << "\n";

    LL = add_LL( 50, 4, LL );

    print_LL( LL ); 
    print_backwards_LL( LL );
    cout << "\n";

    return 0;
}
