type 'a subtyping_node = {
  rule: string;
  env : ContextType.context;
  s : 'a;
  t : 'a
}

type 'a t =
  | Empty
  | Node of 'a subtyping_node * 'a t list

val string_of_subtyping_derivation_tree : int -> Grammar.nominal_typ t -> string
