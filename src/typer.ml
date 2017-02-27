let subtype s t = match (s, t) with
  | (_, Grammar.TypeTop) -> true
  | (Grammar.TypeBottom, _) -> true
