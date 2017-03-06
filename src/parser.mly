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

(* Only for testing. It's not a « real » token for the language *)
%token SUBTYPE

%start <Grammar.raw_term> top_level
%start <Grammar.raw_typ> top_level_type
%start <Grammar.raw_typ * Grammar.raw_typ> top_level_subtype
%%

top_level:
| t = rule_term ; SEMICOLON ; SEMICOLON { t }
| EOF { raise End_of_file }

(* A rule which can be used to read a file containing only types. Useful to try
   subtyping algorithm.
*)
top_level_subtype:
| s = rule_typ ; SUBTYPE ; t = rule_typ ; SEMICOLON ; SEMICOLON { (s, t) }
| EOF { raise End_of_file }

(* Read a top level type. *)
top_level_type:
| s = rule_typ ; SEMICOLON ; SEMICOLON { s }
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
| t = rule_typ_forall { t }

(* Allow to add extra parentheses around for all types *)
rule_typ_forall:
| FORALL ;
  LEFT_PARENT ;
  x = VAR ;
  COLON ;
  s = rule_typ ;
  RIGHT_PARENT ;
  t = rule_typ {
          Grammar.TypeDependentFunction(s, (x, t))
        }
| LEFT_PARENT ;
  t = rule_typ_forall
  RIGHT_PARENT { t }
