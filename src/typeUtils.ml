exception NotATypeDeclaration of Grammar.nominal_typ
exception NotADependentFunction of Grammar.nominal_typ
exception NotAValue of Grammar.nominal_term

type direction =
  | Upper
  | Lower

(* Need to find an invariant. We suppose the [t] is well formed. *)
let rec best_bound_for_type_declaration ~direction ~label context t = match t with
  (* The best least upper bound is the type declaration { A : Bottom .. Bottom }.
  And there is no greatest lower bound in the form { A : L .. U } *)
  | Grammar.TypeBottom ->
    (match direction with
    | Upper -> Some Grammar.TypeBottom
    | Lower -> None)
  (* The best greatest lower bound is the type declaration { A : Top .. Top }.
  And there is no least upper bound in the form { A : L .. U } *)
  | Grammar.TypeTop ->
    (match direction with
    | Lower -> Some Grammar.TypeTop
    | Upper -> None)
  (* No comparable *)
  | Grammar.TypeDependentFunction(_) ->
    None
  (* The type of the given variable is a module. *)
  | Grammar.TypeDeclaration(l, s, t) ->
    assert (String.equal l label);
    (match direction with
     | Lower -> Some s
     | Upper -> Some t)
  (* Else, it's a path selection type. *)
  | Grammar.TypeProjection(x, label_selected) ->
    let type_of_x = ContextType.find x context in
    (* Recursive call to the algorithm. It is supposed to return the greatest
       lower bound (resp. the least upper bound) of x wrt the label given by
       [label_selected].
       [u'] is the best bound for the type of [x].
    *)
    let u' =
      best_bound_for_type_declaration
        ~direction
        ~label:label_selected
        context
        type_of_x
    in
    (match u' with
    | Some u' -> best_bound_for_type_declaration ~direction ~label context u'
    | None -> None
    )

let least_upper_bound ~label context t =
  best_bound_for_type_declaration ~direction:Upper ~label context t

let greatest_lower_bound ~label context t =
  best_bound_for_type_declaration ~direction:Lower ~label context t

(** [best_tuple_of_dependent_function ctx L] renvoie le plus petit U de la forme
    ∀(x : S) T tel que L <: U
*)
let rec best_tuple_of_dependent_function context t = match t with
  | Grammar.TypeDependentFunction(s, (x, t)) ->
    Some (s, (x, t))
  | Grammar.TypeBottom -> Some (Grammar.TypeTop, ((AlphaLib.Atom.fresh "_"), Grammar.TypeBottom))
  | Grammar.TypeTop -> None
  | Grammar.TypeDeclaration(_) -> None
  (* Si on a L = x.A, on a x de la forme { A : L .. U }. On fait alors appel à
     least_upper_bound pour récupérer le plus petit U tel que L <: U et on
     applique de nouveau best_tuple_of_dependent_function sur U pour récupérer le
     plus U' tel que U' est de la forme ∀(x : S) T.
  *)
  | Grammar.TypeProjection(x, label) ->
    let least_upper_bound = least_upper_bound ~label context t in
    (match least_upper_bound with
    | None -> None
    | Some u -> best_tuple_of_dependent_function context u
    )


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

