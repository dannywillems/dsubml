exception Not_a_type_declaration of Grammar.nominal_typ

let tuple_of_type_declaration t = match t with
  | Grammar.TypeDeclaration(l, s, t) -> (l, s, t)
  | _ -> raise (Not_a_type_declaration t)

let rec subtype_internal history context s t = match (s, t) with
  (* TOP *)
  | (_, Grammar.TypeTop) ->
    let node_value =
      DerivationTree.{
        rule = "TOP";
        env = context;
        s = s;
        t = t
    } in
    (DerivationTree.Node (node_value, history), true)
  (* BOTTOM *)
  | (Grammar.TypeBottom, _) ->
    let node_value =
      DerivationTree.{
        rule = "BOTTOM";
        env = context;
        s = s;
        t = t
    } in
    (DerivationTree.Node (node_value, history), true)
  (* REFL. FIXME α-equality OK? Seems OK but must be more tested. *)
  | (s, t) when (Grammar.equiv_typ s t) ->
    let node_value =
      DerivationTree.{
        rule = "REFL";
        env = context;
        s = s;
        t = t
    } in
    (DerivationTree.Node (node_value, history), true)
  (* <: SEL *)
  | (s1, Grammar.TypeProjection(x, label_selected)) ->
    let node_value =
      DerivationTree.{
        rule = "<: SEL";
        env = context;
        s = s;
        t = t
    } in
    let (label, s2, t2) = tuple_of_type_declaration (ContextType.find x context) in
    (
      DerivationTree.Node (node_value, history),
      (label == label_selected) && (Grammar.equiv_typ s1 s2)
    )
  (* SEL <: *)
  | (Grammar.TypeProjection(x, label_selected), t1) ->
    let node_value =
      DerivationTree.{
        rule = "SEL <:";
        env = context;
        s = s;
        t = t
    } in
    let (label, s2, t2) = tuple_of_type_declaration (ContextType.find x context) in
    (
      DerivationTree.Node (node_value, history),
      (label == label_selected) && (Grammar.equiv_typ t1 t2)
    )
  (* ALL <: ALL *)
  | (Grammar.TypeDependentFunction(s1, (x1, t1)),
     Grammar.TypeDependentFunction(s2, (x2, t2))
    ) ->
    let node_value =
      DerivationTree.{
        rule = "ALL <: ALL";
        env = context;
        s = s;
        t = t
    } in
    let context' = ContextType.add x1 s2 (ContextType.add x2 s2 context) in
    let left_derivation_tree, left_is_subtype = subtype_internal history context s2 s1 in
    let right_derivation_tree, right_is_subtype = subtype_internal history context' t1 t2 in
    (
      DerivationTree.Node (node_value, [left_derivation_tree ; right_derivation_tree]),
      left_is_subtype && right_is_subtype
    )
  (* TYP <: TYP *)
  | Grammar.TypeDeclaration(tag1, s1, t1), Grammar.TypeDeclaration(tag2, s2, t2) ->
    let node_value =
      DerivationTree.{
        rule = "TYP <: TYP";
        env = context;
        s = s;
        t = t
    } in
    let left_derivation_tree, left_is_subtype = subtype_internal history context s2 s1 in
    let right_derivation_tree, right_is_subtype = subtype_internal history context t1 t2 in
    (
      DerivationTree.Node (node_value, [left_derivation_tree ; right_derivation_tree]),
      (tag1 == tag2) && left_is_subtype && right_is_subtype
    )
  | (_, _) -> DerivationTree.Empty, false

let subtype s t =
  subtype_internal [DerivationTree.Empty] (ContextType.empty ()) s t

let type_of_internal context term = match term with
| Grammar.TermTypeTag(type_tag, t) ->
  Grammar.TypeDeclaration(type_tag, t, t)
(* TODO *)
| _ -> Grammar.TypeTop

let type_of term =
  type_of_internal (ContextType.empty ()) term
