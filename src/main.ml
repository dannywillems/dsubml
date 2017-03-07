open Eval

(* ------------------------------------------------- *)
(* About actions *)
exception Undefined_action of string

type action =
  | Read_term
  | Read_type
  | Eval
  | Subtype
  | Typing

let action_of_string = function
  | "read_term" -> Read_term
  | "read_type" -> Read_type
  | "eval" -> Eval
  | "subtype" -> Subtype
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
let print_is_subtype s t raw_is_subtype is_subtype =
  ANSITerminal.printf
    (if raw_is_subtype = is_subtype then success_style else error_style)
    "%s - %s is%s a subtype of %s\n"
    (if raw_is_subtype = is_subtype then "✓" else "❌")
    (Print.string_of_raw_typ s)
    (if raw_is_subtype then "" else " not")
    (Print.string_of_raw_typ t)

let rec execute action lexbuf =
  try
    action lexbuf;
    execute action lexbuf
  with
  | End_of_file -> ()
  | Parser.Error ->
    print_error lexbuf;
    exit 1

let typing f =
  let raw_t = Parser.top_level Lexer.prog f in
  let nominal_t = Grammar.import_term AlphaLib.KitImport.empty raw_t in
  let history, type_of_t = Typer.type_of nominal_t in
  if !verbose then DerivationTree.print_typing_derivation_tree history;
  ANSITerminal.print_string
    [ANSITerminal.cyan]
    (Print.string_of_raw_term raw_t);
  print_string " : ";
  ANSITerminal.printf
    [ANSITerminal.blue]
    "%s\n"
    (Print.string_of_raw_typ (Grammar.show_typ type_of_t));
  print_endline "-------------------------"

let eval f =
  ()

let check_subtype f =
  let (raw_is_subtype, raw_s, raw_t) = Parser.top_level_subtype Lexer.prog f in
  let nominal_s = Grammar.import_typ AlphaLib.KitImport.empty raw_s in
  let nominal_t = Grammar.import_typ AlphaLib.KitImport.empty raw_t in
  let history, is_subtype = Subtype.subtype nominal_s nominal_t in
  if !verbose then DerivationTree.print_subtyping_derivation_tree history;
  print_is_subtype raw_s raw_t raw_is_subtype is_subtype;
  print_endline "-------------------------"

let read_term_file f =
  let raw_term = Parser.top_level Lexer.prog f in
  let nominal_term = Grammar.import_term AlphaLib.KitImport.empty raw_term in
  print_endline "Raw term";
  Print.Style.raw_term [ANSITerminal.cyan] raw_term;
  print_endline "\nPrint nominal_term";
  Print.Style.raw_term [ANSITerminal.blue] (Grammar.show_term nominal_term);
  print_endline "\n-------------------------"

let read_type_file f =
  let raw_typ = Parser.top_level_type Lexer.prog f in
  let nominal_typ = Grammar.import_typ AlphaLib.KitImport.empty raw_typ in
  print_endline "Raw typ";
  Print.Style.raw_typ [ANSITerminal.cyan] raw_typ;
  print_endline "\nPrint nominal_typ";
  Print.Style.raw_typ [ANSITerminal.blue] (Grammar.show_typ nominal_typ);
  print_endline "\n-------------------------"
(* ------------------------------------------------- *)

(* ------------------------------------------------- *)
(* Args stuff *)
let args_list = [
  ("-f",
   Arg.Set_string file_name,
   "File to read"
  );
  ("-a",
   Arg.Symbol (["read_term" ; "read_type" ; "subtype" ; "typing"], (fun s -> eval_opt := s)),
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
  | Read_term -> execute read_term_file lexbuf
  | Read_type -> execute read_type_file lexbuf
  | Eval -> execute eval lexbuf
  | Subtype -> execute check_subtype lexbuf
  | Typing -> execute typing lexbuf
