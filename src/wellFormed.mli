(** [typ env typ] returns [true] if [typ] is a well formed type. We say
    a type T is well formed if T is the form x.A where x is a sub-type of a type
    declaration. To make the connection with the module language, a type is well
    formed if
    when we want to access to a type defined a module through a variable x, the
    variable x is of type module, or at least, a sub-type.

    As in the definition we allow sub-types, if x is of type Nothing, x.A is
    well-typed.
*)
val typ :
  ContextType.context ->
  Grammar.nominal_typ ->
  bool
