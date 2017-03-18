{
  (* The position in the buffer is set to the next line *)
  let next_line lexbuf =
    let pos = lexbuf.Lexing.lex_curr_p in
    lexbuf.Lexing.lex_curr_p <-
      {
        pos with Lexing.pos_bol = lexbuf.Lexing.lex_curr_pos;
                 Lexing.pos_lnum = pos.Lexing.pos_lnum + 1
      }

  let print_error lexbuf =
    let pos = lexbuf.Lexing.lex_curr_p in
    Printf.printf
      "Syntax error - %d:%d\n"
      pos.Lexing.pos_lnum
      (pos.Lexing.pos_cnum - pos.Lexing.pos_bol + 1)


}

let abstraction = "lambda"
let forall = "forall"
let top = "Any"
let bottom = "Nothing"
let let_ = "let"
let in_ = "in"
let unimplemented_term = "Unimplemented"

let white = [' ' '\t' '\r']
let newline = ['\n']

(** TODO: We can split in several rules for the syntax used in subtyping verification
    and typing verification
*)
rule prog = parse
  | white { prog lexbuf }
  | newline { next_line lexbuf;
              prog lexbuf
            }
  | "(*" {
      comment lexbuf;
      prog lexbuf
    }

  (* Only to test subtyping algorithm. It's not in the language *)
  | "<:" { Parser.SUBTYPE }
  | "!<:" { Parser.NOT_SUBTYPE }
  | "!" { Parser.EXCLAMATION }
  (* Syntastic sugar for functions where the variable is not present in the
     return type.
  *)
  | "->" { Parser.ARROW }
  | unimplemented_term { Parser.UNIMPLEMENTED_TERM }

  | ':' { Parser.COLON}
  | '.' { Parser.DOT }
  | '=' { Parser.EQUAL }
  | '{' { Parser.LEFT_BRACKET }
  | '}' { Parser.RIGHT_BRACKET }
  | '(' { Parser.LEFT_PARENT }
  | ')' { Parser.RIGHT_PARENT }
  | ';' { Parser.SEMICOLON }
  | top { Parser.TOP_TYPE }
  | bottom { Parser.BOTTOM_TYPE }
  | "for all" { Parser.FORALL }
  | let_ { Parser.LET }
  | in_ { Parser.IN }
  | abstraction { Parser.ABSTRACTION }
  | ['A' - 'Z']+ ['a' - 'z' '_' '\'' '0' - '9']* as l { Parser.LABEL l }
  | ['a' - 'z']+ ['a' - 'z' '_' '\'' '0' - '9']* as id { Parser.VAR id }
  | _ { print_error lexbuf; failwith "Illegal character" }
  | eof { Parser.EOF }

and comment = parse
  | "*)" { () }
  | eof { print_error lexbuf; failwith "Unterminated comment" }
  | _ { comment lexbuf }
