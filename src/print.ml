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
      "(%s %s)"
      x
      y
  | Grammar.TermLet (t, (x, u)) ->
    Printf.sprintf
      "let %s = %s in %s"
      x
      (string_of_raw_term t)
      (string_of_raw_term u)
  | Grammar.TermAscription (t, typ_of_t) ->
    Printf.sprintf
      "%s : %s"
      (string_of_raw_term t)
      (string_of_raw_typ typ_of_t)

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

let string_of_nominal_term t =
  string_of_raw_term (Grammar.show_term t)

let string_of_nominal_typ t =
  string_of_raw_typ (Grammar.show_typ t)

let raw_term t =
  Printf.printf "%s" (string_of_raw_term t)

let raw_typ t =
  Printf.printf "%s" (string_of_raw_typ t)

let nominal_term t =
  Printf.printf "%s" (string_of_raw_term (Grammar.show_term t))

let nominal_typ t =
  Printf.printf "%s" (string_of_raw_typ (Grammar.show_typ t))

module Style = struct
  let string_of_raw_term style t =
    ANSITerminal.sprintf
      style
      "%s"
      (string_of_raw_term t)

  let string_of_raw_typ style t =
    ANSITerminal.sprintf
      style
      "%s"
      (string_of_raw_typ t)

  let string_of_nominal_term style t =
    (string_of_raw_term style (Grammar.show_term t))

  let string_of_nominal_typ style t =
    (string_of_raw_typ style (Grammar.show_typ t))

  let raw_term style t =
    ANSITerminal.printf
      style
      "%s"
      (string_of_raw_term style t)

  let raw_typ style t =
    ANSITerminal.printf
      style
      "%s"
      (string_of_raw_typ style t)

  let nominal_term style t =
      raw_term style (Grammar.show_term t)

  let nominal_typ style t =
      raw_typ style (Grammar.show_typ t)
end

