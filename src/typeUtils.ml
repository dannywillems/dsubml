exception NotATypeDeclaration of Grammar.nominal_typ
exception NotADependentFunction of Grammar.nominal_typ
exception NotAValue of Grammar.nominal_term

(* Need to find an invariant. We suppose the [t] is well formed. *)
let rec tuple_of_type_declaration context t = match t with
  (* The type of the given variable is a module. *)
  | Grammar.TypeDeclaration(l, s, t) ->
    (l, s, t)
  (* Else, it's a path selection type. Suppose it's x.A. We need to find the
     real type of x. As we select the type tag A on the variable x, x is also a
     module with a type A. The type A is between two types, saying S and T.
     S and T must be respectively a sub-type and a super-type of a module
     containing a type tag A.
     S and T can be Nothing, Any of a module, but not a dependent function
     (because we suppose t is well formed.
  *)
  | Grammar.TypeProjection(x, label) ->
    let type_of_x = ContextType.find x context in
    (* Recursive call to the algorithm. It is supposed it returns the tuple
       containing the label, the lower bound and the upper bound.
    *)
    let (l, s, t) = tuple_of_type_declaration context type_of_x in
    (* We check the labels are the same. Useless in Dsubml since there is only the label A *)
    tuple_of_type_declaration context t
  | _ -> raise (NotATypeDeclaration t)

let tuple_of_dependent_function t = match t with
  | Grammar.TypeDependentFunction(s, (x, t)) ->
    (s, (x, t))
  | _ -> raise (NotADependentFunction t)

let is_value t = match t with
  | Grammar.TermTypeTag (_) | Grammar.TermAbstraction (_) -> true
  | _ -> false

(* Not sure it's OK and useful. See branch [is_type_declaration]
let rec is_type_declaration context typ = match typ with
  | Grammar.TypeDeclaration _ -> true
  | Grammar.TypeProjection (var, tag) ->
    let type_of_var = ContextType.find var context in
    is_type_declaration context type_of_var
  | _ -> false
*)
let as_value t =
  if is_value t
  then t
  else raise (NotAValue t)
