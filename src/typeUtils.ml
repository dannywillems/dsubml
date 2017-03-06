exception NotATypeDeclaration of Grammar.nominal_typ
exception NotADependentFunction of Grammar.nominal_typ

let tuple_of_type_declaration t = match t with
  | Grammar.TypeDeclaration(l, s, t) -> (l, s, t)
  | _ -> raise (NotATypeDeclaration t)

let tuple_of_dependent_function t = match t with
  | Grammar.TypeDependentFunction(s, (x, t)) ->
    (s, (x, t))
  | _ -> raise (NotADependentFunction t)
