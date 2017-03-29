(**
   This exception is raised when a type s is used as a subtype of t but s is not
   a subtype of t.
*)
exception Subtype of string * Grammar.nominal_typ * Grammar.nominal_typ

(** The avoidance problem is a special case of using a variable x inside the
    type of x in a dependent function type or in the type of a let expression.
    Why do we need to give importance to the avoidance problem?
    Suppose we have let x = t in u : U avec U qui est le type x.A.
    Le binding de la variable x n'est pas que local: il ne pourra pas être
    utilisé en dehors de l'expression u. Cela implique que le type x.A n'a pas
    de sens en dehors de l'expression let. Or, le type de U pourrait être
    utilisé dans le context global, et donc on pourrait faire référence à la
    variable x dans le contexte globale alors que la variable n'existe que
    localement.
*)
exception AvoidanceProblem of string * AlphaLib.Atom.t * Grammar.nominal_typ

exception TypeMismatch of string * (Grammar.nominal_typ * Grammar.nominal_typ)

exception NotWellFormed of ContextType.context * Grammar.nominal_typ

exception NotADependentFunction of Grammar.nominal_typ

val check_well_formedness :
  ContextType.context ->
  Grammar.nominal_typ ->
  unit

val check_avoidance_problem :
  AlphaLib.Atom.t ->
  Grammar.nominal_typ ->
  unit

val check_type_match :
  ContextType.context ->
  Grammar.nominal_term ->
  Grammar.nominal_typ ->
  Grammar.nominal_typ ->
  unit

val check_subtype :
  ContextType.context ->
  Grammar.nominal_typ ->
  Grammar.nominal_typ ->
  unit

val print : exn -> unit
