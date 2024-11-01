#include<iostream>
#include<cmath>
#include"statistics.h"

using namespace std;

// definition of average function

double average(double n1) {
  return n1;
}

double average(double n1, double n2) {
  return (n1+n2)/2.0;
}

double average(double n1, double n2, double n3) {
  return (n1+n2+n3)/3.0;
}

double average(double n1, double n2, double n3, double n4) {
  return (n1+n2+n3+n4)/4.0;
}

// definition of standard deviation function

double standard_deviation(double n1) {
  return 0;
}

double standard_deviation(double n1, double n2) {
  double a = average(n1, n2);

  return sqrt( average( (n1-a)*(n1-a), (n2-a)*(n2-a) ) );
}

double standard_deviation(double n1, double n2, double n3) {
  double a = average(n1, n2, n3);

  return sqrt( average( (n1-a)*(n1-a), (n2-a)*(n2-a), (n3-a)*(n3-a) ) );
}

double standard_deviation(double n1, double n2, double n3, double n4) {
  double a = average(n1, n2, n3, n4);

  return sqrt( average( (n1-a)*(n1-a), (n2-a)*(n2-a), (n3-a)*(n3-a), (n4-a)*(n4-a) ) );
}

