type t = Nominal.t

module StringMap = Map.Make(String)

type env = t StringMap.t

let empty () = StringMap.empty

let contains x env =
  StringMap.mem x env

let lookup x env =
  StringMap.find x env

let extend = StringMap.add

let rec fresh_name x env =
  if contains x env
  then fresh_name (x ^ "'") env
  else x

let print_env env =
  StringMap.iter
    (fun key value -> Printf.printf "%s : %s\n" key (Nominal.string_of_t value))
    env
