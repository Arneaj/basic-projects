#include<iostream>

using namespace std;

#define SPACE ' '
#define STAR '*'

void print_pyramid(int height) {

  for (int i = 1; i <= height; i++) {
    for (int j = 1; j <= height - i; j++) cout << SPACE;
    for (int j = 1; j <= i; j++) cout << STAR << STAR;
    for (int j = 1; j <= height - i; j++) cout << SPACE;

    cout << endl;
  }

  return;
}


