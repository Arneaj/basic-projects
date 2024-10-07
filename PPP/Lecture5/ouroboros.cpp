#include<iostream>
#include<fstream>
using namespace std;

void print_file(ifstream& input) {

  char current_char;
  
  while(!input.eof()) {
    input.get(current_char);
    cout << current_char;
  }
  
  return;
}

int main() {
  
  ifstream input;

  input.open("ouroboros.cpp");

  print_file(input);

  input.close();
  
  return 0;
}

