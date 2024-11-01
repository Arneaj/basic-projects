#include<iostream>
#include<fstream>
using namespace std;

void print_file_without_comments(ifstream& input, ofstream& output) {

  char current_char;

  bool is_in_comment = false;

  while(!input.eof()) {
    current_char = input.get();

    if ( !is_in_comment && (current_char == '/') && (input.peek() == '*') ) is_in_comment = true;

    if ( !is_in_comment ) output.put(current_char);
    
    if ( is_in_comment && (current_char == '*') && (input.peek() == '/') ) {
      input.get();
      input.get();
      is_in_comment = false;
    }
  }

  return;
}

int main() {
  cout << "Testing: " << 16/2 << " = " << 4*2 << ".\n\n";
  
  /* 
     haha this is a comment 
     I'm a failure
  */

  ifstream input;
  ofstream output;
  
  input.open("with_comments.cpp");
  output.open("without_comments.cpp");

  print_file_without_comments(input, output);

  input.close();
  output.close();

  /*
    comments again ??
    bro stop
  */
  
  return 0;
}

