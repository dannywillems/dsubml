(** NOT USED ANYMORE.
    Not removed if we need it.
    This modules must never be used because the syntax of DSub is not stable by
    substitution (but renaming is OK).
*)
exception TypeError of string

let rec substitute x typ t =
  match t with
  (* We don't need to change anything if it's bottom or top *)
  | Grammar.TypeTop -> Grammar.TypeTop
  | Grammar.TypeBottom -> Grammar.TypeBottom
  (* The variable can appear in the lower and upper bound of a type declaration,
     so we apply the substitution
  *)
  | Grammar.TypeDeclaration(label, lower, upper) ->
    let lower' = substitute x typ lower in
    let upper' = substitute x typ upper in
    Grammar.TypeDeclaration(label, lower', upper')
  (* It's more complicated for a type projection.   *)
  | Grammar.TypeProjection (x', label_selected) ->
  (* We check the variable
     in the type projection is the same than the variable we need to substitute.
  *)
    if AlphaLib.Atom.equal x' x
    then
      (* If we have a type projection/selection, the replacement value must be a
      type declaration with the same label. *)
      let  label, lower, upper = TypeUtils.tuple_of_type_declaration typ in
      (* And we also need to check label is equal (useless in DSub) *)
      if String.equal label_selected label
      then typ
      else
        let msg = Printf.sprintf
            "%s must be a type declarations because %s is a variable used in the\
            path selection %s."
            (Print.string_of_nominal_typ typ)
            (AlphaLib.Atom.show x)
            (Print.string_of_nominal_typ t)
        in
        raise (TypeError(msg))
    else t
  (* The dependent function case is the same than type declaration *)
  | Grammar.TypeDependentFunction(s, (x', t)) ->
    (* The variable to substitute (x) can appear in S or T *)
    let s' = substitute x typ s in
    let t' = substitute x typ t in
    Grammar.TypeDependentFunction(s', (x', t'))
