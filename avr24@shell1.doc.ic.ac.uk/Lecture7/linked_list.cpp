#include<iostream>
#include<cstring>
#include"linked_list.h"
using namespace std;

void assign_new_node(Node_ptr& node) {
    node = new (nothrow) Node;
    if ( node == NULL ) {
        cout << "Sorry, ran out of memory";
        exit(1);
    }
}

void assign_list(Node_ptr &a_list)
{
    Node_ptr current_node, last_node;

    assign_new_node(a_list);
    cout << "Enter first word (or '.' to end list): ";
    cin >> a_list->word;
    if (!strcmp(".",a_list->word))
    {
        delete a_list;
        a_list = NULL;
    }
    current_node = a_list;			/* LINE 13 */

    while (current_node != NULL)
    {
        assign_new_node(last_node);
        cout << "Enter next word (or '.' to end list): ";
        cin >> last_node->word;
        if (!strcmp(".",last_node->word))
        {
            delete last_node;
            last_node = NULL;
        }
        current_node->ptr_to_next_node = last_node;
        current_node = last_node;
    }
}

void add_after(Node_ptr &list, char a_word[], char word_after[]) {
    
    Node_ptr current_node = list;

    if (current_node == NULL ) {
        cout << "Empty list" << endl;
        return;
    }

    Node_ptr new_node;

    assign_new_node(new_node);

    while( strcmp(current_node->word, a_word) != 0 ) {
        current_node = current_node->ptr_to_next_node;

        if ( current_node == NULL ) {
            cout << "Given word doesn't appear" << endl;
            return;
        }
    }

    strcpy( new_node->word, word_after);
    new_node->ptr_to_next_node = current_node->ptr_to_next_node;
    current_node->ptr_to_next_node = new_node;
}

void delete_node(Node_ptr &a_list, char a_word[]) {

    if ( a_list == NULL ) {
        cout << "Nothing to remove" << endl;
        return;
    }

    Node_ptr current_node = a_list;
    
    if ( strcmp(current_node->word, a_word) == 0 ) {
        a_list = a_list->ptr_to_next_node;
        delete current_node;
        cout << "Deleted word " << a_word << endl;
        return;
    }

    Node_ptr previous_node = a_list;
    current_node = current_node->ptr_to_next_node;

    while( strcmp(current_node->word, a_word) != 0 ) {

        if ( current_node->ptr_to_next_node == NULL ) {
            cout << "Given word doesn't appear" << endl;
            return;
        }

        previous_node = current_node;
        current_node = current_node->ptr_to_next_node;
    }

    previous_node->ptr_to_next_node = current_node->ptr_to_next_node;
    delete current_node;
    cout << "Deleted word " << a_word << endl;
}

Node_ptr minimum_from( Node_ptr node ) {

    Node_ptr& min_node = node;

    if ( min_node->ptr_to_next_node == NULL ) {
        return min_node;
    }

    Node_ptr current_node = node->ptr_to_next_node;
    
    while ( true ) {
        if ( strcmp( current_node->word, min_node->word ) < 0 ) 
            min_node = current_node;

        if ( current_node->ptr_to_next_node == NULL ) { 
            return min_node;
        }

        current_node = current_node->ptr_to_next_node;
    }
}

void swap( Node_ptr first, Node_ptr second ) {
    if ( first == second ) return;
    
    char temp[MAX_WORD_LENGTH];
    strcpy( temp, first->word );
    strcpy( first->word, second->word);
    strcpy( second->word, temp );
}

void list_selection_sort( Node_ptr &a_list ) {
    
    Node_ptr current_node = a_list;
    
    while ( current_node->ptr_to_next_node != NULL ) {
        swap( current_node, minimum_from(current_node) );
        current_node = current_node->ptr_to_next_node;
    }
}

void print_list( Node_ptr& a_list ) {

    Node_ptr current_node = a_list;
    
    while ( current_node != NULL ) {
        cout << current_node->word << ' ';

        current_node = current_node->ptr_to_next_node;
    }

    cout << endl;
}






