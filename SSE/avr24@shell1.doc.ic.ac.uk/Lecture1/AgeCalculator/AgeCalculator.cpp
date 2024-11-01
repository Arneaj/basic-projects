#include <iostream> 
using namespace std; 

int main() 
{ 
  int year_now, age_now, month_now, birth_month, another_year, another_month, another_age_year, another_age_months;
 
	cout << "Enter the current year then press RETURN.\n"; 
	cin >> year_now;

	cout << "Enter the current month (between 1 and 12)." << endl;
	cin >> month_now;
 
	cout << "Enter your current age in years.\n"; 
	cin >> age_now;

	cout << "Enter the month you were born." << endl;
	cin >> birth_month;
	
	cout << "Enter the year for which you wish to know your age.\n";
	cin >> another_year;

	cout << "Enter the month" << endl;
	cin >> another_month;
	
	another_age_year = another_year - (year_now - age_now);
	another_age_months = another_month - (month_now - birth_month);

	if (another_age_months > 12) {
	  another_age_year++;
	  another_age_months -= 12;
	}
	if (another_age_months < 0) {
	  another_age_year--;
	  another_age_months += 12;
	}
	
	if (another_age_year >= 0) {
		if (another_age_year > 150) {
			cout << "Sorry, you'll probably be dead by " << another_year << endl;
		} else {
		  cout << "Your age in year " << another_year << " month " << another_month << ": "; 
		  cout << another_age_year << ", " << another_age_months << "months" << "\n";
		}
	} else { 
		cout << "You weren't even born in ";
		cout << another_year << "!\n"; 
	}
	
	return 0; 

}







