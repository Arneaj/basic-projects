#include<iostream>
#include<cmath>
#include"IntArray.h"
using namespace std;

void zero_out(int array[], int n) {
  for (int i = 0; i < n; i++) {
    array[i] = 0;
  }
}

void input_array(int array[], int n) {
  cout << "Enter " << n << " numbers." << endl << endl;
  
  for (int i = 0; i < n; i++) {
    cout << "array[" << i << "] = ";
    cin >> array[i];
  }
}

void display_array(int array[], int n) {
  cout << "array[0:" << n-1 << "] = { ";

  for (int i = 0; i < n-1; i++) {
    cout << array[i] << ", ";
  }

  cout << array[n-1] << " }." << endl;
}
 
void copy_array(int array1[], int array2[], int n) {
  for (int i = 0; i < n; i++) {
    array2[i] = array1[i];
  }
}

float average(int array[], int n) {
  int total = 0;

  for (int i = 0; i < n; i++) {
    total += array[i];
  }

  return (double) total / n;
}

float standard_deviation(int array[], int n) {
  int avg = average(array, n);
  int variance = 0;

  int current_int;
  
  for (int i = 0; i < n; i++) {
    current_int = array[i];
    variance += (current_int - avg)*(current_int - avg);
  }

  variance /= n;

  return sqrt( variance );
}

