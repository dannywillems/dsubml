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
%token NOT_SUBTYPE
%token UNIMPLEMENTED_TERM
%token ARROW
%token EXCLAMATION

%start <Grammar.raw_top_level_term> top_level
%start <Grammar.raw_typ> top_level_type
%start <Grammar.raw_top_level_term * Grammar.raw_typ> top_level_check_typing
%start <bool * Grammar.raw_top_level_subtype> top_level_subtype
%start <bool * Grammar.raw_top_level_typ> top_level_well_formed
%%

(* ----------------------------------------------------- *)
(* Top level rules *)
top_level:
| t = rule_term ; SEMICOLON ; SEMICOLON { Grammar.Term(t) }
| t = top_level_let {
          let (var, term) = t in
          Grammar.TopLevelLetTerm(var, term)
        }
| EOF { raise End_of_file }

top_level_let:
| LET ;
  var = VAR ;
  EQUAL ;
  term = rule_term ;
  SEMICOLON ;
  SEMICOLON {
      (var, term)
    }
| LET ;
  var = VAR ;
  COLON ;
  typ = rule_typ ;
  EQUAL ;
  term = rule_term ;
  SEMICOLON ;
  SEMICOLON {
      (var, Grammar.TermAscription(term, typ))
    }

(* A rule which can be used to read a file containing only types. Useful to try
   sub-typing algorithm.
*)
top_level_subtype:
| s = rule_typ ; SUBTYPE ; t = rule_typ ; SEMICOLON ; SEMICOLON
  {
    (true, Grammar.CoupleTypes(s, t))
  }
| s = rule_typ ; NOT_SUBTYPE ; t = rule_typ ; SEMICOLON ; SEMICOLON
  {
    (false, Grammar.CoupleTypes(s, t))
  }
| t = top_level_let { let (var, term) = t in
                      (false, Grammar.TopLevelLetSubtype(var, term))
                    }
| EOF { raise End_of_file }

(* Read a top level type. *)
top_level_type:
| s = rule_typ ; SEMICOLON ; SEMICOLON { s }
| EOF { raise End_of_file }

(* Read a top level check typing. *)
top_level_check_typing:
| t = top_level_let {
            let (var, term) = t in
            (* We can use any type we want, it's not used. *)
            (Grammar.TopLevelLetTerm(var, term), Grammar.TypeBottom)
          }
| term = rule_term ;
  COLON ;
  typ = rule_typ ;
  SEMICOLON ;
  SEMICOLON { (Grammar.Term(term), typ) }
| EOF { raise End_of_file }

top_level_well_formed:
| t = top_level_let { let (var, term) = t in
                        (true, Grammar.TopLevelLetType(var, term))
                      }
| EXCLAMATION ; t = rule_typ ; SEMICOLON ; SEMICOLON {
                                               (false, Grammar.Type(t))
                                             }
| t = rule_typ ; SEMICOLON ; SEMICOLON { (true, Grammar.Type(t))  }
| EOF { raise End_of_file }
(* ----------------------------------------------------- *)

(* ----------------------------------------------------- *)
(* Rules to build terms and types. *)
rule_term:
| id = VAR { Grammar.TermVariable id }
| UNIMPLEMENTED_TERM { Grammar.TermUnimplemented }
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
| t = rule_terms_not_in_dsub { t }

rule_terms_not_in_dsub:
| t = rule_term ;
  COLON ;
  typ_of_t = rule_typ { Grammar.TermAscription(t, typ_of_t) }

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
| s = rule_typ ;
  ARROW ;
  t = rule_typ {
          Grammar.TypeDependentFunction(s, ("_", t))
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
| LEFT_PARENT ;
  t = rule_typ_forall
  RIGHT_PARENT { t }
(* ----------------------------------------------------- *)
