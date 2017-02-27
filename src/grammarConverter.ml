(* TODO:
   If a variable is already in the environment, we must replace the
   current binding value
*)
exception AlreadyInEnvironment of (string * Env.env)
exception NotInEnvironment of (string * Env.env)

let rec nominal_term_of_raw_term_internal env_term env_typ t = match t with
  | Grammar.TermVariable x -> (
    try
      let n = Env.lookup x env_term in
      Grammar.TermVariable n
    with
    | Not_found -> raise (NotInEnvironment (x, env_term))
    )
  | Grammar.TermTypeTag (a, typ) ->
    Grammar.TermTypeTag (
      a,
      (nominal_typ_of_raw_typ_internal env_term env_typ typ)
    )
  | Grammar.TermAbstraction (x, typ, t) ->
    let n = Nominal.t_of_string x in
    let env_term' = Env.extend x n env_term in
    Grammar.TermAbstraction (
      n,
      (* env_term' ?? *)
      (nominal_typ_of_raw_typ_internal env_term env_typ typ),
      (nominal_term_of_raw_term_internal env_term' env_typ t)
    )
  | Grammar.TermVarApplication (x, y) ->
    if Env.contains x env_term
    then (
      if Env.contains y env_term
      then
        let n_x = Env.lookup x env_term in
        let n_y = Env.lookup y env_term in
        Grammar.TermVarApplication (n_x, n_y)
      else raise (NotInEnvironment(y, env_term))
    )
    else raise (NotInEnvironment(x, env_term))
  | Grammar.TermLet (x, t, u) ->
    if Env.contains x env_term
    then raise (AlreadyInEnvironment (x, env_term))
    else (
      let n = Nominal.t_of_string x in
      let env_term' = Env.extend x n env_term in
      Grammar.TermLet(
        n,
        (nominal_term_of_raw_term_internal env_term env_typ t),
        (nominal_term_of_raw_term_internal env_term' env_typ u)
      )
    )

and nominal_typ_of_raw_typ_internal
    (env_term : Env.env)
    (env_typ : Env.env)
    (t : Grammar.raw_typ)
  = match t with
  | Grammar.TypeTop -> Grammar.TypeTop
  | Grammar.TypeBottom -> Grammar.TypeBottom
  | Grammar.TypeDeclaration (a, s, t) ->
    Grammar.TypeDeclaration (
      a,
      (nominal_typ_of_raw_typ_internal env_term env_typ s),
      (nominal_typ_of_raw_typ_internal env_term env_typ t)
    )
  | Grammar.TypeProjection (x, a) ->
    if Env.contains x env_term
    then (
      let n_x = Env.lookup x env_term in
      Grammar.TypeProjection(n_x, a)
    )
    else raise (NotInEnvironment(x, env_typ))
  | Grammar.TypeDependentFunction (x, s, t) ->
    if Env.contains x env_typ
    then raise (AlreadyInEnvironment (x, env_typ))
    else (
      let n_x = Nominal.t_of_string x in
      let env_term' = Env.extend x n_x env_term in
      Grammar.TypeDependentFunction(
        n_x,
        (nominal_typ_of_raw_typ_internal env_term env_typ s),
        (nominal_typ_of_raw_typ_internal env_term' env_typ t)
      )
    )

and nominal_term_of_raw_term t =
  nominal_term_of_raw_term_internal (Env.empty ()) (Env.empty ()) t

and nominal_typ_of_raw_typ t =
  nominal_typ_of_raw_typ_internal (Env.empty ()) (Env.empty ()) t

let rec raw_term_of_nominal_term t = match t with
  | Grammar.TermVariable x ->
    Grammar.TermVariable (Nominal.string_of_t x)
  | Grammar.TermTypeTag (a, typ) ->
    Grammar.TermTypeTag (
      a,
      raw_typ_of_nominal_typ typ
    )
  | Grammar.TermAbstraction (x, typ, t) ->
    Grammar.TermAbstraction (
      Nominal.string_of_t x,
      (raw_typ_of_nominal_typ typ),
      (raw_term_of_nominal_term t)
    )
  | Grammar.TermVarApplication (x, y) ->
    Grammar.TermVarApplication (
      Nominal.string_of_t x,
      Nominal.string_of_t y
    )
  | Grammar.TermLet (x, t, u) ->
    Grammar.TermLet (
      Nominal.string_of_t x,
      (raw_term_of_nominal_term t),
      (raw_term_of_nominal_term u)
    )

and raw_typ_of_nominal_typ t = match t with
  | Grammar.TypeTop -> Grammar.TypeTop
  | Grammar.TypeBottom -> Grammar.TypeBottom
  | Grammar.TypeDeclaration (a, s, t) ->
    Grammar.TypeDeclaration (
      a,
      (raw_typ_of_nominal_typ s),
      (raw_typ_of_nominal_typ t)
    )
  | Grammar.TypeProjection (x, a) ->
    Grammar.TypeProjection (
      Nominal.string_of_t x,
      a
    )
  | Grammar.TypeDependentFunction (x, s, t) ->
    Grammar.TypeDependentFunction(
      Nominal.string_of_t x,
      (raw_typ_of_nominal_typ s),
      (raw_typ_of_nominal_typ t)
    )
