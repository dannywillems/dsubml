exception NotATypeDeclaration of Grammar.nominal_typ

let rec subtype_internal history context s t = match (s, t) with
  (* TOP *)
  | (_, Grammar.TypeTop) ->
    let subtyping_node =
      DerivationTree.{
        rule = "TOP";
        env = context;
        s = s;
        t = t
    } in
    (DerivationTree.Node (subtyping_node, history), true)
  (* BOTTOM *)
  | (Grammar.TypeBottom, _) ->
    let subtyping_node =
      DerivationTree.{
        rule = "BOTTOM";
        env = context;
        s = s;
        t = t
    } in
    (DerivationTree.Node (subtyping_node, history), true)
  (* REFL-TYP.
     This rule is added from the official rule to be able to remove REFL.
     The missing typing rules was for type projections. We only need to check
     that the variables are represented by the same atom.
  *)
  | Grammar.TypeProjection(x, label_x), Grammar.TypeProjection(y, label_y) ->
    let subtyping_node =
      DerivationTree.{
        rule = "REFL-TYP";
        env = context;
        s = s;
        t = t
    } in
    (
      DerivationTree.Node (subtyping_node, history),
      (String.equal label_x label_y) && (AlphaLib.Atom.equal x y)
    )
  (* TYP <: TYP *)
  | Grammar.TypeDeclaration(tag1, s1, t1), Grammar.TypeDeclaration(tag2, s2, t2) ->
    let subtyping_node =
      DerivationTree.{
        rule = "TYP <: TYP";
        env = context;
        s = s;
        t = t
    } in
    let left_derivation_tree, left_is_subtype = subtype_internal history context s2 s1 in
    let right_derivation_tree, right_is_subtype = subtype_internal history context t1 t2 in
    (
      DerivationTree.Node (subtyping_node, [left_derivation_tree ; right_derivation_tree]),
      String.equal tag1 tag2 && left_is_subtype && right_is_subtype
    )
  (* <: SEL. TODO: SUB must be allowed! *)
  | (s1, Grammar.TypeProjection(x, label_selected)) ->
    let subtyping_node =
      DerivationTree.{
        rule = "<: SEL";
        env = context;
        s = s;
        t = t
    } in
    (* We get the corresponding label, lower bound and upper bound for the given
       variable x from the environment and we check if s1 and the lower bound are
       equivalent.
    *)
    let (label, s2, t2) = TypeUtils.tuple_of_type_declaration (ContextType.find x context) in
    (
      DerivationTree.Node (subtyping_node, history),
      String.equal label label_selected && Grammar.equiv_typ s1 s2
    )
  (* SEL <:. TODO: SUB must be allowed! *)
  | (Grammar.TypeProjection(x, label_selected), t1) ->
    let subtyping_node =
      DerivationTree.{
        rule = "SEL <:";
        env = context;
        s = s;
        t = t
    } in
    let (label, s2, t2) = TypeUtils.tuple_of_type_declaration (ContextType.find x context) in
    (
      DerivationTree.Node (subtyping_node, history),
      String.equal label label_selected && (Grammar.equiv_typ t1 t2)
    )
  (* ALL <: ALL *)
  | (Grammar.TypeDependentFunction(s1, (x1, t1)),
     Grammar.TypeDependentFunction(s2, (x2, t2))
    ) ->
    let subtyping_node =
      DerivationTree.{
        rule = "ALL <: ALL";
        env = context;
        s = s;
        t = t
    } in
    let x = AlphaLib.Atom.copy x1 in
    let t1' = Grammar.rename_typ (AlphaLib.Atom.Map.singleton x1 x) t1 in
    let t2' = Grammar.rename_typ (AlphaLib.Atom.Map.singleton x2 x) t2 in
    let context' = ContextType.add x s2 context in
    let left_derivation_tree, left_is_subtype =
      subtype_internal history context s2 s1
    in
    let right_derivation_tree, right_is_subtype =
      subtype_internal history context' t1' t2'
    in
    (
      DerivationTree.Node (
        subtyping_node,
        [left_derivation_tree ; right_derivation_tree]
      ),
      left_is_subtype && right_is_subtype
    )
  (* TODO: TRANS *)
  | (_, _) -> DerivationTree.Empty, false

let subtype ?(context = ContextType.empty ()) s t =
  subtype_internal [DerivationTree.Empty] context s t

let is_subtype ?(context = ContextType.empty ()) s t =
  let _, b = subtype ~context s t in b
