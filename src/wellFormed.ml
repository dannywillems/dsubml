let well_formed context typ = match typ with
  | Grammar.TypeProjection(var, typ) ->
    let typ_of_var = ContextType.find var context in
    Subtype.is_subtype ~context typ_of_var (Grammar.TypeDeclaration("A", Grammar.TypeBottom, Grammar.TypeTop))
  | _ -> true
