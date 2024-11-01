#ifndef SOUNDEX_H
#define SOUNDEX_H

const int MAX_LENGTH = 64;

void encode( char str[], char soundex[] );

void encode2( char* str, char soundex[] );

bool compare( char one[], char two[] );

int count( char surname[], const char sentence[] );

#endif
