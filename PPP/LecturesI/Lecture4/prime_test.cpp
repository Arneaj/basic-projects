#include<iostream>
#include<cmath>
#include"prime.h"

using namespace std;

int main() {

  bool continue_loop = true;
  int nb;
  
  cout << "Testing the prime.cpp program. (enter 0 to end the program)" << endl << endl;

  while (continue_loop) {
    cout << "Enter a number to check if it's prime: ";
    cin >> nb;

    if (nb == 0) break;

    bool primality = is_prime_and_less_than_1000(nb);
    
    if (primality) cout << "The number " << nb << " is prime and smaller than 1000." << endl << endl;
    else cout << "The number " << nb << " is not prime or is bigger than 1000." << endl << endl;
  }

  cout << "End of test of program prime.cpp." << endl;

  return 0;
}
