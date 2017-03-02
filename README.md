DSUBML is an implementation in OCaml of DSUB.

To compile, use
```
make
```

It produces an executable `main.native`.
This executable has two parameters: the file and the action.

Possible actions are:
- evaluate a list of terms (`eval`).
- use the subtyping algorithm on types (`subtype`).

For example, you can try the subtyping algorithm on the file `test/subtype_simple.dsubml` by using:
```
./main.native -f test/subtype_simple.dsubml -a subtype
```


TODO
====

## Grammar.

- Add integer, string, char, bool.

## Subtyping.

- Check all results are correct.
- Add an history to get the derivation tree.
