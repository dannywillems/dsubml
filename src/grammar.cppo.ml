open AlphaLib
open BindingForms

type type_tag = string[@opaque]

and ('bn, 'fn) term =
  (* x *)
  | TermVariable of 'fn
  (* { A = T } *)
  | TermTypeTag of type_tag * ('bn, 'fn) typ
  (* λ(x : S) t --> (S, (x, t)) *)
  | TermAbstraction of
      ('bn, 'fn) typ * ('bn, ('bn, 'fn) term) abs
  (* x y *)
  | TermVarApplication of 'fn * 'fn
  (* let x = t in u --> (t, (x, u))*)
  | TermLet of ('bn, 'fn) term * ('bn, ('bn, 'fn) term) abs
  (* t : T *)
  | TermAscription of ('bn, 'fn) term * ('bn, 'fn) typ

and ('bn, 'fn) typ =
  (* Top type : ⊤ *)
  | TypeTop
  (* Bottom type : ⟂ *)
  | TypeBottom
  (* { L : S..T } --> (L, S, T) *)
  | TypeDeclaration of type_tag * ('bn, 'fn) typ * ('bn, 'fn) typ
  (* x.L *)
  | TypeProjection of 'fn * type_tag
  (* ∀(x : S) T --> (S, (x, T)) *)
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
  },
  visitors {
    variety = "endo" ;
    ancestors = ["BindingForms.endo"]
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
