type 'a term_variable = 'a

type 'a term =
  | TermVariable of 'a term_variable
  | TermTypeTag of string * 'a typ
  | TermAbstraction of 'a term_variable * 'a typ * 'a term
  | TermVarApplication of 'a term_variable * 'a term_variable
  | TermLet of 'a term_variable * 'a term * 'a term

and 'a typ =
  | TypeTop
  | TypeBottom
  | TypeDeclaration of string * 'a typ * 'a typ
  | TypeProjection of 'a term_variable * string
  | TypeDependentFunction of 'a term_variable * 'a typ * 'a typ

type raw_term = string term
type raw_typ = string typ

type nominal_term = Nominal.t term
type nominal_typ = Nominal.t typ
