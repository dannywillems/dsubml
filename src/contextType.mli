(** This module provides an abstraction of context for algorithm about types for DOT.
    A context is a list of couple (x, T) where x is a term variable and T is a type.
    It is supposed to be used with [AlphaLib] and that terms are represented in
    nominal form (with {AlphaLib.Atom.t}).

    This abstraction of contexts is useful for subtyping and type
    inference algorithms.
    For an abstraction of context for evaluation, see {!ContextEvaluation}.
*)

(** The type of term variable. *)
type key = AlphaLib.Atom.t

type t = Grammar.nominal_typ

type context

val empty : unit -> context

val add : key -> t -> context -> context

val is_empty : context -> bool
