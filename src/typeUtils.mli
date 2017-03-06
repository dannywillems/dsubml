exception NotATypeDeclaration of Grammar.nominal_typ
exception NotADependentFunction of Grammar.nominal_typ

val tuple_of_type_declaration :
  Grammar.nominal_typ ->
  (Grammar.type_tag * Grammar.nominal_typ * Grammar.nominal_typ)

val tuple_of_dependent_function :
  Grammar.nominal_typ ->
  (Grammar.nominal_typ * (AlphaLib.Atom.atom * Grammar.nominal_typ))
