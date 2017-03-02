let rec string_of_raw_term t = match t with
  | Grammar.TermVariable x -> x
  | Grammar.TermTypeTag (tag, typ) ->
    Printf.sprintf
      "{ %s = %s }"
      tag
      (string_of_raw_typ typ)
  | Grammar.TermAbstraction (typ, (x, term)) ->
    Printf.sprintf
      "λ(%s : %s) %s"
      x
      (string_of_raw_typ typ)
      (string_of_raw_term term)
  | Grammar.TermVarApplication (x, y) ->
    Printf.sprintf
      "%s %s"
      x
      y
  | Grammar.TermLet (t, (x, u)) ->
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
      x
      a
  | Grammar.TypeDependentFunction (typ1, (x, typ2)) ->
    Printf.sprintf
      "∀(%s : %s) %s"
      x
      (string_of_raw_typ typ1)
      (string_of_raw_typ typ2)

let raw_term t =
  Printf.printf "%s" (string_of_raw_term t)

let raw_typ t =
  Printf.printf "%s" (string_of_raw_typ t)
