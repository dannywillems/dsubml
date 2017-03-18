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

(* Not sure it's OK and useful. See branch [is_type_declaration]
let rec is_type_declaration context typ = match typ with
  | Grammar.TypeDeclaration _ -> true
  | Grammar.TypeProjection (var, tag) ->
    let type_of_var = ContextType.find var context in
    is_type_declaration context type_of_var
  | _ -> false
*)
let as_value t =
  if is_value t
  then t
  else raise (NotAValue t)
