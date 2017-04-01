type direction =
  | Upper
  | Lower

let rec best_bound_for_type_declaration ~direction ~label context t = match t with
  (* The least upper bound is the type declaration { A : Bottom .. Bottom }.
  And there is no greatest lower bound in the form { A : L .. U } *)
  | Grammar.TypeBottom ->
    (match direction with
    | Upper -> Some Grammar.TypeBottom
    | Lower -> None)
  (* The greatest lower bound is the type declaration { A : Top .. Top }.
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
     (* I failed in proving it's the best bound but it's at least a
        candidate.
     *)
    | Some u' -> best_bound_for_type_declaration ~direction ~label context u'
    | None -> None
    )

let least_upper_bound_of_type_declaration ~label context t =
  best_bound_for_type_declaration ~direction:Upper ~label context t

let greatest_lower_bound_of_type_declaration ~label context t =
  best_bound_for_type_declaration ~direction:Lower ~label context t

let rec least_upper_bound_of_dependent_function context t = match t with
  | Grammar.TypeDependentFunction(s, (x, t)) ->
    Some (s, (x, t))
  | Grammar.TypeBottom ->
    Some (
      Grammar.TypeTop,
      ((AlphaLib.Atom.fresh "_"), Grammar.TypeBottom)
    )
  | Grammar.TypeTop -> None
  | Grammar.TypeDeclaration(_) -> None
  | Grammar.TypeProjection(x, label) ->
    (* Si on a T = x.A, on a x de la forme { A : L .. U }. On fait alors appel à
       least_upper_bound pour récupérer le plus petit U tel que T <: U et on
       applique de nouveau least_upper_bound_of_dependent_function sur U pour
       récupérer le plus U' tel que U' est de la forme ∀(x : S') T'.
    *)
    let type_of_x = ContextType.find x context in
    let least_upper_bound =
      least_upper_bound_of_type_declaration ~label context type_of_x
    in
    (match least_upper_bound with
    | None -> None
    | Some u -> least_upper_bound_of_dependent_function context u
    )

let is_value t = match t with
  | Grammar.TermTypeTag (_) | Grammar.TermAbstraction (_) -> true
  | _ -> false
