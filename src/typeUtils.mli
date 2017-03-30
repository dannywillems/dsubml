(** Utilities about types and terms. *)

(** [least_upper_bound_of_type_declaration ~label context typ] returns the least upper bound
    (as an option) appearing in a type declaration
    for the given type [typ]. If no such type exists, it returns [None].

    In other words, this algorithm returns
    the least U such as [typ] <: { A : L .. U }.

    The parameter [~label] is to check the type label.
*)
val least_upper_bound_of_type_declaration :
  label:Grammar.type_label ->
  ContextType.context ->
  Grammar.nominal_typ ->
  Grammar.nominal_typ option

(** [greatest_lower_bound_of_type_declaration ~label context typ] returns the greatest lower bound
    (as an option) appearing in a type declaration for the given type [typ]. If
    no such type exists, it returns [None].

    In other words, this algorithm returns
    the greatest L such as { A : L .. U } <: [typ].

    The parameter [~label] is to check the type label.
*)
val greatest_lower_bound_of_type_declaration :
  label:Grammar.type_label ->
  ContextType.context ->
  Grammar.nominal_typ ->
  Grammar.nominal_typ option

(** [least_upper_bound_of_dependent_function ctx L] returns the least upper
    bound of L which has the form ∀(x : S) T.
*)
val least_upper_bound_of_dependent_function :
  ContextType.context ->
  Grammar.nominal_typ ->
  (Grammar.nominal_typ * (AlphaLib.Atom.atom * Grammar.nominal_typ)) option

(** [is_value term] returns [true] if [term] is a value (a lambda abstraction or
    a type tag).
*)
val is_value :
  Grammar.nominal_term ->
  bool
