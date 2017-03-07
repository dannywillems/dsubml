type 'derivation subtyping_node = {
  rule: string;
  env : ContextType.context;
  s : 'derivation;
  t : 'derivation
}

type 'node_value t =
  | Empty
  | Node of 'node_value * 'node_value t list

val string_of_subtyping_derivation_tree :
  int ->
  Grammar.nominal_typ subtyping_node t ->
  string
