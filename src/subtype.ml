let subtype_internal context s t = match (s, t) with
  | (_, Grammar.TypeTop) -> true
  | (Grammar.TypeBottom, _) -> true
  | (s, t) when (Grammar.equiv_typ s t) -> true
  | (_, _) -> false

let subtype s t =
  subtype_internal (ContextType.empty ()) s t
