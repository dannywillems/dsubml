(* ------------------------------------------------- *)
(* About actions *)
exception Undefined_action of string

type action =
  | Check_typing
  | Read_term
  | Read_type
  | Eval
  | Subtype
  | Subtype_same_output
  | Subtype_with_REFL
  | Typing

let action_of_string = function
  | "check_typing" -> Check_typing
  | "read_term" -> Read_term
  | "read_type" -> Read_type
  | "eval" -> Eval
  | "subtype" -> Subtype
  | "subtype_with_REFL" -> Subtype_with_REFL
  | "subtype_same_output" -> Subtype_same_output
  | "typing" -> Typing
  | s -> raise (Undefined_action s)
(* ------------------------------------------------- *)

(* ------------------------------------------------- *)
(* References for arguments *)
let file_name = ref ""
let eval_opt = ref ""
let verbose = ref false
(* ------------------------------------------------- *)

(* ------------------------------------------------- *)
(* Style using ANSITerminal *)
let error_style = [ANSITerminal.red]
let success_style = [ANSITerminal.green]
(* ------------------------------------------------- *)

(* ------------------------------------------------- *)
(* Syntax error management *)
let print_error lexbuf =
  let pos = lexbuf.Lexing.lex_curr_p in
  Printf.printf
    "Syntax error in %s - %d:%d\n"
    (!file_name)
    pos.Lexing.pos_lnum
    (pos.Lexing.pos_cnum - pos.Lexing.pos_bol + 1)

(* ------------------------------------------------- *)

(* ------------------------------------------------- *)
(* Functions for actions *)

(* The environment to convert raw terms/types to nominal terms/types.
   Due to the design choice of the eval loop, we use a reference.
*)
let kit_import_env = ref AlphaLib.KitImport.empty

(* The environment for typing and subtyping algorithms.
   Due to the design choice of the eval loop, we use a reference.
*)
let typing_env = ref (ContextType.empty ())

(* ---- Some printing functions ---- *)
(** [print_is_subtyppe s t raw_is_subtype is_subtype] *)
let print_is_subtype s t raw_is_subtype is_subtype =
  ANSITerminal.printf
    (if raw_is_subtype = is_subtype then success_style else error_style)
    "%s - %s is%s a subtype of %s\n"
    (if raw_is_subtype = is_subtype then "✓" else "❌")
    (Print.string_of_raw_typ s)
    (if raw_is_subtype then "" else " not")
    (Print.string_of_raw_typ t)

let print_raw_term_with_nominal_typ raw_term nominal_typ =
  ANSITerminal.print_string
    [ANSITerminal.cyan]
    (Print.string_of_raw_term raw_term);
  print_string " : ";
  ANSITerminal.printf
    [ANSITerminal.blue]
    "%s\n"
    (Print.string_of_nominal_typ nominal_typ);
  print_endline "-------------------------"

let print_derived_and_attended_types
    derived_typ
    attended_typ
    nominal_term
    same_type
  =
  ANSITerminal.printf
    (if same_type then success_style else error_style)
    "%s %s\n"
    (if same_type then "✓" else "❌")
    (Print.string_of_nominal_term nominal_term);
  ANSITerminal.printf
    [ANSITerminal.cyan]
    "  Derived type: %s\n  Attending type: %s\n"
    (Print.string_of_nominal_typ derived_typ)
    (Print.string_of_nominal_typ attended_typ);
  print_endline "-------------------------"


(* The main loop to execute actions. *)
let rec execute action lexbuf =
  try
    action lexbuf;
    execute action lexbuf
  with
  | End_of_file -> ()
  | Parser.Error ->
    print_error lexbuf;
    exit 1

(** Action to type check. *)
(** [check_typing lexbuf] reads the next top level expression from [lexbuf] *)
let check_typing f =
  let raw_term, raw_typ = Parser.top_level_check_typing Lexer.prog f in
  let nominal_term = Grammar.import_term AlphaLib.KitImport.empty raw_term in
  let nominal_typ = Grammar.import_typ AlphaLib.KitImport.empty raw_typ in
  let history, derived_typ = Typer.type_of nominal_term in
  let same_type = Grammar.equiv_typ derived_typ nominal_typ in
  if !verbose then DerivationTree.print_typing_derivation_tree history;
  print_derived_and_attended_types derived_typ nominal_typ nominal_term same_type

(** Action to call the typechecker *)
let typing f =
  match Parser.top_level Lexer.prog f with
  | Grammar.Term raw_t ->
    let nominal_t =
      Grammar.import_term
        (!kit_import_env)
        raw_t
    in
    let history, type_of_t =
      Typer.type_of
        ~context:(!typing_env)
        nominal_t
    in
    if !verbose
    then DerivationTree.print_typing_derivation_tree history;
    print_raw_term_with_nominal_typ raw_t type_of_t
    (* let x = t. Top level expressions. Can not appear in other expressions. *)
  | Grammar.TopLevelLet (x, raw_typ, raw_t) ->
    (* Convert raw term/type to nominal term/type using the import environment. *)
    let nominal_t =
      Grammar.import_term
        (!kit_import_env)
        raw_t
    in
    let nominal_typ =
      Grammar.import_typ
        (!kit_import_env)
        raw_typ
    in
    (* Infer the type of t *)
    let history, type_of_t =
      Typer.type_of
        ~context:(!typing_env)
        nominal_t
    in
    let extended_kit_import_env, atom_x =
      AlphaLib.KitImport.extend
        (!kit_import_env)
        x
    in
    (* The inferred type must be a subtype of the wanted type. *)
    if Subtype.is_subtype type_of_t nominal_typ
    then (
      (* If verbose is activated, we print the typing derivation tree *)
      if !verbose
      then DerivationTree.print_typing_derivation_tree history;
      Printf.printf "(Top level let definition)\n";
      print_raw_term_with_nominal_typ raw_t type_of_t;
      kit_import_env := extended_kit_import_env;
      typing_env := ContextType.add atom_x nominal_typ (!typing_env)
    )
    else
      raise (
        Error.SubtypeError (
          (Printf.sprintf
             "%s is not a subtype of %s"
             (Print.string_of_nominal_typ type_of_t)
             (Print.string_of_raw_typ raw_typ)
          ),
          type_of_t,
          nominal_typ
        )
      )

