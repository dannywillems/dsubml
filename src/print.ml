let string_of_term_variable (t : string Grammar.term_variable) : string =
  t

let rec string_of_raw_term t = match t with
  | Grammar.TermVariable x -> x
  | Grammar.TermTypeTag (tag, typ) ->
    Printf.sprintf
      "{ %s = %s }"
      tag
      (string_of_raw_typ typ)
  | Grammar.TermAbstraction (var, typ, term) ->
    Printf.sprintf
      "λ(%s : %s) %s"
      var
      (string_of_raw_typ typ)
      (string_of_raw_term term)
  | Grammar.TermVarApplication (x, y) ->
    Printf.sprintf
      "%s %s"
      x
      y
  | Grammar.TermLet (x, t, u) ->
    Printf.sprintf
      "let %s = %s in %s"
      x
      (string_of_raw_term t)
      (string_of_raw_term u)

and string_of_raw_typ t = match t with
  | Grammar.TypeTop -> "Any"
  | Grammar.TypeBottom -> "Nothing"
  | Grammar.TypeDeclaration (x, l, h) ->
    Printf.sprintf
      "{ %s : %s .. %s }"
      x
      (string_of_raw_typ l)
      (string_of_raw_typ h)
  | Grammar.TypeProjection (x, a) ->
    Printf.sprintf
      "%s.%s"
      (string_of_term_variable x)
      a
  | Grammar.TypeDependentFunction (x, typ1, typ2) ->
    Printf.sprintf
      "∀(%s : %s) %s"
      x
      (string_of_raw_typ typ1)
      (string_of_raw_typ typ2)

let string_of_nominal_term t =
  string_of_raw_term (GrammarConverter.raw_term_of_nominal_term t)

let nominal_term t =
  Printf.printf "%s" (string_of_nominal_term t)

let raw_term t =
  Printf.printf "%s" (string_of_raw_term t)
