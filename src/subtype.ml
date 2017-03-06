exception NotATypeDeclaration of Grammar.nominal_typ

let tuple_of_type_declaration t = match t with
  | Grammar.TypeDeclaration(l, s, t) -> (l, s, t)
  | _ -> raise (NotATypeDeclaration t)

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
  (* REFL. FIXME α-equality OK?
     Seems OK but must be more tested.
     By the way, is it very useful? Like TRANS, could it be implied by other
     rules based on the types structure?
     I don't think we can remove REFL because we can not recover the node x.A <:
     x.A with another rule. The type x.A only appears in SEL-<: and <:-SEL. If
     we want to have x.A <: x.A (or in a more general case x.A <: y.A), we need
     to create a new rule comparing bounds (maybe using TYP <: TYP). This rule
     must look after variables x and y in the environment.
     See the « unofficial » REFL-TYP.
  *)
  | (s, t) when (Grammar.equiv_typ s t) ->
    let node_value =
      DerivationTree.{
        rule = "REFL";
        env = context;
        s = s;
        t = t
    } in
    (DerivationTree.Node (node_value, history), true)
    (* NOTE: It's not a defined subtyping rule. This rule is added to distinguish
    the case Γ ⊦ x.A <: y.A. This case must not be handled by REFL because x.A
    and y.A depends on the environment.

    We call it REFL-TYP.

    NOTE: As terms/types are not recursive, the corresponding hypothesis on the
    variables must be removed from the environment. By the way, as the variable
    is unique, it doesn't matter.
    *)
  | (Grammar.TypeProjection(x1, label_selected1),
     Grammar.TypeProjection(x2, label_selected2)
    ) ->
    let label1, s1, t1 = tuple_of_type_declaration (ContextType.find x1 context) in
    let label2, s2, t2 = tuple_of_type_declaration (ContextType.find x2 context) in
    (* FIXME: We don't check that selected label are the same than label1 and
    label2 *)
    subtype_internal
      history
      context
      (Grammar.TypeDeclaration(label1, s1, t1))
      (Grammar.TypeDeclaration(label2, s2, t2))
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
    let context' = ContextType.add x1 s1 (ContextType.add x2 s2 context) in
    let left_derivation_tree, left_is_subtype =
      subtype_internal history context s2 s1
    in
    let () = print_endline "right" in
    let right_derivation_tree, right_is_subtype =
      subtype_internal history context' t1 t2
    in
    (
      DerivationTree.Node (
        node_value,
        [left_derivation_tree ; right_derivation_tree]
      ),
      left_is_subtype && right_is_subtype
    )
  (* TODO: TRANS *)
  | (_, _) -> DerivationTree.Empty, false

let subtype s t =
  subtype_internal [DerivationTree.Empty] (ContextType.empty ()) s t

let type_of_internal context term = match term with
  (* TODO: VAR *)
  (* TODO: SUB *)
  (* TODO: LET *)
  (* TODO: TYP-I *)
  (* TODO: ALL-I *)
  (* TODO: ALL-E *)
  | Grammar.TermTypeTag(type_tag, t) ->
    Grammar.TypeDeclaration(type_tag, t, t)
  | _ -> Grammar.TypeTop

let type_of term =
  type_of_internal (ContextType.empty ()) term
