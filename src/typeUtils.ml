exception NotATypeDeclaration of Grammar.nominal_typ
exception NotADependentFunction of Grammar.nominal_typ
exception NotAValue of Grammar.nominal_term

let tuple_of_type_declaration t = match t with
  | Grammar.TypeDeclaration(l, s, t) -> (l, s, t)
  | _ -> raise (NotATypeDeclaration t)

let tuple_of_dependent_function t = match t with
  | Grammar.TypeDependentFunction(s, (x, t)) ->
    (s, (x, t))
  | _ -> raise (NotADependentFunction t)

let is_value t = match t with
  | Grammar.TermTypeTag (_) | Grammar.TermAbstraction (_) -> true
  | _ -> false

let as_value t =
  if is_value t
  then t
  else raise (NotAValue t)
