open AlphaLib
open BindingForms

type type_tag = string[@opaque]

and ('bn, 'fn) term =
  | TermVariable of 'fn
  | TermTypeTag of type_tag * ('bn, 'fn) typ
  | TermAbstraction of
      ('bn, 'fn) typ * ('bn, ('bn, 'fn) term) abs
  | TermVarApplication of 'fn * 'fn
  | TermLet of ('bn, 'fn) term * ('bn, ('bn, 'fn) term) abs

and ('bn, 'fn) typ =
  | TypeTop
  | TypeBottom
  | TypeDeclaration of type_tag * ('bn, 'fn) typ * ('bn, 'fn) typ
  | TypeProjection of 'fn * type_tag
  | TypeDependentFunction of
      ('bn, 'fn) typ *
      ('bn, ('bn, 'fn) typ) abs

[@@deriving
  visitors {
    variety = "map" ;
    ancestors = ["BindingForms.map"]
  },
  visitors {
    variety = "iter" ;
    ancestors = ["BindingForms.iter"]
  },
  visitors {
    variety = "iter2" ;
    ancestors = ["BindingForms.iter2"]
  }
]

type raw_term = (string, string) term
type raw_typ = (string, string) typ

type nominal_term = (Atom.t, Atom.t) term
type nominal_typ = (Atom.t, Atom.t) typ

#include "AlphaLibMacros.cppo.ml"
__ALL
ALL(term)
ALL(typ)
