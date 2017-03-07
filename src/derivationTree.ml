type 'derivation subtyping_node = {
  rule : string;
  env : ContextType.context;
  s : 'derivation;
  t : 'derivation;
}

type 'node_value t =
  | Empty
  | Node of 'node_value * 'node_value t list

let rec ( ^* ) s n = match n with
  | 0 -> ""
  | 1 -> s
  | n when n > 0 -> s ^ (s ^* (n - 1))
  | _ -> s

let rec string_of_subtyping_derivation_tree level t = match t with
  | Empty -> ""
  | Node (v, children) ->
    Printf.sprintf
      "%s%s (%s ⊦ %s <: %s)\n%s"
      (" " ^* (level * 2))
      v.rule
      (ContextType.string_of_context v.env)
      (Print.Style.string_of_raw_typ [ANSITerminal.cyan] (Grammar.show_typ v.s))
      (Print.Style.string_of_raw_typ [ANSITerminal.cyan] (Grammar.show_typ v.t))
      (String.concat "\n" (List.map (string_of_subtyping_derivation_tree (level + 1)) children))
