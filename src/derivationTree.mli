type 'a node_value = {
  rule: string;
  env : ContextType.context;
  s : 'a;
  t : 'a
}

type 'a t =
  | Empty
  | Node of 'a node_value * 'a t list

val to_string : int -> Grammar.nominal_typ t -> string
