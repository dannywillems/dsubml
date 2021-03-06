TODO
====

## Basic types and functions:

- [x] Integer.
- [ ] Boolean.
- [ ] test (`if .. then .. else ..`)

## Grammar.

- [x] Add `let x : T = t` to define top-level definition. It is used to extend
  the environment.
  - [x] Add a `magic` term of type `Nothing` to define a term which has no
    implementation (like `()` for `unit`). With this term, we can say a term
    exist without defining the meaning.
- [x] Add `(term : Type)` with the typing rule: `Γ ⊦ t : T => Γ ⊦ (t : T) : T`
- [x] Add `let x = t`.

- [x] Reorganize the grammar because it's very ugly! `let x : T = t` is
  equivalent to `let x = (t : T)`.
- [x] Type label can be any string beginning with a capital letter. It implies to remove all check about labels.

## Subtyping.

- [x] Check all results.
- [x] Automatic verification for tests.
- [x] Add an history to get the derivation tree.
- [x] Use `SUB` in select rules.
- [x] Add an action to check if each algorithm outputs the same result.
  representation of a variable when an error occurs and is raised.
- [x] Trick when `SEL <:` and `<: SEL` can be both used.
- [x] Add `let x = t`.
- [x] Clean code.
- [x] Define function to create nodes.
- [x] Use defined function to create nodes in the algorithm.

#### Not important.

- [ ] Return all possible derivation trees.
- [ ] Take an extend environment (`Atom -> String`) to recover the initial

## Typing.

- [x] In `let x = s in t`, check that the variable doesn't appear in the type of
  `t`. This is the avoidance problem.
  representation of a variable when an error occurs and is raised.
- [x] Add `let x = t`.
- [ ] `tuple_of_dependent_function`: call to `best_bounds` and check if it's an
  arrow. If it's `Nothing`, we need to return `Top -> Nothing` because it's the
  least upper bound which is an arrow.
- [ ] Prove `best_bounds` is correct.
- [x] check well formedness.
- [x] Clean code.
- [x] Define function to create nodes.
- [x] Use defined function to create nodes in the algorithm.

#### Not important.

- [ ] Improve error message in var application when we have `x.A` (for the moment, we only have `x.A`, not what is `x.A`). Example
- [ ] Take an extend environment (`Atom -> String`) to recover the initial

## Evaluation.

#### Not important.

- [ ] Add a syntax to check typing at runtime like 
```
[@check_typing type]
```

## MISC

- [x] Add a function `well_formed : env -> Grammar.nominal_typ -> bool`
  returning `true` if the given nominal type is well formed. We say a type `T` is
  not well formed if `T` is the form `x.A` and `x` is not a variable of type `{ A :
  Nothing .. Any }`.
- [x] Be able to extend the environment with the syntax `let x : T = t`.
- [x] Use a default environment (like `Pervasives` in OCaml) while reading a file.

#### Not important.

- [ ] Emacs mode.

## Surface language.

- [x] Add a sugar for dependent function when the variable is not
  needed in the return type.
- [x] `S : Nothing .. Any` (no need to mention bounds) -> `S`
- [x] `S : Nothing .. U` -> `S <: U`
- [x] `S : L .. Any` -> `S :> L`
- [x] `struct .. end` and `obj .. end`) to define module structure and
- [x] `sig .. end` to define module type.
- [x] `{ S : int .. int }` -> `{ S = int }`
