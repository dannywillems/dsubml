(** Return [true] if [nominal_typ] is well formed. *)
let rec typ context nominal_typ = match nominal_typ with
  | Grammar.TypeTop | Grammar.TypeBottom -> true
  | Grammar.TypeDeclaration(_, s, t) -> (
    try
      (Subtype.is_subtype ~context s t) &&
      (typ context s) &&
      (typ context t)
    with
    | TypeUtils.NotATypeDeclaration _ -> false)
  | Grammar.TypeProjection(var, typ) ->
    let typ_of_var = ContextType.find var context in
    Subtype.is_subtype
      ~context
      typ_of_var
      (Grammar.TypeDeclaration("A", Grammar.TypeBottom, Grammar.TypeTop))
  | Grammar.TypeDependentFunction(s, (x, t)) ->
    let context' = ContextType.add x s context in
    (typ context s) && (typ context' t)
