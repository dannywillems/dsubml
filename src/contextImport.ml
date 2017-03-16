(* Module alias for readibility *)
module TermVariable = AlphaLib.Atom

(* A ContextModule is defined as a map of atom to things (defined below) *)
type atom = AlphaLib.Atom.t

module ContextModule = Map.Make(TermVariable)

(* An atom is mapped to its type, the term it references and the location of its
   definition.
   This type can be extended later with more information.
*)
type env = {
  typ : ContextType.env;
  term : Grammar.nominal_term ContextModule.t;
  (* Must be change later with the line and column location in the files. Maybe
     the derivation tree, etc
  *)
  definition_location : string ContextModule.t;
}

let typ_of_atom atom context =
  ContextModule.find atom context.typ

let term_of_atom atom context =
  ContextModule.find atom context.term

let definition_location_of_atom context =
  ContextModule.find atom context.definition_location

let type_of_atoms context =
  context.typ

let term_of_atoms context =
  context.term

let definition_location_of_atoms context =
  context.definition_location

let information_of_atom atom context =
  let typ =
    typ_of_atom atom context
  in
  let term =
    term_of_atom atom context
  in
  let definition_location =
    definition_location_of_atom atom context
  in
  (typ, term, definition_location)

(* Usual functions about contexts *)
let empty () = {
  typ = ContextType.empty ();
  term = ContextModule.empty;
  definition_location = ContextModule.empty;
}

let add x typ term definition_location context = {
  typ = ContextModule.add x typ context.typ;
  term = ContextModule.add x term context.term;
  definiation_location =
    ContextModule.add x definition_location context.definitaion_location
}

let is_empty context =
  ContextModule.is_empty context