(** Action to check all algorithms for subtyping give the same results. *)
let check_subtype_algorithms f =
  let (raw_is_subtype, raw_s, raw_t) = Parser.top_level_subtype Lexer.prog f in
  let nominal_s = Grammar.import_typ AlphaLib.KitImport.empty raw_s in
  let nominal_t = Grammar.import_typ AlphaLib.KitImport.empty raw_t in
  let history_with_refl, is_subtype_with_refl =
    Subtype.subtype ~with_refl:true nominal_s nominal_t
  in
  let history_without_refl, is_subtype_without_refl =
    Subtype.subtype ~with_refl:false nominal_s nominal_t
  in
  Printf.printf
    "%s <: %s\n"
    (Print.string_of_raw_typ raw_s)
    (Print.string_of_raw_typ raw_t);
  ANSITerminal.printf
    (if is_subtype_without_refl = raw_is_subtype then success_style else error_style)
    "    %s %s\n"
    (if is_subtype_without_refl = raw_is_subtype then "✓" else "❌")
    "Without REFL";
  ANSITerminal.printf
    (if is_subtype_with_refl = raw_is_subtype then success_style else error_style)
    "    %s %s\n"
    (if is_subtype_with_refl = raw_is_subtype then "✓" else "❌")
    "With REFL";
  print_endline "-------------------------"

(** Action to evaluate a file.
    NOTE: We can erase the types because we don't need it when evaluating.
*)
let eval f =
  ()

(** Action to check the subtype algorithm (with or without REFL). It uses the
    syntax S <: T or S !<: T and automatically check if the answer is the same than
    we want.
*)
let check_subtype ~with_refl f =
  let (raw_is_subtype, raw_s, raw_t) = Parser.top_level_subtype Lexer.prog f in
  let nominal_s = Grammar.import_typ AlphaLib.KitImport.empty raw_s in
  let nominal_t = Grammar.import_typ AlphaLib.KitImport.empty raw_t in
  let history, is_subtype = Subtype.subtype ~with_refl nominal_s nominal_t in
  if !verbose then DerivationTree.print_subtyping_derivation_tree history;
  print_is_subtype raw_s raw_t raw_is_subtype is_subtype;
  print_endline "-------------------------"

(** Action to read a file with list of terms. *)
let read_term_file f =
  match Parser.top_level Lexer.prog f with
  | Grammar.Term raw_term ->
    let nominal_term = Grammar.import_term (!kit_import_env) raw_term in
    print_endline "Raw term";
    Print.Style.raw_term [ANSITerminal.cyan] raw_term;
    print_endline "\nPrint nominal_term";
    Print.Style.nominal_term [ANSITerminal.blue] nominal_term;
    print_endline "\n-------------------------"
  | Grammar.TopLevelLet (x, typ, term) -> () (* TODO *)

(** Action to read a file with list of types. *)
let read_type_file f =
  let raw_typ = Parser.top_level_type Lexer.prog f in
  let nominal_typ = Grammar.import_typ AlphaLib.KitImport.empty raw_typ in
  print_endline "Raw typ";
  Print.Style.raw_typ [ANSITerminal.cyan] raw_typ;
  print_endline "\nPrint nominal_typ";
  Print.Style.nominal_typ [ANSITerminal.blue] nominal_typ;
  print_endline "\n-------------------------"
(* ------------------------------------------------- *)

(* ------------------------------------------------- *)
(* Args stuff *)
let actions = [
  "check_typing";
  "read_term";
  "read_type";
  "subtype";
  "subtype_same_output";
  "subtype_with_REFL";
  "typing";
]

let args_list = [
  ("-f",
   Arg.Set_string file_name,
   "File to read"
  );
  ("-a",
   Arg.Symbol (actions, (fun s -> eval_opt := s)),
   "The action to do"
  );
  ("-v",
   Arg.Set verbose,
   "Verbose mode"
  )
]

let () =
  Arg.parse args_list print_endline "An interpreter for DSub implemented in OCaml"
(* ------------------------------------------------- *)

let () =
  let lexbuf = Lexing.from_channel (open_in (!file_name)) in
  match (action_of_string (!eval_opt)) with
  | Check_typing -> execute check_typing lexbuf
  | Read_term -> execute read_term_file lexbuf
  | Read_type -> execute read_type_file lexbuf
  | Eval -> execute eval lexbuf
  | Subtype -> execute (check_subtype ~with_refl:false) lexbuf
  | Subtype_same_output -> execute check_subtype_algorithms lexbuf
  | Subtype_with_REFL -> execute (check_subtype ~with_refl:true) lexbuf
  | Typing -> execute typing lexbuf
