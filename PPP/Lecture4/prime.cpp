#include<iostream>
#include<cmath>
#include"prime.h"

using namespace std;

bool is_prime(int nb) {
 
  if (nb <= 1) return false;
  
  for (int i=2; i < floor( sqrt(nb) )+1; i++)
    if ( nb%i == 0) return false;

  return true;
}

bool is_prime_and_less_than_1000(int nb) {
  return is_prime(nb) && (nb <= 1000);
}
