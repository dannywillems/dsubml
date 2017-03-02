exception Not_a_type_declaration of Grammar.nominal_typ

let tuple_of_type_declaration t = match t with
  | Grammar.TypeDeclaration(l, s, t) -> (l, s, t)
  | _ -> raise (Not_a_type_declaration t)

let rec subtype_internal context s t = match (s, t) with
  (* TOP *)
  | (_, Grammar.TypeTop) -> print_endline "TOP"; true
  (* BOTTOM *)
  | (Grammar.TypeBottom, _) -> print_endline "BOTTOM"; true
  (* REFL. FIXME α-equality OK? *)
  | (s, t) when (Grammar.equiv_typ s t) -> print_endline "REFL"; true
  (* <: SEL *)
  | (s1, Grammar.TypeProjection(x, label_selected)) ->
    let (label, s2, t2) = tuple_of_type_declaration (ContextType.find x context) in
    print_endline "<: SEL";
    (label == label_selected) &&
    (Grammar.equiv_typ s1 s2)
  (* SEL <: *)
  | (Grammar.TypeProjection(x, label_selected), t1) ->
    let (label, s2, t2) = tuple_of_type_declaration (ContextType.find x context) in
    (label == label_selected) &&
    (Grammar.equiv_typ t1 t2)
  (* ALL <: ALL *)
  | (Grammar.TypeDependentFunction(s1, (x1, t1)),
     Grammar.TypeDependentFunction(s2, (x2, t2))
    ) ->
    let context' = ContextType.add x1 s2 (ContextType.add x2 s2 context) in
    print_endline "ALL <: ALL";
    (subtype_internal context s2 s1) &&
    (subtype_internal context' t1 t2)
  (* TYP <: TYP *)
  | Grammar.TypeDeclaration(tag1, s1, t1), Grammar.TypeDeclaration(tag2, s2, t2) ->
    print_endline "TYP <: TYP";
    (tag1 == tag2) &&
    (subtype_internal context s2 s1) &&
    (subtype_internal context t1 t2)
  | (_, _) -> false

let subtype s t =
  subtype_internal (ContextType.empty ()) s t

let type_of_internal context term = match term with
| Grammar.TermTypeTag(type_tag, t) ->
  Grammar.TypeDeclaration(type_tag, t, t)
(* TODO *)
| _ -> Grammar.TypeTop

let type_of term =
  type_of_internal (ContextType.empty ()) term
