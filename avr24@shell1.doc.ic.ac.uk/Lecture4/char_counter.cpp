#include<iostream>
#include<fstream>
using namespace std;

void print_char_counter(ifstream& input) {
  int place_in_ascii = 97;
  int occurence;
  
  char read_char;

  cout << "Character";

  cout.width(20);
  cout << "Occurence" << endl;  
  
  while(place_in_ascii < 123) {      
    occurence = 0;
    
    while(!input.eof()) {
      input >> read_char;
      
      if ( (int) read_char == place_in_ascii ) occurence++;
    }

    input.clear();
    input.seekg(0);

    cout << (char) place_in_ascii;

    cout.width(20);
    cout << occurence << endl;
    
    place_in_ascii++;
  }
}

int main(int argc, char *argv[]) {
  ifstream input;

  if (argc > 1)
  {
    string file_name(argv[1]);

    input.open(file_name);

    print_char_counter( input );

    input.close();
  }
   
  return 0;
}

