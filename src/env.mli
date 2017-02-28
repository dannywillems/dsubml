module Map : sig
  type t = Nominal.t

  type env

  val empty : unit -> env

  val contains : string -> env -> bool

  val lookup : string -> env -> t

  val extend : string -> t -> env -> env

  val print_env : env -> unit

  val fresh_name : string -> env -> string
end

module Set : sig
  type t = string

  type env

  val empty : unit -> env

  val add : t -> env -> env

  val contains : t -> env -> bool

  val fresh_name : string -> env -> string
end
