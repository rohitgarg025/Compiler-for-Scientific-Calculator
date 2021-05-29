%{
#include <math.h>
#include <stdlib.h>
#include <stdio.h>

#include "calcilist.h"
#include "calcilist.tab.h"

void yyerror(char*);

%}

var_name [a-zA-Z_][0-9a-zA-Z_]*

%%
{var_name} {yylval.name = strdup(yytext); return NAME; }
[0-9][0-9]*		  { yylval.lst = NewNode(); yylval.lst->value = atof(yytext); return NUM; }
[0-9][0-9]*\.[0-9]+	  { yylval.lst = NewNode(); yylval.lst->value = atof(yytext); return NUM; }
\n                        { return *yytext; }
[ \t]*			  { /* Do nothing, drop them. */ }
.                         { return *yytext; }
%%

#ifdef STANDALONE_LEXER
int main(void)
	{
	while(yylex()!='q');
	}
#endif
