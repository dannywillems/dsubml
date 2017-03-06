exception NotATypeDeclaration of Grammar.nominal_typ

let tuple_of_type_declaration t = match t with
  | Grammar.TypeDeclaration(l, s, t) -> (l, s, t)
  | _ -> raise (NotATypeDeclaration t)
