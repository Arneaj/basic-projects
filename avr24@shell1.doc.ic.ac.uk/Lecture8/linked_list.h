#ifndef LINKED_LIST_H
#define LINKED_LIST_H

const int MAX_WORD_LENGTH = 80;

struct Node;
typedef Node *Node_ptr;

struct Node
{
    char word[MAX_WORD_LENGTH];
    Node_ptr ptr_to_next_node;
};

void assign_new_node(Node_ptr& node);

void list_selection_sort( Node_ptr &a_list );

void assign_list(Node_ptr &a_list);

void add_after(Node_ptr &list, char a_word[], char word_after[]); 

void delete_node(Node_ptr &a_list, char a_word[]);

Node_ptr minimum_from( Node_ptr node );

void swap( Node_ptr first, Node_ptr second );

void list_selection_sort( Node_ptr &a_list ); 

void print_list( Node_ptr& a_list);

void print_list_forwards( Node_ptr a_list );

void print_list_backwards( Node_ptr a_list );

#endif
