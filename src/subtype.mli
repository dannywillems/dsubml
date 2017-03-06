(** Module for the subtyping algorithm. *)

(** [subtype s t] returns a tuple (derivation_tree, is_subtype) where
    [is_subtype] is [true] if [s] is a subtype of [t] and [derivation_tree] is
    the corresponding subtyping derivation tree.
*)
val subtype :
  Grammar.nominal_typ ->
  Grammar.nominal_typ ->
  (Grammar.nominal_typ DerivationTree.t * bool)
