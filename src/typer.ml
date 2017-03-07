exception TypeMismatch of string * (Grammar.nominal_typ * Grammar.nominal_typ)

let rec type_of_internal history context term = match term with
  (* ALL-I *)
  | Grammar.TermAbstraction(s_typ, (x, t)) ->
    let context' = ContextType.add x s_typ context in
    let u_history, type_of_t = type_of_internal history context' t in
    let typ = Grammar.TypeDependentFunction(s_typ, (x, type_of_t)) in
    let typing_node = DerivationTree.{
        rule = "ALL-I";
        env = context;
        term = term;
        typ = typ
      }
    in (
      DerivationTree.Node(
        typing_node,
        [u_history]
      ),
      typ
    )
  (* TYP-I *)
  | Grammar.TermTypeTag(a, typ) ->
    let typ = Grammar.TypeDeclaration(a, typ, typ) in
    let typing_node = DerivationTree.{
        rule = "TYP-I";
        env = context;
        term = term ;
        typ = typ ;
      }
    in (
      DerivationTree.Node(
        typing_node,
        []
      ),
      typ
    )
  (* LET *)
  | Grammar.TermLet(t, (x, u)) ->
    let left_history, t_typ = type_of_internal history context t in
    (* It implies that x has the type of t, i.e. t_typ *)
    let x_typ = t_typ in
    let context' = ContextType.add x x_typ context in
    let right_history, u_typ = type_of_internal history context' u in
    let typing_node = DerivationTree.{
        rule = "LET";
        env = context;
        term = term;
        typ = u_typ
      }
    in (
      DerivationTree.Node(
        typing_node,
        [left_history ; right_history]
      ),
      u_typ
    )
  (* VAR *)
  | Grammar.TermVariable x ->
    let typ = ContextType.find x context in
    let typing_node = DerivationTree.{
        rule = "VAR";
        env = context;
        term = term;
        typ = typ;
      }
    in (
      DerivationTree.Node(
        typing_node,
        []
      ),
      typ
    )
  (* ALL-E. TODO --> Need an idea to substitute. *)
  | Grammar.TermVarApplication(x, y) ->
    (* Hypothesis, get the corresponding types of x and y *)
    (* We can simply use [ContextType.find x context], but it's to avoid
       duplicating code for the history construction.
    *)
    let history_x, type_of_x =
      type_of_internal history context (Grammar.TermVariable x)
    in
    let history_y, type_of_y =
      type_of_internal history context (Grammar.TermVariable y)
    in
    (* Check if x is a dependent function. *)
    (* let x1 = s in t *)
    let (s, (x1, t)) = TypeUtils.tuple_of_dependent_function type_of_x in
    let subtype_history, is_subtype = Subtype.subtype ~context type_of_y s in
    if is_subtype
    then (
      let sigma = AlphaLib.Atom.Map.singleton x1 s in
      let typ = AlphaLib.KitSubst.apply Grammar.copy_typ sigma t x1 in
      let typing_node = DerivationTree.{
          rule ="ALL-E";
          env = context;
          term = term;
          typ = typ
        }

      in
      let node = DerivationTree.Node(
          typing_node,
          [history_x ; history_y]
        )
      in
      node, typ
    )
    else raise
        (TypeMismatch (
            Printf.sprintf
              "ALL-E: %s must be a subtype of %s but it's of type %s."
              (AlphaLib.Atom.show y)
              (Print.string_of_raw_typ (Grammar.show_typ s))
              (Print.string_of_raw_typ (Grammar.show_typ type_of_y)),
          (s, type_of_y)
          )
        )
  (* Unofficial typing rules *)
  (* UN-ASC *)
  | Grammar.TermAscription(t, typ_of_t) ->
    let typing_node = DerivationTree.{
        rule = "UN-ASC";
        env = context;
        term = term;
        typ = typ_of_t;
      }
    in
    let node = DerivationTree.Node(
        typing_node,
        history
      )
    in
    node, typ_of_t

let type_of term =
  type_of_internal [] (ContextType.empty ()) term
