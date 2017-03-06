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
  | Grammar.TermLet(u, (x, t)) ->
    let t_typ = type_of_internal context t in
    (* It implies that x has the type of t, i.e. t_typ *)
    let x_typ = t_typ in
    let context' = ContextType.add x x_typ context in
    let u_typ = type_of_internal context' u in
    u_typ
  (* VAR *)
  | Grammar.TermVariable x ->
    ContextType.find x context
  (* ALL-E *)
  (* | Grammar.TermVarApplication(x, y) -> *)
  (* TODO: SUB *)
  | _ -> Grammar.TypeTop

let type_of term =
  type_of_internal (ContextType.empty ()) term
