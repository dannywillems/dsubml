let rec eval_file f =
  try
    let term = Parser.top_level Lexer.prog f in
    let n_term = GrammarConverter.nominal_term_of_raw_term term in
    print_endline "Raw term";
    Print.raw_term term;
    print_endline "\nPrint nominal_term";
    Print.nominal_term n_term;
    print_endline "";
    eval_file f
  with End_of_file -> ()

let () =
  let argc = Array.length Sys.argv in
  if argc > 1
  then
    let f = open_in (Array.get Sys.argv 1) in
    eval_file (Lexing.from_channel f);
    close_in f
  else
    print_endline "You must give a file"

