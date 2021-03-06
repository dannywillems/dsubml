open WellFormed

(* ------------------------------------------------- *)
(* About actions *)
exception Undefined_action of string

type action =
  | Check_typing
  | Eval
  | WellFormed
  | Subtype
  | Subtype_same_output
  | Subtype_with_REFL
  | Typing

let action_of_string = function
  | "check_typing" -> Check_typing
  | "eval" -> Eval
  | "subtype" -> Subtype
  | "subtype_with_REFL" -> Subtype_with_REFL
  | "subtype_same_output" -> Subtype_same_output
  | "typing" -> Typing
  | "wellFormed" -> WellFormed
  | s -> raise (Undefined_action s)
(* ------------------------------------------------- *)

(* ------------------------------------------------- *)
(* References for arguments *)
let file_name = ref ""
let eval_opt = ref ""
let show_derivation_tree = ref false
let verbose = ref false
let use_stdlib = ref false
(* ------------------------------------------------- *)

(* ------------------------------------------------- *)
(* Style using ANSITerminal *)
let error_style = [ANSITerminal.red]
let success_style = [ANSITerminal.green]
(* ------------------------------------------------- *)

(* ------------------------------------------------- *)
(* References used for environments *)
(* The environment to convert raw terms/types to nominal terms/types.
   Due to the design choice of the eval loop, we use a reference.
*)
let kit_import_env = ref AlphaLib.KitImport.empty

(* The environment for typing and subtyping algorithms.
   Due to the design choice of the eval loop, we use a reference.
*)
let typing_env = ref (ContextType.empty ())
(* ------------------------------------------------- *)

(* ------------------------------------------------- *)
(* Printing functions *)
let print_info string =
  if !verbose then (ANSITerminal.print_string [ANSITerminal.cyan] string)

(* Syntax error *)
let print_error lexbuf =
  let pos = lexbuf.Lexing.lex_curr_p in
  Printf.printf
    "Syntax error in %s - %d:%d\n"
    (!file_name)
    pos.Lexing.pos_lnum
    (pos.Lexing.pos_cnum - pos.Lexing.pos_bol + 1)

(* ------------------------------------------------- *)
(* Functions for actions *)
(** [print_is_subtyppe s t raw_is_subtype is_subtype] *)
let print_is_subtype s t raw_is_subtype is_subtype =
  ANSITerminal.printf
    (if raw_is_subtype = is_subtype then success_style else error_style)
    "%s - %s is%s a subtype of %s\n"
    (if raw_is_subtype = is_subtype then "✓" else "❌")
    (Print.string_of_raw_typ s)
    (if raw_is_subtype then "" else " not")
    (Print.string_of_raw_typ t);
  if raw_is_subtype <> is_subtype then exit(1)

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
  print_endline "-------------------------";
  if not same_type then exit(1)

let print_is_well_formed raw_is_well_formed is_well_formed raw_typ =
  let is_right = raw_is_well_formed = is_well_formed in
  let style = if is_right then success_style else error_style in
  let icon = if is_right then "✓" else "❌" in
  let string_of_raw_typ = Print.string_of_raw_typ raw_typ in
  ANSITerminal.printf
    style
    "%s %s\n  Algorithm output: %s\n  Attending output: %s\n"
    icon
    string_of_raw_typ
    (string_of_bool is_well_formed)
    (string_of_bool raw_is_well_formed);
  print_endline "-------------------------";
  if not is_right then exit(1)


let read_top_level_let x raw_term =
  (* Convert raw term/type to nominal term/type using the import environment. *)
  let nominal_term =
    Grammar.import_term
      (!kit_import_env)
      raw_term
  in
  (* Infer the type of t *)
  let history, type_of_t =
    Typer.type_of
      ~context:(!typing_env)
      nominal_term
  in
  if !show_derivation_tree
  then DerivationTree.print_typing_derivation_tree history;
  let extended_kit_import_env, atom_x =
    AlphaLib.KitImport.extend
      (!kit_import_env)
      x
  in
  kit_import_env := extended_kit_import_env;
  typing_env := ContextType.add atom_x type_of_t (!typing_env)

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
  | Error.Subtype(_) | Error.AvoidanceProblem(_) as e ->
    Error.print e;
    execute action lexbuf

let well_formed f =
  let raw_is_well_formed, top_level =
    Parser.top_level_well_formed Lexer.prog f
  in
  match top_level with
  | Grammar.Type raw_typ ->
    let nominal_typ = Grammar.import_typ (!kit_import_env) raw_typ in
    let is_well_formed = WellFormed.typ (!typing_env) nominal_typ in
    print_is_well_formed raw_is_well_formed is_well_formed raw_typ
  | Grammar.TopLevelLetType(x, raw_term) ->
    read_top_level_let x raw_term


