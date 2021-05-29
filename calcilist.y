%debug
%{
#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <error.h>
#include <errno.h>

#include "calcilist.h"
#include "calcilist.tab.h"

pair **var_map;
int id;

void yyerror(char *s)
{
fprintf(stderr,"%s\n",s);
return;
}

int yywrap()
{
    return 1;
}

#define printob printf("[")
#define printcb printf("]")
#define println printf("\n")
#define printlist(l) PrintList(l); println

void PrintList(list *l) {
    if(l) {
        if(l->first) {
            printob;
            PrintList(l->first);
            PrintList(l->rest);
            printcb;
        }
        else printf("%g ",l->value);
    }

}

int nodecount = 0;
list *NewNode(void) {
    list *temp = (list*)malloc(sizeof(list));
    if(temp) {
        nodecount++;
        temp->first = NULL;
        temp->rest = NULL;
        temp->value = M_E;
    }
    else error(-1,errno,"Allocation failed at %dth new node.", nodecount+1);
    return temp;
}

void FreeRecursive(list *l) {
    if(l) {
        FreeRecursive(l->first);
        FreeRecursive(l->rest);
        free(l);
        nodecount--;
    }
}

void AddAtomToList(double num, list *l) {
    if(l) {
        if(l->first) {
            AddAtomToList(num, l->first);
            AddAtomToList(num, l->rest);
        }
        else l->value += num;
    }
}

list *Add(list *one, list *two) {
    if(!(one || two)) return NULL;
    if(one && !two) return one;
    if(!one && two) return two;
    if(one->first) {
        if(two->first) {
            one->first = Add(one->first, two->first);
            one->rest = Add(one->rest, two->rest);
            return one;
        }
        else {
            AddAtomToList(two->value, one->first);
            free(two);
            return one;
        }
    }
    else {
        AddAtomToList(one->value, two);
        free(one);
        return two;
    }
}

void MultiplyAtomToList(double num, list *l) {
    if(l) {
        if(l->first) {
            MultiplyAtomToList(num, l->first);
            MultiplyAtomToList(num, l->rest);
        }
        else l->value *= num;
    }
}

list *Multiply(list *one, list *two) {
    if(!(one || two)) return NULL;
    if(one && !two) return one;
    if(!one && two) return two;
    if(one->first) {
        if(two->first) {
            one->first = Multiply(one->first, two->first);
            one->rest = Multiply(one->rest, two->rest);
            return one;
        }
        else {
            MultiplyAtomToList(two->value, one->first);
            free(two);
            return one;
        }
    }
    else {
        MultiplyAtomToList(one->value, two);
        free(one);
        return two;
    }

    
}

void store_names(char* name, list* lst){
    for(int i=0;i<id;i++){
        if(strcmp(name, var_map[i]->name) == 0){
            var_map[i]->lst = lst;
            return;
        }
    }

    var_map[id] = (pair*)malloc(sizeof(pair));
    var_map[id]->lst = lst;
    strcpy(var_map[id]->name, name);
    id++;
}

list* get_list(char* name){
    for(int i=0;i<id;i++){
        if(strcmp(name, var_map[i]->name) == 0){
            return var_map[i]->lst;        
        }
    }

    return NULL;

}

list *lst; /* for debugging. temp. */

%}

%token <lst> NUM
%token <name> NAME 

%union{
    char* name;
    list* lst;
}

%type <lst> EXPR TERM FACTOR LIST EXTEND
%type <name> NAAM


%%
LINES       :   LINES LINE
            |
            ;

LINE        :   EXPR '\n'                       { printlist($1); }
            |   NAAM    '='     EXPR    '\n'             { store_names($1,$3);}
            |   NAAM '\n'                        {PrintList(get_list($1));}
            |   '\n'
            ;
NAAM        :   NAME                            {$$ = yyval.name;};

EXPR        :   EXPR    '+'     TERM            { PrintList($1); printf("+"); PrintList($3); printf("="); $$ = Add($1,$3); printlist($$); }
            |   TERM                            { $$ = $1; }
            ;
TERM        :   TERM    '*'     FACTOR          { PrintList($1); printf("*"); PrintList($3); printf("="); $$ = Multiply($1,$3); printlist($$); }
            |   FACTOR                          { $$ = $1; }
            ;

FACTOR      :   '('     EXPR    ')'             { $$ = $2; }
            |   NUM                             { $$ = yylval.lst; }
            |   '['     LIST    ']'             { $$ = $2; }
            |   NAAM    '\''                           {$$ = NewNode(); $$->first = get_list($1);}
            ;
LIST        :   EXPR     EXTEND                  { $$ = NewNode(); $$->first = $1; $$->rest = $2; }
            |   '['     LIST    ']'  '\''   EXTEND  { $$ = NewNode(); $$->first = $2; $$->rest = $5; }
            |   NAAM '\''  EXTEND                      {$$ = NewNode(); $$->first = get_list($1); $$->rest = $3;}
            ;
EXTEND      :  LIST                            { $$ = $1; }
            |                                    { $$ = NULL; }
            ;
%%

int main(int argc, char *argv[])
{
    var_map = (pair**)malloc((MAX_SIZE)*sizeof(pair*));
    id = 0;
    var_map[id] = (pair*)malloc(sizeof(pair));
    var_map[id]->lst = NewNode();
    var_map[id]->lst->value = 69.00;
    strcpy(var_map[id]->name, "chal ja");
    id++;
    printf("%s %d\n",var_map[0]->name,id);

yyparse();
return 0;
}
