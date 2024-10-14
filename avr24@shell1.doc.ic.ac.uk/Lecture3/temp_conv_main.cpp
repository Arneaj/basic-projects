#include<iostream>
#include"conversions.h"

using namespace std;

void print_preliminary_message();
void input_table_specifications(int&, int&, int&);
void print_message_echoing_input(int, int, int);
void print_table(int, int, int);

int main()
{
    int lower = 0; /* the lowest Fahrenheit entry in the table */
    int upper = 0; /* the highest Fahrenheit entry in the table */
    int step = 1;  /* difference in Fahrenheit between entries */

    /* print a message explaining what the program does: */
    print_preliminary_message();

    /* prompt the user for table specifications in Fahrenheit: */
    input_table_specifications(lower, upper, step);

    /* print appropriate message including an echo of the input: */
    print_message_echoing_input(lower, upper, step);

    /* Print the table (including the column headings): */
    print_table(lower, upper, step);

    return 0;
}

void print_preliminary_message() {
  cout << "This program prints out a conversion table of temperatures." << endl << endl;

    return ;
}

void input_table_specifications( int& lower_fahr, int& higher_fahr, int& fahr_step ) {

  cout << "Enter the minimum (whole number) temperature you want in the table, in Fahrenheit: ";
  cin >> lower_fahr;

  cout << "Enter the maximum temperature you want in the table: ";
  cin >> higher_fahr;

  cout << "Enter the temperature difference you want between table entries: ";
  cin >> fahr_step;
  
  cout << endl;
}

void print_message_echoing_input( int lower_fahr, int higher_fahr, int fahr_step ) {

  cout << "Tempertature conversion table from "
       << lower_fahr << " Fahrenheit to "
       << higher_fahr << " Fahrenheit, in steps of "
       << fahr_step << " Fahrenheit:" << endl << endl;

}

void print_table( int lower_fahr, int higher_fahr, int fahr_step ) {
  int fahrenheit_temp;
  float celsius_temp;
  float kelvin_temp;

  cout << "Fahrenheit \tCelsius \tKelvin" << endl << endl;

  cout.setf(ios::fixed);
  cout.setf(ios::showpoint);
  cout.precision(2);

  for (int T = lower_fahr; T <= higher_fahr; T += fahr_step) {

    fahrenheit_temp = T;
    celsius_temp = to_celsius( T );
    kelvin_temp = to_absolute_value( T );

    cout << fahrenheit_temp << "\t\t" << celsius_temp << "\t\t" << kelvin_temp << endl;
  }

}


