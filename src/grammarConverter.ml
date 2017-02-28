(* TODO:
   If a variable is already in the environment, we must replace the
   current binding value
*)
exception AlreadyInEnvironment of (string * Env.Map.env)
exception UnboundVariable of (string * Env.Map.env)

(* ------------------------ *)
(* Raw to nominal *)
let rec nominal_term_of_raw_term_internal env t = match t with
  | Grammar.TermVariable x -> (
    try
      let n = Env.Map.lookup x env in
      Grammar.TermVariable n
    with
    | Not_found -> raise (UnboundVariable (x, env))
  )
  | Grammar.TermTypeTag (a, typ) ->
    Grammar.TermTypeTag (
      a,
      (nominal_typ_of_raw_typ_internal env typ)
    )
  | Grammar.TermAbstraction (x, typ, t) ->
    let n = Nominal.t_of_string x in
    let env' = Env.Map.extend x n env in
    Grammar.TermAbstraction (
      n,
      (nominal_typ_of_raw_typ_internal env typ),
      (nominal_term_of_raw_term_internal env' t)
    )
  | Grammar.TermVarApplication (x, y) ->
    if Env.Map.contains x env
    then (
      if Env.Map.contains y env
      then
        let n_x = Env.Map.lookup x env in
        let n_y = Env.Map.lookup y env in
        Grammar.TermVarApplication (n_x, n_y)
      else raise (UnboundVariable(y, env))
    )
    else raise (UnboundVariable(x, env))
  | Grammar.TermLet (x, t, u) ->
    let n = Nominal.t_of_string x in
    let env' = Env.Map.extend x n env in
    Grammar.TermLet(
      n,
      (nominal_term_of_raw_term_internal env t),
      (nominal_term_of_raw_term_internal env' u)
    )

and nominal_typ_of_raw_typ_internal env t = match t with
  | Grammar.TypeTop -> Grammar.TypeTop
  | Grammar.TypeBottom -> Grammar.TypeBottom
  | Grammar.TypeDeclaration (a, s, t) ->
    Grammar.TypeDeclaration (
      a,
      (nominal_typ_of_raw_typ_internal env s),
      (nominal_typ_of_raw_typ_internal env t)
    )
  | Grammar.TypeProjection (x, a) -> (
    try
      let n_x = Env.Map.lookup x env in
      Grammar.TypeProjection(n_x, a)
    with
    | Not_found -> raise (UnboundVariable (x, env))
    )
  | Grammar.TypeDependentFunction (x, s, t) ->
    let n_x = Nominal.t_of_string x in
    let env' = Env.Map.extend x n_x env in
    Grammar.TypeDependentFunction(
      n_x,
      (nominal_typ_of_raw_typ_internal env s),
      (nominal_typ_of_raw_typ_internal env' t)
    )

and nominal_term_of_raw_term t =
  nominal_term_of_raw_term_internal (Env.Map.empty ()) t

and nominal_typ_of_raw_typ t =
  nominal_typ_of_raw_typ_internal (Env.Map.empty ()) t
(* ------------------------ *)

(* ------------------------ *)
(* Nominal to raw *)
let rec raw_term_of_nominal_term_internal env t = match t with
  | Grammar.TermVariable x ->
    Grammar.TermVariable (Nominal.string_of_t x)
  | Grammar.TermTypeTag (a, typ) ->
    Grammar.TermTypeTag (
      a,
      raw_typ_of_nominal_typ_internal env typ
    )
  | Grammar.TermAbstraction (x, typ, t) ->
    (*
    let x = Env.Set.fresh_name x env in
    let env' = Env.Set.add x env in
    *)
    Grammar.TermAbstraction (
      (Nominal.string_of_t x),
      (raw_typ_of_nominal_typ_internal env typ),
      (raw_term_of_nominal_term_internal env t)
    )
  | Grammar.TermVarApplication (x, y) ->
    Grammar.TermVarApplication (
      (Nominal.string_of_t x),
      (Nominal.string_of_t y)
    )
  | Grammar.TermLet (x, t, u) ->
    (*
    let x = Env.Set.fresh_name x env in
    let env' = Env.Set.add x env in
    *)
    Grammar.TermLet (
      (Nominal.string_of_t x),
      (raw_term_of_nominal_term_internal env t),
      (raw_term_of_nominal_term_internal env u)
    )

and raw_term_of_nominal_term t =
  raw_term_of_nominal_term_internal (Env.Set.empty ()) t

and raw_typ_of_nominal_typ_internal env t = match t with
  | Grammar.TypeTop -> Grammar.TypeTop
  | Grammar.TypeBottom -> Grammar.TypeBottom
  | Grammar.TypeDeclaration (a, s, t) ->
    Grammar.TypeDeclaration (
      a,
      (raw_typ_of_nominal_typ_internal env s),
      (raw_typ_of_nominal_typ_internal env t)
    )
  | Grammar.TypeProjection (x, a) ->
    (* let x = Env.Set.fresh_name x env in *)
    Grammar.TypeProjection (
      (Nominal.string_of_t x),
      a
    )
  | Grammar.TypeDependentFunction (x, s, t) ->
    (*
    let x = Env.Set.fresh_name x env in
    let env' = Env.Set.add x env in
    *)
    Grammar.TypeDependentFunction(
      (Nominal.string_of_t x),
      (raw_typ_of_nominal_typ_internal env s),
      (raw_typ_of_nominal_typ_internal env t)
    )

and raw_typ_of_nominal_typ t =
  raw_typ_of_nominal_typ_internal (Env.Set.empty ()) t
(* ------------------------ *)
