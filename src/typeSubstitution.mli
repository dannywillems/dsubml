(** NOT USED ANYMORE.
    Not removed if we need it.
    This modules must never be used because the syntax of DSub is not stable by
    substitution (but renaming is OK).
*)

exception TypeError of string

(**
   [substitute x S T] substitutes the variable x by the type S in the type T.
   A {!TypeError} exception is raised if a type projection substitution is done
   but the variable [x] and the variable in the type projection has not the same
   label (which can't be the case in DSub, it's just to scale easily to DOT)
*)
val substitute :
  AlphaLib.Atom.t ->
  Grammar.nominal_typ ->
  Grammar.nominal_typ ->
  Grammar.nominal_typ
