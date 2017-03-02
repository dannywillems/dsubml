{
  let next_line lexbuf =
    let pos = lexbuf.Lexing.lex_curr_p in
    lexbuf.Lexing.lex_curr_p <-
      {
        pos with Lexing.pos_bol = lexbuf.Lexing.lex_curr_pos;
                 Lexing.pos_lnum = pos.Lexing.pos_lnum + 1
      }
}

let abstraction = "lambda"
let forall = "forall"
let top = "Any"
let bottom = "Nothing"
let let_ = "let"
let in_ = "in"

let white = [' ' '\t' '\r']
let newline = ['\n']

rule prog = parse
  | white { prog lexbuf }
  | newline { next_line lexbuf;
              prog lexbuf
            }
  | ':' { Parser.COLON}
  | '.' { Parser.DOT }
  | '=' { Parser.EQUAL }
  | '{' { Parser.LEFT_BRACKET }
  | '}' { Parser.RIGHT_BRACKET }
  | '(' { Parser.LEFT_PARENT }
  | ')' { Parser.RIGHT_PARENT }
  | top { Parser.TOP_TYPE }
  | bottom { Parser.BOTTOM_TYPE }
  | ['A' - 'Z']+ as l { Parser.LABEL l }
  | ';' { Parser.SEMICOLON }
  | let_ { Parser.LET }
  | in_ { Parser.IN }
  | abstraction { Parser.ABSTRACTION }
  | ['a' - 'z']+ as id { Parser.VAR id }
  | forall { Parser.FORALL }
  | _ { failwith "Illegal character" }
  | eof { Parser.EOF }
