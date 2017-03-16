(** Maps atom *)
type atom = AlphaLib.Atom.t

(** An atom is mapped to its type, the term it references and the location of its
   definition.
   This type can be extended later with more information.
*)
type t

(** Get the type of an atom based on the corresponding mapped value. *)
val typ_of_atom : atom -> Grammar.nominal_typ

(** Get the term of an atom based on the corresponding mapped value. *)
val term_of_atom : atom -> Grammar.nominal_term

(** Get definition of an atom based on the corresponding mapped value. *)
val definition_location_of_atom : atom -> string

(** Get the type of an atom based on the corresponding mapped value. *)
val typ_of_atoms : atom -> ContextType.context

(** The type of the environment. It maps atom to information type {t} *)
type env

(** Create an empty context. *)
val empty : unit -> env

(** Extend the given context with the mapping of the given atom to the given
    information
*)
val add :
  atom ->
  Grammar.nominal_typ ->
  Grammar.nominal_term ->
  string ->
  env ->
  env

(** Returns [true] if the given context is empty. *)
val is_empty : env -> bool
