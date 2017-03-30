(** Utilities about types and terms. *)
exception NotATypeDeclaration of Grammar.nominal_typ
exception NotADependentFunction of Grammar.nominal_typ
exception NotAValue of Grammar.nominal_term

(** [least_upper_bound_of_type_declaration ~label context typ] returns the least upper bound
    (as an option) appearing in a type declaration
    for the given type [typ]. If no such type exists, it returns [None].

    In other words, this algorithm returns
    the least U such as [typ] <: { A : L .. U }.

    The parameter [~label] is to check the type label.
*)
val least_upper_bound_of_type_declaration :
  label:Grammar.type_tag ->
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
  label:Grammar.type_tag ->
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

(* Not sure it's OK and useful. See branch [is_type_declaration]
(** [is_type_declaration context typ] returns [true] if [typ] is a type
    declaration (i.e. a module). It also considers the nested type declarations
    i.e. when the variable [x] in a type projection [x.A] is an alias of [y.A]
    in the context [context] where [y] is a type declaration.
*)
val is_type_declaration :
  ContextType.context ->
  Grammar.nominal_typ ->
  bool
*)

(** [as_value term] returns [term] if it's a value, else raise an exception
    [NotAValue].
*)
val as_value :
  Grammar.nominal_term ->
  Grammar.nominal_term

