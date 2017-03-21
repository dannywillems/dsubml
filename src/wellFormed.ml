(** Return [true] if [nominal_typ] is well formed. *)
let rec typ context nominal_typ = match nominal_typ with
  | Grammar.TypeTop | Grammar.TypeBottom -> true
  | Grammar.TypeDeclaration(_, s, t) -> (
    try
      let s_is_subtype_of_t =
        Subtype.is_subtype ~context s t
      in
      let s_is_well_formed =
        typ context s
      in
      let t_is_well_formed =
        typ context t
      in
      s_is_subtype_of_t &&
      s_is_well_formed &&
      t_is_well_formed
    with
    | TypeUtils.NotATypeDeclaration _ -> false)
  | Grammar.TypeProjection(var, typ) ->
    let typ_of_var = ContextType.find var context in
    let is_subtype =
      Subtype.is_subtype
        ~context
        typ_of_var
        (Grammar.TypeDeclaration("A", Grammar.TypeBottom, Grammar.TypeTop))
    in
    is_subtype
  | Grammar.TypeDependentFunction(s, (x, t)) ->
    let context' = ContextType.add x s context in
    let s_is_well_formed = typ context s in
    let t_is_well_formed = typ context' t in
    s_is_well_formed && t_is_well_formed
