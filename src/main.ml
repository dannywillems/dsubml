open Typer
(* ------------------------------------------------- *)
(* About actions *)
exception Undefined_action of string

type action =
  | Eval
  | Subtype
  | Typing

let action_of_string = function
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
let print_is_subtype s t is_subtype =
  ANSITerminal.printf
    (if is_subtype then success_style else error_style)
    "%s - %s is%s a subtype of %s\n"
    (if is_subtype then "✓" else "❌")
    (Print.string_of_raw_typ s)
    (if is_subtype then "" else " not")
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

let rec typing f =
  let raw_t = Parser.top_level Lexer.prog f in
  let nominal_t = Grammar.import_term AlphaLib.KitImport.empty raw_t in
  let type_of_t = Typer.type_of nominal_t in
  Print.raw_typ (Grammar.show_typ type_of_t);
  print_endline ""

let rec check_subtype f =
  let (raw_s, raw_t) = Parser.top_level_subtype Lexer.prog f in
  let nominal_s = Grammar.import_typ AlphaLib.KitImport.empty raw_s in
  let nominal_t = Grammar.import_typ AlphaLib.KitImport.empty raw_t in
  let history, is_subtype = Subtype.subtype nominal_s nominal_t in
  if !verbose then print_string (DerivationTree.to_string 0 history);
  print_is_subtype raw_s raw_t is_subtype;
  print_endline "-------------------------"

let rec eval_file f =
  let raw_term = Parser.top_level Lexer.prog f in
  let nominal_term = Grammar.import_term AlphaLib.KitImport.empty raw_term in
  print_endline "Raw term";
  Print.raw_term raw_term;
  print_endline "\nPrint nominal_term";
  Print.raw_term @@ Grammar.show_term nominal_term;
  print_endline ""
(* ------------------------------------------------- *)

(* ------------------------------------------------- *)
(* Args stuff *)
let args_list = [
  ("-f",
   Arg.Set_string file_name,
   "File to read"
  );
  ("-a",
   Arg.Symbol (["eval" ; "subtype" ; "typing"], (fun s -> eval_opt := s)),
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
  | Eval -> execute eval_file lexbuf
  | Subtype -> execute check_subtype lexbuf
  | Typing -> execute typing lexbuf
