#include<iostream>
#include<vector>
#include<bitset>
#include<cmath>
#include"inf_precision.h"
using namespace std;


class inf_float
{
public:
    int exponent;

    bool positive;

    vector<bitset<4>> digits;

public:
    inf_float( );

    inf_float( int );

    inf_float( float );

    inf_float( double );

    int length();
};



inf_float::inf_float()
{
    exponent = 0;
    positive = true;
    for (int i = 0; i < 4; i++) digits.push_back(0);
}

inf_float::inf_float( int number )
{
    exponent = 0;
    positive = (number >= 0);

    for (int i = 0; number / pow(10, i) >= 10; i++) exponent++;
    for (int i = 0; number * pow(10, i) < 1; i++) exponent--;

    //for (int i = 0; number >= pow(10, i); i++) 
    //    digits[i] = (number/((int)pow(10,i))) % ((int)pow(10,i+1));
}

/*
inf_float::inf_float( float number )
{
    exponent = 0;
    positive = (number >= 0);

    for (int i = 0; number / pow(10, i) > 10; i++) exponent++;
    for (int i = 0; number * pow(10, i) < 1; i++) exponent--;

    for (int i = 0; i < 23; i++) digits.push_back( number & ~(1 << i) );
}
*/

int inf_float::length()
{
    return digits.size();
}



ostream &operator<<(ostream &os, inf_float &m) 
{ 
    int buffer = 0;
    int length = m.length();

    for (int j = 0; j < 4; j++) buffer += m.digits[0][j] * pow(2, j);
    
    if (!m.positive) os << '-';
    os << buffer;
    if (length >= 1) os << '.';

    for (int i = 1; i < length; i++)
    {
        int buffer = 0;

        for (int j = 0; j < 4; j++) buffer += m.digits[i][j] * pow(2, j);
            
        os << buffer;
    }

    os << "e" << m.exponent;

    return os;
}



int main()
{
    inf_float nb(1);

    for (int i = nb.digits.size() - 1; i >= 0; i--) cout << nb.digits.at(i);
    cout << endl;

    //cout << nb << endl;

    return 0;
}