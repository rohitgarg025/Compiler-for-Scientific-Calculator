#ifndef CALCILIST_H
#define CALCILIST_H
#define MAX_SIZE 100
#define MAX_STRING 100
// #define YYSTYPE list*

typedef struct _list {
    struct _list *first, *rest;
    double value;
} list;


typedef struct{
    char name[MAX_STRING];
    list * lst;
} pair;



extern char *yytext;

list *NewNode(void);
#endif

// {<a->[1,3]>, b->[5,6], c = [[1 3] a]}

// S-> aS | e
