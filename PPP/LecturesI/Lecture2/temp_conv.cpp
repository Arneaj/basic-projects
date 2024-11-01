#include <iostream> // for cin and cout
#include <cmath> // for math functions

using namespace std; // standard names for functions

float fahrenheit_to_celsius( int temp ) {
  return ( temp - 32.0 ) * 5.0 / 9.0;
}

int main() {

  int fahrenheit_temp;
  float celsius_temp;
  float kelvin_temp;

  int fahrenheit_lower_bound;
  int fahrenheit_higher_bound;
  int fahrenheit_step;

  cout << "How low do you want the Fahrenheit to go :" << endl;
  cin >> fahrenheit_lower_bound;

  cout.setf(ios::fixed);
  cout.setf(ios::showpoint);
  cout.precision(2);

  cout << "How high do you want the Fahrenheit to go :" << endl;
  cin >> fahrenheit_higher_bound;

  cout << "What step size do you want :" << endl;
  cin >> fahrenheit_step;
  
  cout << "Table of values in Fahrenheit, Celsius and Kelvin from "
       << fahrenheit_lower_bound << "°F"
       << " to " << fahrenheit_higher_bound << "°F"
       << " with a step of " << fahrenheit_step << "°F" << endl << endl;

  cout << "Fahrenheit \tCelsius \tKelvin" << endl << endl;

  for (int T = fahrenheit_lower_bound; T <= fahrenheit_higher_bound; T += fahrenheit_step) {
    
    fahrenheit_temp = T;
    celsius_temp = fahrenheit_to_celsius( T );
    kelvin_temp = fahrenheit_to_celsius( T ) + 273.15;

    cout << fahrenheit_temp << "\t\t" << celsius_temp << "\t\t" << kelvin_temp << endl;
  }
  
  return 0;
}


