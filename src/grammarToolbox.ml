module type INPUT =
sig
  type 'a term

  type 'a typ
end

module type OUTPUT =
sig
  type 'a term
  type 'a typ

  type raw_term
  type raw_typ

  type nominal_term
  type nominal_typ
end

module Make (Input : INPUT) : (OUTPUT with type 'a term = 'a Input.term
                                       and type 'a typ = 'a Input.typ) =
struct
  type 'a term = 'a Input.term
  type 'a typ = 'a Input.typ

  type raw_term = string Input.term
  type raw_typ = string Input.typ

  type nominal_term = Nominal.t Input.term
  type nominal_typ = Nominal.t Input.typ
end
