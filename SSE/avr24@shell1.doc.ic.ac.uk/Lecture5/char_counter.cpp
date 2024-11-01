#include<iostream>
#include<fstream>
using namespace std;

void print_char_counter(ifstream& input) {
  int place_in_ascii = 1;
  int occurence;
  
  char read_char;

  cout.setf(ios::left);
  cout.width(20);
  
  cout << "Character";

  cout << "Occurence" << endl;  
  
  while(place_in_ascii < 128) {      
    occurence = 0;
    
    while(!input.eof()) {
      read_char = input.get();
      
      if ( (int) read_char == place_in_ascii ) occurence++;
    }

    input.clear();
    input.seekg(0);

    if (occurence > 0) {
      cout.width(20);
      
      if (place_in_ascii == 10) cout << "NEW LINE";
      else if (place_in_ascii == 32) cout << "SPACE";
      else {
        cout << (char) place_in_ascii;
      }

      cout << occurence << endl;
    }
    
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

