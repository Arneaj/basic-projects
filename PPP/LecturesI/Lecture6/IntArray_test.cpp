#include<iostream>
#include"IntArray.h"
using namespace std;

int main() {
  int array[10];

  zero_out( array, 10 );

  display_array( array, 10 );

  input_array( array, 5 );

  display_array( array, 10 );

  cout << "Average of first 5: " << average( array, 5 ) << endl;
  cout << "Average: " << average( array, 10 ) << endl;

  cout << "Standard deviation: " << standard_deviation( array, 10 ) << endl;
  
  return 0;
}

