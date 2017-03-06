exception TypeMismatch of string * (Grammar.nominal_typ * Grammar.nominal_typ)
let rec type_of_internal context term = match term with
  (* ALL-I *)
  | Grammar.TermAbstraction(s_typ, (x, t)) ->
    let context' = ContextType.add x s_typ context in
    let u = type_of_internal context' t in
    Grammar.TypeDependentFunction(s_typ, (x, u))
  (* TYP-I *)
  | Grammar.TermTypeTag(a, typ) ->
    Grammar.TypeDeclaration(a, typ, typ)
  (* LET *)
  | Grammar.TermLet(t, (x, u)) ->
    let t_typ = type_of_internal context t in
    (* It implies that x has the type of t, i.e. t_typ *)
    let x_typ = t_typ in
    let context' = ContextType.add x x_typ context in
    let u_typ = type_of_internal context' u in
    u_typ
  (* VAR *)
  | Grammar.TermVariable x ->
    ContextType.find x context
  (* ALL-E. TODO --> Need an idea to substitute. *)
  | Grammar.TermVarApplication(x, y) ->
    (* Hypothesis, get the corresponding types of x and y *)
    let type_of_x = ContextType.find x context in
    let type_of_y = ContextType.find y context in
    (* Check if x is a dependent function. *)
    let (s, (x1, t)) = TypeUtils.tuple_of_dependent_function type_of_x in
    if (Grammar.equiv_typ s type_of_y)
    then t
    else raise
        (TypeMismatch (
            "ALL-E: x must be of type dependent function", (s, type_of_y)
          )
        )
  (* TODO: SUB *)
  | _ -> Grammar.TypeTop

let type_of term =
  type_of_internal (ContextType.empty ()) term
