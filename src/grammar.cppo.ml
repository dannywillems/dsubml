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

  (* ----- Unofficial terms ----- *)
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

(* The top level let bindings are separated from the terms. A top level term is either a usual term or a top level term. *)
type ('bn, 'fn) top_level_term =
  | Term of ('bn, 'fn) term
  (* let x : T = t -> Top level definition. Must never appear in a term *)
  | TopLevelLet of 'fn * ('bn, 'fn) typ * ('bn, 'fn) term

(* ------------------------------------------------ *)
(* Concrete types of terms and types *)
type raw_term = (string, string) term
type raw_typ = (string, string) typ
type raw_top_level_term = (string, string) top_level_term

type nominal_term = (Atom.t, Atom.t) term
type nominal_typ = (Atom.t, Atom.t) typ
type nominal_top_level_term = (Atom.t, Atom.t) top_level_term
(* ------------------------------------------------ *)

(* ------------------------------------------------ *)
(* These lines use cppo (https://github.com/mjambon/cppo ).
   It allows to generate useful functions thanks to AlphaLib.
   The generated interface and generated functions can be seen by using {make
   mli} and by opening the generated file {_build/src/grammar.inferred.mli}.
*)
#include "AlphaLibMacros.cppo.ml"

(* We decide to generate all functions AlphaLib provides, even if we don't need
   everything.
*)
__ALL
ALL(term)
ALL(typ)
