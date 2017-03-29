(* The main typing algorithm.
   When a type if given if the term, we check if this type is well formed.
*)
let rec type_of_internal history context term = match term with
  (* ALL-I
     Γ, x : S ⊦ t : U ∧ x ∉ FV(S)
     =>
     Γ ⊦ λ(x : S) t ⊦ ∀(x : S) U
  *)
  | Grammar.TermAbstraction(s, (x, t)) ->
    Error.check_well_formedness context s;
    Error.check_avoidance_problem x s;
    let context' = ContextType.add x s context in
    let u_history, u = type_of_internal history context' t in
    let typ = Grammar.TypeDependentFunction(s, (x, u)) in
    DerivationTree.create_typing_node
      ~rule:"ALL-I"
      ~env:context
      ~term
      ~typ
      ~history:[u_history]
  (* TYP-I
     Γ ⊦ { A = T } : { A : T .. T }
  *)
  | Grammar.TermTypeTag(a, typ) ->
    Error.check_well_formedness context typ;
    let typ = Grammar.TypeDeclaration(a, typ, typ) in
    DerivationTree.create_typing_node
      ~rule:"TYP-I"
      ~env:context
      ~term
      ~typ
      ~history:[]
  (* LET
     Γ ⊦ t : T ∧
     Γ, x : T ⊦ u : U ∧
     x ∉ FV(U)
     =>
     Γ ⊦ let x = t in u : U
  *)
  | Grammar.TermLet(t, (x, u)) ->
    let left_history, t_typ = type_of_internal history context t in
    (* It implies that x has the type of t, i.e. t_typ *)
    let x_typ = t_typ in
    let context' = ContextType.add x x_typ context in
    let right_history, u_typ = type_of_internal history context' u in
    Error.check_avoidance_problem x u_typ;
    DerivationTree.create_typing_node
      ~rule:"LET"
      ~env:context
      ~term
      ~typ:u_typ
      ~history:[left_history ; right_history]
  (* VAR
     Γ, x : T, Γ' ⊦ x : T
  *)
  | Grammar.TermVariable x ->
    let typ = ContextType.find x context in
    DerivationTree.create_typing_node
      ~rule:"VAR"
      ~env:context
      ~term
      ~typ
      ~history:[]
  (* ALL-E.
     Γ ⊦ x : ∀(z : S) : T ∧
     Γ ⊦ y : S
     =>
     Γ ⊦ xy : [y := z]T
  *)
  | Grammar.TermVarApplication(x, y) ->
    (* We can simply use [ContextType.find x context], but it's to get the
       history.
    *)
    let history_x, type_of_x =
      type_of_internal history context (Grammar.TermVariable x)
    in
    let history_y, type_of_y =
      type_of_internal history context (Grammar.TermVariable y)
    in
    (* Check if [x] is a dependent function. *)
    let dep_function_opt =
      TypeUtils.best_tuple_of_dependent_function context type_of_x
    in
    (match dep_function_opt with
    | Some (s, (z, t)) ->
      Error.check_type_match context (Grammar.TermVariable y) type_of_y s;
      (* Here, we rename the variable [z] (which is the variable in the for all
         type, by the given variable [y]). We don't substitute the variable by
         the right types because it doesn't work with not well formed types (like
         x.A when x is of types Any).
      *)
      let typ = Grammar.rename_typ (AlphaLib.Atom.Map.singleton z y) t in
      DerivationTree.create_typing_node
        ~rule:"ALL-E"
        ~env:context
        ~term
        ~typ
        ~history:[history_x ; history_y]
    | None -> raise (Error.NotADependentFunction(type_of_x))
    )
  (* ----- Unofficial typing rules ----- *)
  (* UN-ASC
     Γ ⊦ t : T
  *)
  | Grammar.TermAscription(t, typ_of_t) ->
    let actual_history, actual_typ_of_t =
      type_of_internal history context t
    in
    Error.check_well_formedness context typ_of_t;
    Error.check_subtype context actual_typ_of_t typ_of_t;
    DerivationTree.create_typing_node
      ~rule:"UN-ASC"
      ~env:context
      ~term
      ~typ:typ_of_t
      ~history:[actual_history]
  (* UN-UNIMPLEMENTED
     Γ ⊦ Unimplemented : ⟂
  *)
  | Grammar.TermUnimplemented ->
    DerivationTree.create_typing_node
      ~rule:"UN-UNIMPLEMENTED"
      ~env:context
      ~term
      ~typ:Grammar.TypeBottom
      ~history

let type_of ?(context = ContextType.empty ()) term =
  type_of_internal [] context term
