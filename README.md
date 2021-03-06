DSubML is an implementation in OCaml of DSub, a ML like language with path dependent type, parametric and subtype polymorphism.

## Syntax of Dsub.

#### Terms

- Variables : `x`, `y`, `z` (string beginning with lowercase)
- Module containing a concrete type `{ A = int }`
- a function : `lambda(x : T) t`
- let binding : `let x = t in u`
- variable application : `x y`

#### Types

- forall : `forall(x : S) T`
- module containing an abstract type with lower and upper bound `{ A : S .. T }`.
- Top : `Any`
- Bottom : `Nothing`
- type projection (or a type selection in a module) : `x.A`

#### Syntactic sugar.

Some additional syntax is allowed to be close to OCaml syntax.

- `fun(x : T) t` = `lambda(x : T) t`
- `struct A = int end` = `{ A = int }`

- `forall(_ : S) T` = `S -> T`
- `sig A : S .. U end` = `{ A : S .. U }`
- `{ A :> S }` = `{ A : S .. Any }`
- `{ A <: T }` = `{ A : Nothing .. T }`
- `{ A }` = `{ A : Nothing .. Any }`
- ``{ A = int }` = `{A : int .. int }`

#### Additional

- `t : T`: ascription.
- `let x = t`: only allow at toplevel. Use to extend the environment.
- `let x : T = t` = `let x = t : T`
- `let x = t : T in u` = `let x : T = t in u`

## Examples

```OCaml
(* We define a module with a type which is a module type with a type between
   int.A -> string.A and Any (Top)
*)
let x = struct
  A = sig A :> int.A -> string.A end
end;;

let f = lambda (z : x.A) z;;

(* Try to apply to a function a module which is a subtype of the argument. *)
let y = struct A = int.A -> string.A end;;
f y;;

(* Must fail because g is of type Any because (f y) is between int.A -> string.A
   and Any and the upper bound is selected.
   NOTE: zero is a predefined value of type int.A.
*)
let g = f y;;
g zero;;

(* Try with a supertype of the lower bound of the argument. *)
let y = struct A = int.A -> Any end;;
f y;;

(* Must fail because g is of type Any because (f y) is between int.A -> Any
   and Any and the upper bound is selected.
*)
let g = f y;;
g zero;;

let x = struct
  A = sig A = sig A = int.A -> int.A end end
end;;

let y : x.A = struct A = sig A = int.A -> int.A end end;;

let z : y.A = struct A = int.A -> int.A end;;

let f : z.A = succ;;

f zero;;
```

## How to compile.
```
make
```

It produces an executable `main.native`.

## How to use?

The produced executable has two parameters: the **file** and the **action**.

**Actions** are algorithms you want to execute/test.
Possible actions are:
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

A verbose mode is available for some action to see the derivation tree. Use `--show-derivation-tree` to activate this mode.

## Syntax

### Evaluation

### Subtyping

### check_typing
