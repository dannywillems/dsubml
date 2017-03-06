let rec eval t = match t with
  (* let x = let y = s in t in u → let y = s in let x = t in u *)
  | Grammar.TermLet (
      Grammar.TermLet(s, (y, t)),
      (x, u)
    ) ->
    Grammar.TermLet (s, (y, Grammar.TermLet(t, (x, u))))
  (* (let x = t in u and t → t') → let x = t' in u *)
  | Grammar.TermLet (t, (x, u)) ->
    let t' = eval t in
    Grammar.TermLet (t', (x, u))
  (* (let x = v in u and u → u') → let x = v in u' *)
  | Grammar.TermLet (v, (x, u)) when TypeUtils.is_value v ->
    let u' = eval u in
    Grammar.TermLet (v, (x, u'))
  | _ -> t

