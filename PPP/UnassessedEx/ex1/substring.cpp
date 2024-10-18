#include<iostream>
#include<cstring>
#include"substring.h"
using namespace std;

int substring_position( string sub_str, string str ) 
{
    int sub_str_advancement = 0;
    int sub_str_beginning = 0;

    for (int i = 0; str[i] != '\0'; i++)
    {
        if ( sub_str[sub_str_advancement] == '\0' ) return sub_str_beginning;

        if ( str[i] != sub_str[sub_str_advancement] )
        {
            sub_str_advancement = 0;
        }

        if ( str[i] == sub_str[sub_str_advancement] )
        {
            if ( sub_str_advancement == 0 ) sub_str_beginning = i;

            sub_str_advancement++;
        }
    }

    if ( sub_str[sub_str_advancement] == '\0' ) return sub_str_beginning;

    return -1;
}

int substring_position_short( char* b, char* a )
{
    return strstr(a,b)-a;
}

