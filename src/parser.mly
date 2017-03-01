%token COLON
%token DOT
%token LEFT_BRACKET
%token RIGHT_BRACKET
%token LEFT_PARENT
%token RIGHT_PARENT
%token TOP_TYPE
%token BOTTOM_TYPE
%token <string> LABEL
%token SEMICOLON
%token <string> VAR
%token ABSTRACTION
%token EQUAL
%token FORALL
%token LET
%token IN
%token EOF

%start <Grammar.raw_term> top_level
%%

top_level:
| t = rule_term ; SEMICOLON ; SEMICOLON { t }
| EOF { raise End_of_file }

rule_term:
| id = VAR { Grammar.TermVariable id }
| v = rule_value { v }
| x = VAR ; y = VAR { Grammar.TermVarApplication (x, y) }
| LET ;
  x = VAR ;
  EQUAL ;
  t = rule_term ;
  IN ;
  u = rule_term {
          Grammar.TermLet(t,(x, u))
        }

| LEFT_PARENT ;
  t = rule_term ;
  RIGHT_PARENT { t }

rule_value:
| LEFT_BRACKET ;
  l = LABEL ;
  EQUAL ;
  typ = rule_typ ;
  RIGHT_BRACKET {
      Grammar.TermTypeTag(l, typ)
    }
| ABSTRACTION ;
  LEFT_PARENT ;
  id = VAR ;
  COLON ;
  typ = rule_typ ;
  RIGHT_PARENT ;
  t = rule_term {
          Grammar.TermAbstraction(typ, (id, t))
        }

rule_typ:
| TOP_TYPE { Grammar.TypeTop }
| BOTTOM_TYPE { Grammar.TypeBottom }
| LEFT_BRACKET ;
  l = LABEL ;
  COLON ;
  s = rule_typ ;
  DOT ;
  DOT ;
  t = rule_typ ;
  RIGHT_BRACKET {
      Grammar.TypeDeclaration(l, s, t)
    }
| x = VAR ;
  DOT ;
  l = LABEL {
          Grammar.TypeProjection(x, l)
        }
| FORALL ;
  LEFT_PARENT ;
  x = VAR ;
  COLON ;
  s = rule_typ ;
  RIGHT_PARENT ;
  t = rule_typ {
          Grammar.TypeDependentFunction(s, (x, t))
        }
