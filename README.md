DSubML is an implementation in OCaml of DSub.

To compile, use
```
make
```

It produces an executable `main.native`.

## How to use?

The produced executable has two parameters: the **file** and the **action**.

**Actions** are algorithms you want to execute/test.
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

A verbose mode is available for some action to see the derivation tree. Use `-v`
to activate this mode.

## Syntax

### Evaluation

### Subtyping

### check_typing


TODO
====

## Basic types and functions:

- [ ] Integer.
- [ ] Boolean.
- [ ] test (if .. then .. else ..)

## Grammar.

- [x] Add `let x : T = t` to define top-level definition. It is used to extend
  the environment.
  - [x] Add a `magic` term of type `Nothing` to define a term which has no
    implementation (like `()` for `unit`). With this term, we can say a term
    exist without defining the meaning.
- [ ] Surface language.
- [x] Add (term : Type) with the typing rule: Γ ⊦ t : T => Γ ⊦ (t : T) : T

## Subtyping.

- [x] Check all results.
- [x] Automatic verification for tests.
- [x] Add an history to get the derivation tree.
- [ ] Use SUB in select rules.
- [x] Add an action to check if each algorithm outputs the same result.
- [ ] Take an extend environment (Atom ->
  String) to recover the initial representation of a variable when an error
  occurs and is raised.


## Typing.

- [ ] In `let x = s in t`, check that the variable doesn't appear in the type of
  `t`. This is the avoidance problem.
- [ ] Improve error message in var application when we have x.A (for the moment, we only have x.A, not what is x.A). Example
- [ ] Take an extend environment (Atom -> String) to recover the initial
  representation of a variable when an error occurs and is raised.

```
let x = { A = Nothing } in
let y = { A = Any } in
let f = lambda(y : x.A) y in
(f y);;
```

## MISC

- [ ] Add a function `well_formed : env -> Grammar.nominal_typ -> bool`
  returning `true` if the given nominal type is well formed. We say a type T is
  not well formed if T is the form x.A and x is not a variable of type { A :
  Nothing .. Any }.
- [x] Be able to extend the environment with the syntax `let x : T = t`.
- [ ] Use a default environment (like `Pervasives` in OCaml) while reading a files.
- [ ] Emacs mode.
- [ ] Add a syntastic sugar for dependent function when the variable is not needed in the return type.
