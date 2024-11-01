#include<iostream>
#include"conversions.h"

using namespace std;

double to_celsius(int fahr)
{
    return (static_cast<double>(5)/9) * (fahr - 32);
}

double to_absolute_value(int fahr)
{
    return ((static_cast<double>(5)/9) * (fahr - 32)) + 273.15;
}

