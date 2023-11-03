/*
*  cool.y
*              Parser definition for the COOL language.
*
*/

/* http://www.gnu.org/software/bison/manual/bison.html#Prologue
 */
%{
  #include <iostream>
  #include "cool-tree.h"
  #include "stringtab.h"
  #include "utilities.h"
  #include "list.h"
  
  extern char *curr_filename;
  
  
  /* Locations */
  #define YYLTYPE int              /* the type of locations */
  #define cool_yylloc curr_lineno  /* use the curr_lineno from the lexer
  for the location of tokens */
    
    extern int node_lineno;          /* set before constructing a tree node
    to whatever you want the line number
    for the tree node to be */
      
      
      #define YYLLOC_DEFAULT(Current, Rhs, N)         \
      Current = Rhs[1];                             \
      node_lineno = Current;
    
    
    #define SET_NODELOC(Current)  \
    node_lineno = Current;
    
    /* IMPORTANT NOTE ON LINE NUMBERS
    *********************************
    * The above definitions and macros cause every terminal in your grammar to 
    * have the line number supplied by the lexer. The only task you have to
    * implement for line numbers to work correctly, is to use SET_NODELOC()
    * before constructing any constructs from non-terminals in your grammar.
    * Example: Consider you are matching on the following very restrictive 
    * (fictional) construct that matches a plus between two integer constants. 
    * (SUCH A RULE SHOULD NOT BE  PART OF YOUR PARSER):
    
    plus_consts : INT_CONST '+' INT_CONST 
    
    * where INT_CONST is a terminal for an integer constant. Now, a correct
    * action for this rule that attaches the correct line number to plus_const
    * would look like the following:
    
    plus_consts : INT_CONST '+' INT_CONST 
    {
      // Set the line number of the current non-terminal:
      // ***********************************************
      // You can access the line numbers of the i'th item with @i, just
      // like you acess the value of the i'th exporession with $i.
      //
      // Here, we choose the line number of the last INT_CONST (@3) as the
      // line number of the resulting expression (@$). You are free to pick
      // any reasonable line as the line number of non-terminals. If you 
      // omit the statement @$=..., bison has default rules for deciding which 
      // line number to use. Check the manual for details if you are interested.
      @$ = @3;
      
      
      // Observe that we call SET_NODELOC(@3); this will set the global variable
      // node_lineno to @3. Since the constructor call "plus" uses the value of 
      // this global, the plus node will now have the correct line number.
      SET_NODELOC(@3);
      
      // construct the result node:
      $$ = plus(int_const($1), int_const($3));
    }
    
    */
    
    
    
    void yyerror(char *s);        /*  defined below; called for each parse error */
    extern int yylex();           /*  the entry point to the lexer  */

    /************************************************************************/
    /*                DONT CHANGE ANYTHING IN THIS SECTION                  */
    
    Program ast_root;       /* the result of the parse  */
    Classes parse_results;        /* for use in semantic analysis */
    int omerrs = 0;               /* number of errors in lexing and parsing */
    %}
    
    /* A union of all the types that can be the result of parsing actions. */
    %union {
      Boolean boolean;
      Symbol symbol;
      Program program;
      Class_ class_;
      Classes classes;
      Feature feature;
      Features features;
      Formal formal;
      Formals formals;
      Case case_;
      Cases cases;
      Expression expression;
      Expressions expressions;
      char *error_msg;
    }
    
    /* 
    Declare the terminals; a few have types for associated lexemes.
    The token ERROR is never used in the parser; thus, it is a parse
    error when the lexer returns it.
    
    The integer following token declaration is the numeric constant used
    to represent that token internally.  Typically, Bison generates these
    on its own, but we give explicit numbers to prevent version parity
    problems (bison 1.25 and earlier start at 258, later versions -- at
    257)
    */
    %token CLASS 258 ELSE 259 FI 260 IF 261 IN 262 
    %token INHERITS 263 LET 264 LOOP 265 POOL 266 THEN 267 WHILE 268
    %token CASE 269 ESAC 270 OF 271 DARROW 272 NEW 273 ISVOID 274
    %token <symbol>  STR_CONST 275 INT_CONST 276 
    %token <boolean> BOOL_CONST 277
    %token <symbol>  TYPEID 278 OBJECTID 279 
    %token ASSIGN 280 NOT 281 LE 282 ERROR 283
    
    /*  DON'T CHANGE ANYTHING ABOVE THIS LINE, OR YOUR PARSER WONT WORK       */
    /**************************************************************************/
    
    /* Complete the nonterminal list below, giving a type for the semantic
    value of each non terminal. (See section 3.6 in the bison 
    documentation for details). */
    
    /* Declare types for the grammar's non-terminals. */
    %type <program> program
    %type <class_> class
    %type <features> class_list
    %type <features> features_list
    %type <features> features
    %type <feature> feature
    %type <formals> formals
    %type <formal> formal
    %type <expressions> expr
    %type <expression> assignment_expr
    %type <expression> dispatch_expr
    %type <expression> if_expr
    %type <expression> while_expr
    %type <expression> block_expr
    %type <expression> let_expr
    %type <expression> case_expr
    %type <expression> new_expr
    %type <expression> isvoid_expr
    %type <expression> arith_expr
    %type <expression> comp_expr
    %type <expression> neg_expr
    %type <expression> primary_expr
    %type <expressions> expr_list
    %type <expressions> one_or_more_expr
    %type <expressions> param_expr
    %type <bindings> let_bindings
    %type <cases> case_branch_list
    %type <case_> case_list
    %type <case_> case_branch
    %type <expression> add_sub_expr
    %type <expression> mul_div_expr
    %type <expression> unary_expr

    %right ASSIGN
    %left NOT
    %nonassoc LE '<' '='
    %left '+' '-'
    %left '*' '/'
    %left ISVOID
    %left '~'
    %left '@'
    %left '.'

    %%
    /* Think about what this grammar means; a program is made up of a list of one or more classes */
    /* Definição das regras da gramática Cool */
    program : class_list { 
                /* Salva o nó raiz da árvore de sintaxe abstrata em uma variável global @$ 
                * Veja a seção 6.5 no arquivo Tour of Cool para mais informações */
                @$ = @1; 
                ast_root = program($1); 
            }
            ;

    /* Lista de classes: pode ser uma única classe ou uma lista de classes */
    class_list : class {
                    /* Cria uma lista com uma única classe */
                    $$ = single_Classes($1);
                    parse_results = $$;
                }
            | class_list class {
                    /* Adiciona uma nova classe à lista existente de classes */
                    $$ = append_Classes($1, single_Classes($2));
                    parse_results = $$;
                }
            ;

    /* Definição de uma classe em Cool */
    class : CLASS TYPEID '{' features_list '}' ';' {
                /* Cria um objeto de classe com nome, tipo pai, lista de features e nome do arquivo */
                $$ = class_($2, idtable.add_string("Object"), $4, stringtable.add_string(curr_filename)); 
            }
        | CLASS TYPEID INHERITS TYPEID '{' features_list '}' ';' {
                /* Cria um objeto de classe com nome, tipo pai, lista de features e nome do arquivo */
                $$ = class_($2, $4, $6, stringtable.add_string(curr_filename)); 
            }
        /* Tratamento de erros para a definição de classe */
        | CLASS TYPEID '{' error '}' ';' { yyclearin; $$ = NULL; }
        | CLASS error '{' features_list '}' ';' { yyclearin; $$ = NULL; }
        | CLASS error '{' error '}' ';' { yyclearin; $$ = NULL; }
        ;

    /* Lista de features: pode ser vazia ou conter uma ou mais features */
    features_list : features { $$ = $1; }
                | empty_list { $$ = $1; }
                ;

    /* Lista de features vazia */
    empty_list : /* Vazia */ { $$ = nil_Features(); };

    /* Pode ser um único atributo ou um método, ou uma lista de features seguida por uma feature */
    features : feature ';' { $$ = single_Features($1); }
            | multiple_features { $$ = $1; }
            | error ';' { yyclearin; $$ = NULL; }
            ;

    /* Uma única formal (parâmetro de método) */
    formal : OBJECTID ':' TYPEID { $$ = formal($1, $3); }

    /* Lista de formais não vazia: pode conter uma ou mais formais */
    non_empty_formals : formal { $$ = single_Formals($1); }
                    | non_empty_formals ',' formal { $$ = append_Formals($1, single_Formals($3)); }
                    ;

    /* Lista de formais: pode ser não vazia ou vazia */
    formals : non_empty_formals { $$ = $1; }
            | { $$ = nil_Formals(); }
            ;

    /* Atributo sem ou com uma expressão de atribuição */
    attribute_feature : OBJECTID ':' TYPEID { $$ = attr($1, $3, no_expr()); }
                    | OBJECTID ':' TYPEID ASSIGN expr { $$ = attr($1, $3, $5); }
                    ;

    /* Método com parâmetros, tipo de retorno e corpo do método */
    method_feature : OBJECTID '(' formals ')' ':' TYPEID '{' expr '}' { $$ = method($1, $3, $6, $8); }

    /* Uma feature pode ser um atributo ou um método */
    feature : attribute_feature { $$ = $1; }
            | method_feature { $$ = $1; }
            ;

    /* Múltiplas features: uma lista de features seguida por uma feature */
    multiple_features : features feature ';' { $$ = append_Features($1, single_Features($2)); }


    expr : assignment_expr { $$ = $1; }          /* Expressão de atribuição */
        | dispatch_expr { $$ = $1; }           /* Expressão de chamada de método */
        | if_expr { $$ = $1; }                 /* Expressão condicional (if-then-else) */
        | while_expr { $$ = $1; }              /* Expressão de loop while */
        | block_expr { $$ = $1; }              /* Bloco de expressões */
        | let_expr { $$ = $1; }                /* Expressão let (definição de variáveis) */
        | case_expr { $$ = $1; }               /* Expressão case (análise de tipo) */
        | new_expr { $$ = $1; }                /* Expressão de criação de objeto */
        | isvoid_expr { $$ = $1; }             /* Expressão isvoid (verificação de nulidade) */
        | arith_expr { $$ = $1; }              /* Expressões aritméticas */
        | comp_expr { $$ = $1; }               /* Expressões de comparação */
        | neg_expr { $$ = $1; }                /* Expressões de negação */
        | primary_expr { $$ = $1; }            /* Expressões primárias */
        ;

    assignment_expr : OBJECTID ASSIGN expr { $$ = assign($1, $3); } /* Expressão de atribuição */
                    ;

    dispatch_expr : expr '.' OBJECTID '(' param_expr ')' { $$ = dispatch($1, $3, $5); }  /* Expressão de chamada de método */
                    | expr '@' TYPEID '.' OBJECTID '(' param_expr ')' { $$ = static_dispatch($1, $3, $5, $7); } /* Chamada de método estática */
                    | OBJECTID '(' param_expr ')' { $$ = dispatch(object(idtable.add_string("self")), $1, $3); } /* Chamada de método para o objeto self */
                    ;

    if_expr : IF expr THEN expr ELSE expr FI { $$ = cond($2, $4, $6); } /* Expressão condicional (if-then-else) */
            ;

    while_expr : WHILE expr LOOP expr POOL { $$ = loop($2, $4); }  /* Expressão de loop while */
            ;

    block_expr : '{' expr_list '}' { $$ = block($2); }  /* Bloco de expressões */
            ;

    expr_list : expr ';' { $$ = single_Expressions($1); }  /* Lista de expressões separadas por ponto e vírgula */
            | expr_list expr ';' { $$ = append_Expressions($1, single_Expressions($2)); }  /* Lista de expressões com ponto e vírgula */
            ;

    let_expr : LET let_bindings IN expr { $$ = let($2, $4, $6); }  /* Expressão let (definição de variáveis) */
            ;

    let_bindings : OBJECTID ':' TYPEID { $$ = single_LetBindings(formal($1, $3), no_expr()); }  /* Vinculação de variável sem inicialização */
                    | OBJECTID ':' TYPEID ASSIGN expr { $$ = single_LetBindings(formal($1, $3), $5); }  /* Vinculação de variável com inicialização */
                    | let_bindings ',' OBJECTID ':' TYPEID { $$ = append_LetBindings($1, single_LetBindings(formal($3, $5), no_expr())); }  /* Vinculação de variável sem inicialização em uma lista */
                    | let_bindings ',' OBJECTID ':' TYPEID ASSIGN expr { $$ = append_LetBindings($1, single_LetBindings(formal($3, $5), $7)); }  /* Vinculação de variável com inicialização em uma lista */
                    ;

    case_expr : CASE expr OF case_list ESAC { $$ = typcase($2, $4); }  /* Expressão case (análise de tipo) */
            ;

    case_list : case_branch { $$ = single_Cases($1); }  /* Lista de ramos case */
            | case_list case_branch { $$ = append_Cases($1, single_Cases($2)); }  /* Lista de ramos case com mais de um elemento */
            ;

    case_branch : OBJECTID ':' TYPEID DARROW expr { $$ = branch($1, $3, $5); }  /* Ramo case com um tipo e uma expressão */
                    ;

    new_expr : NEW TYPEID { $$ = new_($2); }  /* Expressão de criação de objeto */
            ;

    isvoid_expr : ISVOID expr { $$ = isvoid($2); }  /* Expressão isvoid (verificação de nulidade) */
            ;

    arith_expr : add_sub_expr { $$ = $1; }  /* Expressões aritméticas (adição e subtração) */
            ;

    add_sub_expr : mul_div_expr { $$ = $1; }  /* Expressões aritméticas (multiplicação e divisão) */
                    | add_sub_expr '+' mul_div_expr { $$ = plus($1, $3); }  /* Adição de duas expressões */
                    | add_sub_expr '-' mul_div_expr { $$ = sub($1, $3); }  /* Subtração de duas expressões */
                    ;

    mul_div_expr : unary_expr { $$ = $1; }  /* Expressões aritméticas (unárias) */
                    | mul_div_expr '*' unary_expr { $$ = mul($1, $3); }  /* Multiplicação de duas expressões */
                    | mul_div_expr '/' unary_expr { $$ = divide($1, $3); }  /* Divisão de duas expressões */
                    ;

    unary_expr : primary_expr { $$ = $1; }  /* Expressões unárias */
                | '~' primary_expr { $$ = neg($2); }  /* Negação lógica de uma expressão */
                | NOT primary_expr { $$ = comp($2); }  /* Complemento de uma expressão booleana */
                | '-' primary_expr { $$ = neg($2); }  /* Negação aritmética de uma expressão */
                ;

    primary_expr : '(' expr ')' { $$ = $2; }  /* Expressão entre parênteses */
                    | OBJECTID { $$ = object($1); }  /* Referência a um objeto (identificador) */
                    | INT_CONST { $$ = int_const($1); }  /* Constante inteira */
                    | STR_CONST { $$ = string_const($1); }  /* Constante de string */
                    | BOOL_CONST { $$ = bool_const($1); }  /* Constante booleana */
                    ;
    %%

    void yyerror(char *s)
    {
        extern int curr_lineno;
        extern char *yytext;

        // Obtém a posição do erro na linha
        int error_position = 1;
        char *pos = yytext;
        while (pos > curr_text && *pos != '\n') {
            pos--;
            error_position++;
        }

        // Imprime uma mensagem de erro detalhada
        cerr << "Error at line " << curr_lineno << ", position " << error_position << ": " << s << endl;
        cerr << "Error context: ";
        
        // Imprime o contexto ao redor do erro (10 caracteres antes e depois do erro)
        int context_start = max(0, error_position - 10);
        int context_end = min(strlen(yytext), error_position + 10);
        for (int i = context_start; i < context_end; i++) {
            cerr << yytext[i];
        }
        cerr << endl;

        omerrs++;

        if (omerrs > 50) {
            fprintf(stdout, "More than 50 errors\n");
            exit(1);
        }
    }
