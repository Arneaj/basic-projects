#include<iostream>
using namespace std;

int minimum_from(char a[], int position)
{
    int min_i = position;

    int i = position + 1;
    
    while (a[i] != '\0') {
        if (a[i] < a[min_i]) min_i = i;

        i++;
    }

    return min_i;
}

void swap(char& first, char& second)
{
    char temp = first;
    first = second;
    second = temp;
}

void string_sort(char a[])
{
    int i = 0;

    while (a[i] != '\0') {
        swap(a[i],a[minimum_from(a,i)]);
        
        i++;
    }
}
