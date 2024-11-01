#include<iostream>
#include<cstring>
#include"soundex.h"
using namespace std;

// Question 1

int encode_letter( char l )
{
    if 
    ( 
        l == 'b' || 
        l == 'f' ||
        l == 'p' ||
        l == 'v' 
    ) return 1;

    if 
    ( 
        l == 'c' || 
        l == 'g' ||
        l == 'j' ||
        l == 'k' ||
        l == 'q' ||
        l == 's' ||
        l == 'x' ||
        l == 'z'
    ) return 2;

    if 
    ( 
        l == 'd' || 
        l == 't' 
    ) return 3;

    if 
    ( 
        l == 'l'  
    ) return 4;

    if 
    ( 
        l == 'm' || 
        l == 'n' 
    ) return 5;

    if 
    ( 
        l == 'r' 
    ) return 6;

    return -1;
}

void encode( char str[], char soundex[] )
{
    if ( str[0] == '\0' ) return;
    
    soundex[0] = toupper( str[0] );

    int j = 1;

    int previous_encoded_letter_int = -1;

    for (int i = 1; str[i] != '\0' && j < 4; i++) 
    {
        int encoded_letter_int = encode_letter( str[i] );

        if ( encoded_letter_int == -1 ) 
        {
            previous_encoded_letter_int = -1;
            continue;
        }

        if ( previous_encoded_letter_int == encoded_letter_int ) continue;

        soundex[j] = (char)( encoded_letter_int + 48 );
        j++;
        previous_encoded_letter_int = encoded_letter_int;
    }

    for (; j < 4; j++) soundex[j] = '0';

    soundex[j] = '\0';
}

void recursive_encode( char* str, char soundex[], int last_letter, int depth )
{
    if ( depth > 3 ) return;
    if ( *str == '\0' ) 
    {
        for (; depth < 4; depth++) soundex[depth] = '0';
        return;
    }

    int letter = encode_letter( *str );

    if ( letter == -1 || letter == last_letter )
    {
        recursive_encode( str+1, soundex, letter, depth );
        return;
    }

    soundex[depth] = (char)( letter + 48 );
    recursive_encode( str+1, soundex, letter, depth+1 );
    return;
}

void encode2( char* str, char soundex[] )
{
    if ( *str == '\0' ) return;

    soundex[0] = toupper( *str );

    recursive_encode( str+1, soundex, -1, 1 );
}

// Question 2

bool compare( char one[], char two[] )
{
    for (int i = 0; i < 4; i++) if ( one[i] != two[i] ) return false;

    return true;
}

// Question 3

int count( char surname[], const char sentence[] )
{
    int matches = 0;

    char soundex[5];

    encode( surname, soundex );

    char word_buffer[MAX_LENGTH];
    int word_buffer_length = 0;
    char soundex_buffer[5];

    int i = 0;

    while (true)
    {
        if ( !isalpha( sentence[i] ) ) 
        {
            word_buffer[word_buffer_length] = '\0';

            encode( word_buffer, soundex_buffer );

            if ( compare(soundex_buffer, soundex) ) matches++;

            strcpy( word_buffer, "" );
            strcpy( soundex_buffer, "" );
            word_buffer_length = 0;
        }
        else
        {
            word_buffer[word_buffer_length] = sentence[i];
            word_buffer_length++;
        }

        if ( sentence[i] == '\0' ) return matches;

        i++;
    }

    return matches;
}
