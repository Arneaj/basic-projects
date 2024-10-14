/* This program prints out a conversion table of temperatures, after
prompting the user for upper and lower bounds of the table in
Fahrenheit, and the temperature difference between table entries. */ 

#include <iostream>
using namespace std;

/* FUNCTION DECLARATIONS */
double celsius_of(int);
double absolute_value_of(int);
void print_preliminary_message();
void input_table_specifications(int&, int&, int&);
void print_message_echoing_input(int, int, int);
void print_table(int, int, int);
/* END OF FUNCTION DECLARATION */

/* START OF MAIN PROGRAM */
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
/* END OF MAIN PROGRAM */

/* FUNCTION TO CONVERT FAHRENHEIT TO CELSIUS */
double celsius_of(int fahr)
{
	return (static_cast<double>(5)/9) * (fahr - 32);
}
/* END OF FUNCTION */

/* FUNCTION TO CONVERT FAHRENHEIT TO ABSOLUTE VALUE */
double absolute_value_of(int fahr)
{
	return ((static_cast<double>(5)/9) * (fahr - 32)) + 273.15;
}
/* END OF FUNCTION */

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
    celsius_temp = celsius_of( T );
    kelvin_temp = absolute_value_of( T );

    cout << fahrenheit_temp << "\t\t" << celsius_temp << "\t\t" << kelvin_temp << endl;
  }

}

