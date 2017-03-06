(** Utilities about types and terms. *)
exception NotATypeDeclaration of Grammar.nominal_typ
exception NotADependentFunction of Grammar.nominal_typ
exception NotAValue of Grammar.nominal_term

(** [tuple_of_type_declaration typ] returns the tuple (type_label, s, t) if the
    given type [typ] is a type declaration (TypeDeclaration) where [type_label]
    is a label, [s] the lower bound and [t] the upper bound.
    If it's not a type declaration, an exception [NotATypeDeclaration] is raised
    with [typ] as parameter.
*)
val tuple_of_type_declaration :
  Grammar.nominal_typ ->
  (Grammar.type_tag * Grammar.nominal_typ * Grammar.nominal_typ)

(** [tuple_of_dependent_function typ] returns the tuple (s, (x, t)) if the
    given type [typ] is a dependent function (TypeDependentFunction) where [s]
    is the type of the parameter [x] and [t] the return type.
    If it's not a dependent function, an exception [NotADependentFunction] is
    raised with [typ] as parameter.
*)
val tuple_of_dependent_function :
  Grammar.nominal_typ ->
  (Grammar.nominal_typ * (AlphaLib.Atom.atom * Grammar.nominal_typ))

(** [is_value term] returns [true] if [term] is a value (a lambda abstraction or
    a type tag).
*)
val is_value :
  Grammar.nominal_term ->
  bool

(** [as_value term] returns [term] if it's a value, else raise an exception
    [NotAValue].
*)
val as_value :
  Grammar.nominal_term ->
  Grammar.nominal_term