(** Action to type check. *)
(** [check_typing lexbuf] reads the next top level expression from [lexbuf] *)
let check_typing f =
  let raw_term, raw_typ = Parser.top_level_check_typing Lexer.prog f in
  match raw_term with
  | Grammar.Term raw_term ->
    let nominal_term = Grammar.import_term (!kit_import_env) raw_term in
    let nominal_typ = Grammar.import_typ (!kit_import_env) raw_typ in
    let history, derived_typ =
      Typer.type_of ~context:(!typing_env) nominal_term in
    let same_type = Grammar.equiv_typ derived_typ nominal_typ in
    if !show_derivation_tree then DerivationTree.print_typing_derivation_tree history;
    print_derived_and_attended_types derived_typ nominal_typ nominal_term same_type
  | Grammar.TopLevelLetTerm(x, raw_term) ->
    read_top_level_let x raw_term

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
    if !show_derivation_tree
    then DerivationTree.print_typing_derivation_tree history;
    print_raw_term_with_nominal_typ raw_t type_of_t
    (* let x : T = t. Top level expressions. Can not appear in other expressions. *)
  | Grammar.TopLevelLetTerm(x, raw_term) ->
    read_top_level_let x raw_term


(** Action to check all algorithms for subtyping give the same results. *)
let check_subtype_algorithms f =
  let (raw_is_subtype, raw_couples) = Parser.top_level_subtype Lexer.prog f in
  match raw_couples with
  | Grammar.CoupleTypes(raw_s, raw_t) ->
    let nominal_s = Grammar.import_typ (!kit_import_env) raw_s in
    let nominal_t = Grammar.import_typ (!kit_import_env) raw_t in
    let history_with_refl, is_subtype_with_refl =
      Subtype.subtype ~with_refl:true ~context:(!typing_env) nominal_s nominal_t
    in
    let history_without_refl, is_subtype_without_refl =
      Subtype.subtype ~with_refl:false ~context:(!typing_env) nominal_s nominal_t
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
  | Grammar.TopLevelLetSubtype (var, raw_term) ->
    read_top_level_let var raw_term

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
  let (raw_is_subtype, raw_couple) = Parser.top_level_subtype Lexer.prog f in
  match raw_couple with
  | Grammar.CoupleTypes(raw_s, raw_t) ->
    let nominal_s = Grammar.import_typ (!kit_import_env) raw_s in
    let nominal_t = Grammar.import_typ (!kit_import_env) raw_t in
    (* TODO: check well formedness *)
    let history, is_subtype =
      Subtype.subtype ~with_refl ~context:(!typing_env) nominal_s nominal_t
    in
    if !show_derivation_tree then DerivationTree.print_subtyping_derivation_tree history;
    print_is_subtype raw_s raw_t raw_is_subtype is_subtype;
    print_endline "-------------------------"
  | Grammar.TopLevelLetSubtype (var, raw_term) ->
    read_top_level_let var raw_term
(* ------------------------------------------------- *)

(* ------------------------------------------------- *)
(* Args stuff *)
let actions = [
  "check_typing";
  "subtype";
  "subtype_same_output";
  "subtype_with_REFL";
  "typing";
  "wellFormed";
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
  ("--show-derivation-tree",
   Arg.Set show_derivation_tree,
   "Show derivation tree"
  );
  ("--use-stdlib",
   Arg.Set use_stdlib,
   "Use standard library."
  );
  ("-v",
   Arg.Set verbose,
   "Verbose mode"
  )
]

let () =
  Arg.parse args_list print_endline "An interpreter for DSub implemented in OCaml"
(* ------------------------------------------------- *)

let stdlib_files = [
  "stdlib/special.dsubml";
  "stdlib/unit.dsubml";
  "stdlib/condition.dsubml";
  "stdlib/int.dsubml";
  "stdlib/char.dsubml";
  "stdlib/string.dsubml";
]

let rec add_in_environment files = match files with
  | [] -> ()
  | head :: tail ->
    let channel = open_in head in
    let lexbuf = Lexing.from_channel channel in
    print_info (
      Printf.sprintf
        "  File: %s\n"
        head
    );
    execute typing lexbuf;
    close_in channel;
    add_in_environment tail

let () =
  let lexbuf = Lexing.from_channel (open_in (!file_name)) in
  if (!use_stdlib)
  then (
    print_info "Loading definitions from standard library.\n";
    add_in_environment stdlib_files;
    print_info "\nStandard library loaded.\n";
    print_info "-------------------------\n\n"
  );
  match (action_of_string (!eval_opt)) with
  | Check_typing -> execute check_typing lexbuf
  | WellFormed -> execute well_formed lexbuf
  | Eval -> execute eval lexbuf
  | Subtype -> execute (check_subtype ~with_refl:false) lexbuf
  | Subtype_same_output -> execute check_subtype_algorithms lexbuf
  | Subtype_with_REFL -> execute (check_subtype ~with_refl:true) lexbuf
  | Typing -> execute typing lexbuf
