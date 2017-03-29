(** Utilities about types and terms. *)
exception NotATypeDeclaration of Grammar.nominal_typ
exception NotADependentFunction of Grammar.nominal_typ
exception NotAValue of Grammar.nominal_term

type direction =
  | Upper
  | Lower

(** [best_bound_for_type_declaration ~direction ~label context typ] returns the
    best bound (as an option) appearing in a type declaration (best = least
    upper if [direction] = [Upper] and greatest lower if [direction] = [Lower])
    for the given type [typ]. If no such type exist, [None] is return.

    In other words, in the case of [direction] = [Upper], this algorithm returns
    the least U such as [typ] < { A : L .. U }. In the case of [direction] =
    [Lower], it returns the greatest L such as { A : L .. U } <: [typ].

    The parameter [~label] is to check the type label.
*)
val best_bound_for_type_declaration :
  direction:direction ->
  label:Grammar.type_tag ->
  ContextType.context ->
  Grammar.nominal_typ ->
  Grammar.nominal_typ option

(** [least_upper_bound ~label context typ] is an alias to [best_bound
    ~direction:Upper ~label context typ].
*)
val least_upper_bound :
  label:Grammar.type_tag ->
  ContextType.context ->
  Grammar.nominal_typ ->
  Grammar.nominal_typ option

(** [greatest_lower_bound ~label context typ] is an alias to [best_bound
    ~direction:Lower ~label context typ].
*)
val greatest_lower_bound :
  label:Grammar.type_tag ->
  ContextType.context ->
  Grammar.nominal_typ ->
  Grammar.nominal_typ option

(** [tuple_of_dependent_function typ] returns the tuple (s, (x, t)) if the
    given type [typ] is a dependent function (TypeDependentFunction) where [s]
    is the type of the parameter [x] and [t] the return type.
    If it's not a dependent function, an exception [NotADependentFunction] is
    raised with [typ] as parameter.
*)
val best_tuple_of_dependent_function :
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

