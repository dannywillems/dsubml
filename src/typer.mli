exception TypeMismatch of string * (Grammar.nominal_typ * Grammar.nominal_typ)

val type_of :
  ?context:ContextType.context ->
  Grammar.nominal_term ->
  DerivationTree.typing_node DerivationTree.t * Grammar.nominal_typ
