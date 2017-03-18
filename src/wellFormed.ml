let typ context typ = match typ with
  | Grammar.TypeProjection(var, typ) ->
    let typ_of_var = ContextType.find var context in
    Subtype.is_subtype ~context typ_of_var (Grammar.TypeDeclaration("A", Grammar.TypeBottom, Grammar.TypeTop))
  | _ -> true

(* Is it very useful?
   Define it implies to depend on the module Typer and so we can not use
   [WellFormed.typ] in the typing algorithm.
let term context term =
  let type_of_term =
    Typer.type_of
      ~context
      term
  in
  typ context type_of_term
*)
