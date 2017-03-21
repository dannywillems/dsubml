exception NotATypeDeclaration of Grammar.nominal_typ

let rec subtype_internal history context s t =
  match (s, t) with
  (* TOP
     Γ ⊦ S <: ⊤
  *)
  | (_, Grammar.TypeTop) ->
    let subtyping_node =
      DerivationTree.{
        rule = "TOP";
        env = context;
        s = s;
        t = t
    } in
    (DerivationTree.Node (subtyping_node, history), true)
  (* BOTTOM
     Γ ⊦ ⟂ <: S
  *)
  | (Grammar.TypeBottom, _) ->
    let subtyping_node =
      DerivationTree.{
        rule = "BOTTOM";
        env = context;
        s = s;
        t = t
    } in
    (DerivationTree.Node (subtyping_node, history), true)
  (* UN-REFL-TYP.
     This rule is added from the official rule to be able to remove REFL.
     The missing typing rules was for type projections. We only need to check
     that the variables are represented by the same atom.

     NOTE: The when statement is mandatory!
     If we don't mention it, and do the atom equality checking in the body of
     the expression for this pattern, it won't work because the algorithm choose
     this pattern instead of SEL <: or <: SEL.
     Γ ⊦ x.A <: x.A.
  *)
  | Grammar.TypeProjection(x, label_x), Grammar.TypeProjection(y, label_y)
    when (String.equal label_x label_y) && (AlphaLib.Atom.equal x y) ->
    let subtyping_node =
      DerivationTree.{
        rule = "UN-REFL-TYP";
        env = context;
        s = s;
        t = t
    } in
    (
      DerivationTree.Node (subtyping_node, history),
      true
    )
  (* TYP <: TYP
     Γ ⊦ S2 <: S1 ∧ Γ ⊦ T1 <: T2 =>
     Γ ⊦ { A : S1 .. T1 } <: { A : S2 .. T2 }
  *)
  | Grammar.TypeDeclaration(tag1, s1, t1), Grammar.TypeDeclaration(tag2, s2, t2) ->
    let subtyping_node =
      DerivationTree.{
        rule = "TYP <: TYP";
        env = context;
        s = s;
        t = t
    } in
    let left_derivation_tree, left_is_subtype =
      subtype_internal history context s2 s1
    in
    let right_derivation_tree, right_is_subtype =
      subtype_internal history context t1 t2
    in
    (
      DerivationTree.Node (
        subtyping_node,
        [left_derivation_tree ; right_derivation_tree]
      ),
      String.equal tag1 tag2 && left_is_subtype && right_is_subtype
    )
  (* SEL <:.
     SUB is allowed for upper bound. This rule unifies official SEL <: and SUB.
     This rule unifies the SUB and SEL
     <:. Γ ⊦ x : { A : L .. U } => Γ ⊦ x.A <: U
     becomes
     Γ ⊦ x : { A : L .. U } and Γ ⊦ U <: U' => Γ ⊦ x.A <: U'
  *)
  | (Grammar.TypeProjection(x, label_selected), u') ->
    let subtyping_node =
      DerivationTree.{
        rule = "SEL <:";
        env = context;
        s = s;
        t = t
    } in
    let type_of_x = ContextType.find x context in
    let (label, l, u) =
      TypeUtils.tuple_of_type_declaration context type_of_x
    in
    let derivation_tree_subtype, is_subtype =
      subtype_internal history context u u'
    in
    (
      DerivationTree.Node (subtyping_node, [derivation_tree_subtype]),
      String.equal label label_selected && is_subtype
    )
  (* <: SEL.
     SUB is allowed for lower bound. This rule unifies official <: SEL and SUB.
     Γ ⊦ x : { A : L .. U } =>
     Γ ⊦ L <: x.A
     becomes
     Γ ⊦ x : { A : L' .. U } ∧ Γ ⊦ L <: L' =>
     Γ ⊦ L <: x.A
  *)
  | (l, Grammar.TypeProjection(x, label_selected)) ->
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
    let type_of_x =
      ContextType.find x context
    in
    let (label, l', u) =
      TypeUtils.tuple_of_type_declaration context type_of_x
    in
    let derivation_tree_subtype, is_subtype =
      subtype_internal history context l l'
    in
    (
      DerivationTree.Node (subtyping_node, [derivation_tree_subtype]),
      String.equal label label_selected && is_subtype
    )

  (* ALL <: ALL
     Γ ⊦ S2 <: S1 ∧ Γ, x : S2 ⊦ T1 <: T2 =>
     Γ ⊦ ∀(x : S1) T1 <: ∀(x : S2) T2
  *)
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
    (* We create a new variable x and replace x1 (resp. x2) in t1 (resp. t2) by
       the resulting variable. With this method, we can only add (x : S2) in the
       environment.
    *)
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

let rec subtype_with_refl_internal history context s t = match (s, t) with
  (* TOP
     Γ ⊦ S <: TOP
  *)
  | (_, Grammar.TypeTop) ->
    let subtyping_node =
      DerivationTree.{
        rule = "TOP";
        env = context;
        s = s;
        t = t
    } in
    (DerivationTree.Node (subtyping_node, history), true)
  (* BOTTOM
     Γ ⊦ BOTTOM <: S
  *)
  | (Grammar.TypeBottom, _) ->
    let subtyping_node =
      DerivationTree.{
        rule = "BOTTOM";
        env = context;
        s = s;
        t = t
    } in
    (DerivationTree.Node (subtyping_node, history), true)
  (* REFL
     Γ ⊦ S <: S
  *)
  | (s, t) when Grammar.equiv_typ s t ->
    let subtyping_node = DerivationTree.{
        rule = "REFL";
        env = context;
        s = s;
        t = t;
      }
    in
    (DerivationTree.Node(subtyping_node, history), true)
  (* TYP <: TYP
     Γ ⊦ S2 <: S1 ∧ Γ ⊦ T1 <: T2 =>
     Γ ⊦ { A : S1 .. T1 } <: { A : S2 .. T2 }
  *)
  | Grammar.TypeDeclaration(tag1, s1, t1), Grammar.TypeDeclaration(tag2, s2, t2) ->
    let subtyping_node =
      DerivationTree.{
        rule = "TYP <: TYP";
        env = context;
        s = s;
        t = t
    } in
    let left_derivation_tree, left_is_subtype =
      subtype_with_refl_internal history context s2 s1
    in
    let right_derivation_tree, right_is_subtype =
      subtype_with_refl_internal history context t1 t2
    in
    (
      DerivationTree.Node (subtyping_node, [left_derivation_tree ; right_derivation_tree]),
      String.equal tag1 tag2 && left_is_subtype && right_is_subtype
    )
  (* <: SEL. SUB is allowed for lower bound.
     Γ ⊦ x : { A : L .. U } =>
     Γ ⊦ L <: x.A
     becomes
     Γ ⊦ x : { A : L' .. U } ∧ Γ ⊦ L <: L' =>
     Γ ⊦ L <: x.A
  *)
  | (l, Grammar.TypeProjection(x, label_selected)) ->
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
    let type_of_x =
      ContextType.find x context
    in
    let (label, l', u) =
      TypeUtils.tuple_of_type_declaration context type_of_x
    in
    let derivation_tree_subtype, is_subtype =
      subtype_internal history context l l'
    in
    (
      DerivationTree.Node (subtyping_node, [derivation_tree_subtype]),
      String.equal label label_selected && is_subtype
    )
  (* SEL <:. SUB is allowed for upper bound.
     Γ ⊦ x : { A : L .. U } => Γ ⊦ x.A <: U
     becomes
     Γ ⊦ x : { A : L .. U } and Γ ⊦ U <: U' => Γ ⊦ x.A <: U'
  *)
  | (Grammar.TypeProjection(x, label_selected), u') ->
    let subtyping_node =
      DerivationTree.{
        rule = "SEL <:";
        env = context;
        s = s;
        t = t
    } in
    let type_of_x =
      ContextType.find x context
    in
    let (label, l, u) =
      TypeUtils.tuple_of_type_declaration context type_of_x
    in
    let derivation_tree_subtype, is_subtype =
      subtype_internal history context u u'
    in
    (
      DerivationTree.Node (subtyping_node, [derivation_tree_subtype]),
      String.equal label label_selected && is_subtype
    )
  (* ALL <: ALL
     Γ ⊦ S2 <: S1 ∧ Γ, x : S2 ⊦ T1 <: T2 =>
     Γ ⊦ ∀(x : S1) T1 <: ∀(x : S2) T2
  *)
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
    (* We create a new variable x and replace x1 (resp. x2) in t1 (resp. t2) by
       the resulting variable. With this method, we can only add (x : S2) in the
       environment.
    *)
    let x = AlphaLib.Atom.copy x1 in
    let t1' = Grammar.rename_typ (AlphaLib.Atom.Map.singleton x1 x) t1 in
    let t2' = Grammar.rename_typ (AlphaLib.Atom.Map.singleton x2 x) t2 in
    let context' = ContextType.add x s2 context in
    let left_derivation_tree, left_is_subtype =
      subtype_with_refl_internal history context s2 s1
    in
    let right_derivation_tree, right_is_subtype =
      subtype_with_refl_internal history context' t1' t2'
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

let subtype ?(with_refl = false) ?(context = ContextType.empty ()) s t =
  if with_refl then subtype_with_refl_internal [DerivationTree.Empty] context s t
  else subtype_internal [DerivationTree.Empty] context s t

let is_subtype ?(with_refl = false) ?(context = ContextType.empty ()) s t =
  let _, b = subtype ~with_refl ~context s t in b
