#include<iostream>
#include<cstring>
#include"linked_list.h"
using namespace std;

int main() {
    
    Node_ptr list;

    assign_list( list );

    print_list_forwards( list );

    cout << endl;

    print_list_backwards( list );

    cout << endl;
/*
    char new_word[MAX_WORD_LENGTH];
    char word_before[MAX_WORD_LENGTH];

    cout << "ENTER A NEW WORD TO ADD: ";
    cin.getline(new_word, MAX_WORD_LENGTH);
    cin.getline(new_word, MAX_WORD_LENGTH);

    cout << "ENTER THE WORD BEFORE THAT ONE: ";
    cin.getline(word_before, MAX_WORD_LENGTH);

    add_after( list, word_before, new_word );

    print_list( list );

    char word_to_delete[MAX_WORD_LENGTH];

    cout << "ENTER A WORD TO DELETE: ";
    cin.getline(word_to_delete, MAX_WORD_LENGTH);
    
    delete_node( list, word_to_delete );

    print_list( list );

    list_selection_sort( list );

    print_list( list );
*/    
    return 0;
}

