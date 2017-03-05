val string_of_raw_term : Grammar.raw_term -> string

val string_of_raw_typ : Grammar.raw_typ -> string

val raw_term : Grammar.raw_term -> unit

val raw_typ : Grammar.raw_typ -> unit

module Style : sig
  val string_of_raw_term : ANSITerminal.style list -> Grammar.raw_term -> string

  val string_of_raw_typ : ANSITerminal.style list -> Grammar.raw_typ -> string

  val raw_term : ANSITerminal.style list -> Grammar.raw_term -> unit

  val raw_typ : ANSITerminal.style list -> Grammar.raw_typ -> unit
end
