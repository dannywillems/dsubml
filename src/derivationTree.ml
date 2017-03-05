type 'a node_value = {
  rule: string;
  env : ContextType.context;
  s : 'a;
  t : 'a;
}

type 'a t =
  | Empty
  | Node of 'a node_value * 'a t list

let rec ( ^* ) s n = match n with
  | 0 -> ""
  | 1 -> s
  | n when n > 0 -> s ^ (s ^* (n - 1))
  | _ -> s

let rec to_string level t = match t with
  | Empty -> ""
  | Node (v, children) ->
    Printf.sprintf
      "%s%s (%s ⊦ %s <: %s)\n%s"
      (" " ^* (level * 2))
      v.rule
      (ContextType.string_of_context v.env)
      (Print.Style.string_of_raw_typ [ANSITerminal.cyan] (Grammar.show_typ v.s))
      (Print.Style.string_of_raw_typ [ANSITerminal.cyan] (Grammar.show_typ v.t))
      (String.concat "\n" (List.map (to_string (level + 1)) children))
