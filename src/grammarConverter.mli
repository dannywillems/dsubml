exception AlreadyInEnvironment of (string * Env.Map.env)

exception UnboundVariable of (string * Env.Map.env)

val nominal_term_of_raw_term : Grammar.raw_term -> Grammar.nominal_term

val nominal_typ_of_raw_typ : Grammar.raw_typ -> Grammar.nominal_typ

val raw_typ_of_nominal_typ : Grammar.nominal_typ -> Grammar.raw_typ

val raw_term_of_nominal_term : Grammar.nominal_term -> Grammar.raw_term
