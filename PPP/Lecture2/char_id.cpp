#include <iostream> // for cin and cout
#include <cmath> // for math functions

using namespace std; // standard names for functions

int main() {

    char char_input;

    cout << "Enter a character :" << endl;
    cin >> char_input;

    
    if ( ( char_input >= 'A' ) && ( char_input <= 'Z' ) ) {
      cout << "The lowercase character corresponding to "
	   << char_input << " is : " << (char) (char_input + 32) << endl ;
    } else if ( ( char_input >= 'a' ) && ( char_input <= 'z' ) ) {
      cout << "The uppercase character corresponding to "
	   << char_input << " is : " << (char) (char_input - 32) << endl ;
    } else {
      cout << "Your character is not a letter." << endl;
    }

    return 0;
}
