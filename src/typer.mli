exception TypeMismatch of string * (Grammar.nominal_typ * Grammar.nominal_typ)
exception NotTypable of Grammar.nominal_term

val type_of :
  Grammar.nominal_term ->
  DerivationTree.typing_node DerivationTree.t * Grammar.nominal_typ
