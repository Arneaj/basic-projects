#include<iostream>
#include<fstream>
using namespace std;

int file_length( string name ) {
  int occurence = 0;

  ifstream input;
  input.open(name);

  while (!input.eof()) {
    input.get();
    occurence++;
  }

  input.close();
  
  return occurence;
}

void print_backwards( string name ) {
  int length = file_length(name);

  ifstream input;
  input.open(name);

  char read_char;
  
  for (int i = length; i>=0; i--) {
    input.seekg(i);
    read_char = input.peek();

    cout.put(read_char);
  }

  cout << endl;
  
  input.close();
}

int main() {
  string name = "backwards.cpp";

  print_backwards(name);
  
  return 0;
}

