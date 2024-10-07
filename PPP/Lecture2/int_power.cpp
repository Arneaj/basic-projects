
#include <iostream>

using namespace std;

int main() {
  
  float x;
  int n;

  float result = 1;

  cout << "Enter a number x = ";
  cin >> x;

  cout << "Raised to the positive integer power n = ";
  cin >> n;

  for (int i = 0; i < n; i++) {
    result *= x;
  }

  cout << "x^n = " << result << endl; 

  
  return 0;
}
