#include<iostream>
#include"pyramid.h"

using namespace std;


int main() {

  bool continue_loop = true;
  int height;
  
  cout << "Test program pyramid.cpp (enter 0 to exit program)" << endl << endl;

  while (continue_loop) {
    cout << "Enter a height: ";
    cin >> height;

    if (height == 0) break;
    
    cout << endl;

    print_pyramid(height);

    cout << endl;
  }

  cout << "Finished testing program pyramid.cpp." << endl;
  
  return 0;
}
