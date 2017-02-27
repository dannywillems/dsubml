type t = Nominal.t

type env

val empty : unit -> env

val contains : string -> env -> bool

val lookup : string -> env -> t

val extend : string -> t -> env -> env

val print_env : env -> unit
