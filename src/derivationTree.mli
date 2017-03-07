type subtyping_node = {
  rule : string;
  env : ContextType.context;
  s : Grammar.nominal_typ;
  t : Grammar.nominal_typ;
}

type typing_node = {
  rule : string;
  env : ContextType.context;
  term : Grammar.nominal_term;
  typ : Grammar.nominal_typ;
}

type 'node_value t =
  | Empty
  | Node of 'node_value * 'node_value t list

val string_of_subtyping_derivation_tree :
  int ->
  subtyping_node t ->
  string
