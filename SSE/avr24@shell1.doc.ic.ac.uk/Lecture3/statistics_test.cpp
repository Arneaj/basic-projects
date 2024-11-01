#include<iostream>
#include<cmath>
#include"statistics.h"

using namespace std;

void one_test_value() {
  double n1;
  
  cout << "Enter first value: " << endl;
  cin >> n1;

  cout << "Average: " << average(n1) << ". Standard deviation: " << standard_deviation(n1) << ".\n";

  return;
}

void two_test_values() {
  double n1;
  double n2;
  
  cout << "Enter first value: " << endl;
  cin >> n1;

  cout << "Enter second value: " << endl;
  cin >> n2;
  
  cout << "Average: " << average(n1, n2) << ". Standard deviation: " << standard_deviation(n1, n2) << ".\n";

  return;
}

void three_test_values() {
  double n1;
  double n2;
  double n3;

  cout << "Enter first value: " << endl;
  cin >> n1;

  cout << "Enter second value: " << endl;
  cin >> n2;

  cout << "Enter third value: " << endl;
  cin >> n3;
  
  cout << "Average: " << average(n1, n2, n3) << ". Standard deviation: " << standard_deviation(n1, n2, n3) << ".\n";

  return;
}

void four_test_values() {
  double n1;
  double n2;
  double n3;
  double n4;

  cout << "Enter first value: " << endl;
  cin >> n1;

  cout << "Enter second value: " << endl;
  cin >> n2;

  cout << "Enter third value: " << endl;
  cin >> n3;

  cout << "Enter fourth value: " << endl;
  cin >> n4;
  
  cout << "Average: " << average(n1, n2, n3, n4) << ". Standard deviation: " << standard_deviation(n1, n2, n3, n4) << ".\n";        
  return;
}

void wrong_test_values() {
  cout << "Sorry, the program can only test 1, 2, 3 or 4 values." << endl;
}

int main() {

  int nb_of_numbers;
  bool continue_loop = true;
  
  cout << "This program tests the functions in the 'statistics.h' header file." << endl << endl;

  while (continue_loop) {
  
    cout << "Do you wish to test 1, 2, 3 or 4 numbers (enter 0 to end the program): ";
    cin >> nb_of_numbers;

    cout << endl;

    switch(nb_of_numbers) {
    case 1:
      one_test_value();
      break;
    case 2:
      two_test_values();
      break;
    case 3:
      three_test_values();
      break;
    case 4:
      four_test_values();
      break;
    case 0:
      continue_loop = false;
      break;
    default:
      wrong_test_values();      
    }

  }
  
  cout << "Finished testing 'statistics.h' header file." << endl;

  return 0;
}
