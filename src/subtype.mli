(** Module for the subtyping algorithm. *)

(** [subtype s t] returns a tuple (derivation_tree, is_subtype) where
    [is_subtype] is [true] if [s] is a subtype of [t] and [derivation_tree] is
    the corresponding subtyping derivation tree.
*)
val subtype :
  ?context:ContextType.context ->
  Grammar.nominal_typ ->
  Grammar.nominal_typ ->
  (DerivationTree.subtyping_node DerivationTree.t * bool)

val is_subtype :
  ?context:ContextType.context ->
  Grammar.nominal_typ ->
  Grammar.nominal_typ ->
  bool
