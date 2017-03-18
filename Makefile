TARGET := \
  main.native

PWD := \
  $(shell pwd)

ALPHALIB := \
  `ocamlfind query alphaLib`

SRC_DIR = src

OCAMLBUILD := \
  ocamlbuild \
  -use-ocamlfind \
  -classic-display \
  -plugin-tag 'package(cppo_ocamlbuild)' \
  -tag "cppo_I($(ALPHALIB))" \
  -tag "cppo_I($(PWD))"

# Replace all files ending with .cppo.ml by .inferred.mli which is the
# extension of generated interfaces by ocamlbuild.
MLI := \
  $(patsubst %.cppo.ml,%.inferred.mli,$(shell ls $(SRC_DIR)/*.cppo.ml)) \


.PHONY: all test clean

all:
	@ $(OCAMLBUILD) $(SRC_DIR)/$(TARGET)

test_subtype:
	@ echo "----- Subtyping Algorithms -----"
	@ echo "Predefined types: without REFL."
	@ ./$(TARGET) -f test/subtype/predefined_types.dsubml \
                -a subtype \
                --use-stdlib
	@ echo "\n---------------------------------------\n"
	@ echo "Predefined types: with REFL."
	@ ./$(TARGET) -f test/subtype/predefined_types.dsubml \
                -a subtype_with_REFL \
                --use-stdlib
	@ echo "\n---------------------------------------\n"
	@ echo "Predefined types: same output"
	@ ./$(TARGET) -f test/subtype/predefined_types.dsubml \
                -a subtype_same_output \
                --use-stdlib
	@ echo "\n---------------------------------------\n"
	@ echo "Simple tests: without REFL"
	@ ./$(TARGET) -f test/subtype/simple.dsubml \
                -a subtype
	@ echo "\n---------------------------------------\n"
	@ echo "Simple tests: with REFL"
	@ ./$(TARGET) -f test/subtype/simple.dsubml \
                -a subtype_with_REFL
	@ echo "\n---------------------------------------\n"
	@ echo "Simple tests: same output"
	@ ./$(TARGET) -f test/subtype/simple.dsubml \
                -a subtype_same_output
	@ echo "\n---------------------------------------\n"

test_typing:
	@ echo "----- Typing Algorithm -----"
	@ echo "Simple tests."
	@ ./$(TARGET) -f test/typing/simple.dsubml \
                -a typing
	@ echo "\n---------------------------------------\n"

test_check_typing:
	@ echo "----- Check Typing Algorithm -----"
	@ echo "Simple tests."
	@ ./$(TARGET) -f test/check_typing/simple.dsubml \
                -a check_typing
	@ echo "\n---------------------------------------\n"

test: test_subtype test_typing test_check_typing

# Generate the interface for CPPO files.
mli:
	@ $(OCAMLBUILD) $(MLI)

clean:
	@ rm -f *~
	@ $(OCAMLBUILD) -clean
