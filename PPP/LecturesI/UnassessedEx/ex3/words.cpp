#include<iostream>
#include<cstring>
#include"words.h"
#include"string_sort.h"
#include"string_shear.h"
using namespace std;

// Question 1

void recursive_reverse( const char in[], char out[], int depth, int& max_depth )
{
    if ( in[depth+1] != '\0' ) recursive_reverse( in, out, depth+1, max_depth );
    else max_depth = depth;

    out[max_depth - depth] = in[depth];
}

void reverse( const char in[], char out[] )
{
    int max_depth = -1;

    recursive_reverse( in, out, 0, max_depth );

    out[max_depth+1] = '\0';
}

// Question 2

bool compare( char* str1, char* str2 )
{
    if ( !isalpha( *str1 ) && *str1 != '\0' ) return compare( str1+1, str2 );
    if ( !isalpha( *str2 ) && *str2 != '\0' ) return compare( str1, str2+1 );

    if ( *str1 == '\0' && *str2 == '\0' ) return true;

    if ( toupper(*str1) == toupper(*str2) ) return compare( str1+1, str2+1 );

    return false;
}

// Question 3

bool palindrome( char sentence[] )
{
    char reversed_sentence[MAX_LENGTH];

    reverse( sentence, reversed_sentence );

    return compare( sentence, reversed_sentence );
}

// Question 4

void string_clean( char str[] )
{
    int i = 0;

    while( true )
    {
        if (str[i] == '\0') return;

        if (!isalpha(str[i])) 
        {
            remove_char( i, str );
            continue;
        }
        else str[i] = toupper( str[i] );
        
        i++;
    }
}

bool anagram( char str1[], char str2[] )
{
    char sorted_str1[MAX_LENGTH];
    char sorted_str2[MAX_LENGTH];

    strcpy( sorted_str1, str1 );
    strcpy( sorted_str2, str2 );

    string_clean( sorted_str1 );
    string_clean( sorted_str2 );

    string_sort( sorted_str1 );
    string_sort( sorted_str2 );

    int i = 0;

    while (true)
    {
        if ( sorted_str1[i] != sorted_str2[i] ) return false;

        if ( sorted_str1[i] == '\0' ) break;

        i++;
    }

    return true;
}

