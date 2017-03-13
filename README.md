DSubML is an implementation in OCaml of DSub.

To compile, use
```
make
```

It produces an executable `main.native`.
This executable has two parameters: the file and the action.

Possible actions are:
- read a file containing a list of terms, print the red raw term and the corresponding nominal term (`read_term`).
- read a file containing a list of types, print the red raw type and the corresponding nominal type (`read_type`).
- evaluate a list of terms (`eval`).
- use the typing algorithm on terms (`typing`).
- use the subtyping algorithm on types (`subtype`).
- use the subtyping algorithm on types without REFL rules (`subtype_without_REFL`).
- check if each subtyping algorithm outputs the same result
  (`subtype_same_output`).
- type a term and print the type (`typing`)
- check if a term is well typed with the typing algorithm (`check_typing`).

For example, you can try the subtyping algorithm on the file `test/subtype_simple.dsubml` by using:
```
./main.native -f test/subtype_simple.dsubml -a subtype
```

A verbose is available for some action to see the derivation tree. Use `-v` to
activate this mode.

## Syntax

### Evaluation

### Subtyping

### check_typing


TODO
====

## Grammar.

- [ ] Add integer, string, char, bool.
- [ ] Surface language.
- [x] Add (term : Type) with the typing rule: Γ ⊦ t : T => Γ ⊦ (t : T) : T

## Subtyping.

- [x] Check all results.
- [x] Automatic verification for tests.
- [x] Add an history to get the derivation tree.
- [ ] Use SUB in select rules.
- [x] Add an action to check if each algorithm outputs the same result.

## Typing.

- [ ] Dans let, vérifier que la variable n'apparait pas dans le type final -->
methode occurs. Avoidance problem.
