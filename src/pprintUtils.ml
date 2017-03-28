open PPrint

let lambda = string "λ"

let forall = string "∀"

let colon = string ":"

let indentation = 2

let block opening content closing =
  group (opening ^^ nest indentation (contents) ^^ closing)

let binding x t =
  block (x ^^ colon) (space ^^ t) empty

let parens d =
  block
    lparen
    (break 0 ^^ d)
    (break 0 ^^ rparen)

let nothing = string "Nothing"

let any = string "Any"

