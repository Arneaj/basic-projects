#include <iostream>
using namespace std;

// structs

struct int_cell {
    int value;

    int_cell* next_cell;
    int_cell* previous_cell;
};

struct int_LL {
    int_cell* first_cell;
    int_cell* last_cell;

    int length;
};

// construction function

int_cell create_cell( int new_value ) {
    int_cell cell = { new_value, nullptr, nullptr };

    return cell;
}

int_LL create_empty_LL() {
    int_LL LL = { nullptr, nullptr, 0 };

    return LL;
}

bool is_empty_LL( int_LL LL ) {
    return LL.length == 0;
}

void free_LL( int_LL LL ) {
    int_cell* p_cell = LL.first_cell;
    
    while ( p_cell->next_cell != nullptr ) {
        p_cell = p_cell->next_cell;
        delete p_cell->previous_cell;

    }
    
    delete LL.last_cell ;
}

// manipulation functions

int head_LL( int_LL LL ) {
    return LL.first_cell->value;
}

int_LL tail_LL( int_LL LL ) {
    int_LL new_LL = create_empty_LL();

    if ( LL.length == 0 || LL.length == 1 ) return new_LL;

    LL.first_cell->next_cell->previous_cell = nullptr;

    new_LL.first_cell = LL.first_cell->next_cell;
    new_LL.last_cell = LL.last_cell;
    new_LL.length = LL.length - 1;

    delete LL.first_cell;

    return new_LL;
}

int_LL add_to_beg_LL( int new_value, int_LL LL ) {
    int_LL new_LL = create_empty_LL();
    int_cell* p_cell = new int_cell();

    *p_cell = create_cell( new_value );

    if ( is_empty_LL( LL ) ) {
        new_LL.first_cell = p_cell;
        new_LL.last_cell = p_cell;

        new_LL.length = LL.length + 1;

        return new_LL;
    }

    p_cell->next_cell = LL.first_cell;
    LL.first_cell->previous_cell = p_cell;

    new_LL.first_cell = p_cell;
    new_LL.last_cell = LL.last_cell;
    new_LL.length = LL.length + 1;

    // add free LL part
    //free_LL( LL );

    return new_LL;
}

int_LL add_to_end_LL( int new_value, int_LL LL ) {
    int_LL new_LL = create_empty_LL();
    int_cell* p_cell = new int_cell();

    *p_cell = create_cell( new_value );

    if ( is_empty_LL( LL ) ) {
        new_LL.first_cell = p_cell;
        new_LL.last_cell = p_cell;

        new_LL.length = LL.length + 1;

        return new_LL;
    }

    p_cell->previous_cell = LL.last_cell;
    LL.last_cell->next_cell = p_cell;

    new_LL.first_cell = LL.first_cell;
    new_LL.last_cell = p_cell;
    new_LL.length = LL.length + 1;

    // add free LL part
    //free_LL( LL );

    return new_LL;
}

int_LL remove_LL( int index, int_LL LL ) {
    if ( index < 0 || index >= LL.length ) {
        cout << "index error.\n";
        return LL;
    }

    if ( index == 0 ) {
        return tail_LL( LL );
    }
    
    if ( index == LL.length-1 ) {
        int_LL new_LL = create_empty_LL();

        if ( LL.length == 0 || LL.length == 1 ) return new_LL;

        LL.last_cell->previous_cell->next_cell = nullptr;

        new_LL.first_cell = LL.first_cell;
        new_LL.last_cell = LL.last_cell->previous_cell;
        new_LL.length = LL.length - 1;

        delete LL.last_cell;

        return new_LL;
    }

    int_LL new_LL = create_empty_LL();

    if ( LL.length == 0 || LL.length == 1 ) return new_LL;

    int_cell* p_current_cell = LL.first_cell;

    for ( int i=0; i<index; i++ ) {
        p_current_cell = p_current_cell->next_cell;
    }

    p_current_cell->previous_cell->next_cell = p_current_cell->next_cell;
    p_current_cell->next_cell->previous_cell = p_current_cell->previous_cell;

    new_LL.first_cell = LL.first_cell;
    new_LL.last_cell = LL.last_cell;
    new_LL.length = LL.length - 1;

    delete p_current_cell;

    return new_LL;
}

int_LL change_LL( int new_value, int index, int_LL LL ) {
    if ( index < 0 || index >= LL.length ) {
        cout << "index error.\n";
        return LL;
    }

    int_cell* p_current_cell = LL.first_cell;

    for ( int i=0; i<index; i++ ) {
        p_current_cell = p_current_cell->next_cell;
    }

    p_current_cell->value = new_value;

    return LL;
}

int_LL add_LL( int new_value, int index, int_LL LL ) {
    if ( index < 0 || index > LL.length ) {
        cout << "index error.\n";
        return LL;
    }

    if ( index == 0 ) {
        return add_to_beg_LL( new_value, LL );
    }
    
    if ( index == LL.length ) {
        return add_to_end_LL( new_value, LL );
    }

    int_cell* p_new_cell = new int_cell();
    *p_new_cell = create_cell( new_value );

    int_cell* p_current_cell = LL.first_cell;

    for ( int i=1; i<index; i++ ) {
        p_current_cell = p_current_cell->next_cell;
    }

    p_new_cell->previous_cell = p_current_cell;
    p_new_cell->next_cell = p_current_cell->next_cell;

    p_current_cell->next_cell->previous_cell = p_new_cell;
    p_current_cell->next_cell = p_new_cell;

    int_LL new_LL = create_empty_LL();

    new_LL.first_cell = LL.first_cell;
    new_LL.last_cell = LL.last_cell;
    new_LL.length = LL.length + 1;

    // add free cell part

    return new_LL;
}

// printing functions

void print_LL( int_LL LL ) {
    if ( is_empty_LL( LL ) ) {
        cout << "empty list.\n";

        return;
    }

    int_cell* p_current_cell = LL.first_cell;

    cout << "LL = [ ";

    cout << p_current_cell->value;

    while ( p_current_cell->next_cell != nullptr ) {
        p_current_cell = p_current_cell->next_cell;
        cout << ", " << p_current_cell->value;
    }

    cout << " ]; length = " << LL.length << ".\n";
}

void print_backwards_LL( int_LL LL ) {
    if ( is_empty_LL( LL ) ) {
        cout << "empty list.\n";

        return;
    }

    int_cell* p_current_cell = LL.last_cell;

    cout << "backwards LL = [ ";

    cout << p_current_cell->value;

    while ( p_current_cell->previous_cell != nullptr ) {
        p_current_cell = p_current_cell->previous_cell;
        cout << ", " << p_current_cell->value;
    }

    cout << " ]; length = " << LL.length << ".\n";
}





















