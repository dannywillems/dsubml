module type INPUT = sig
  type 'a term

  type 'a typ
end

module type OUTPUT = sig
  type 'a term
  type 'a typ

  type raw_term
  type raw_typ

  type nominal_term
  type nominal_typ
end

module Make : functor (Input : INPUT) -> sig
  type raw_term
  type raw_typ

  type nominal_term
  type nominal_typ
end
