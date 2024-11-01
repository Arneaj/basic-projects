#include <iostream>
#include "substring.h"

using namespace std;

int main() {
  cout << substring_position_short("this", "this is a simple exercise") << endl;
  cout << substring_position_short("is", "this is a simple exercise") << endl;
  cout << substring_position_short("is a", "this is a simple exercise") << endl;
  cout << substring_position_short("is an", "this is a simple exercise") << endl;
  cout << substring_position_short("exercise", "this is a simple exercise") << endl;
  cout << substring_position_short("simple exercise", "this is a simple") << endl;
  cout << substring_position_short("", "this is a simple exercise") << endl;
  cout << substring_position_short("", "") << endl;
  return 0;
}