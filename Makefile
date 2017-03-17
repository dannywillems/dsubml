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
	@ echo "Predefined types: without REFL."
	@ ./$(TARGET) -f test/subtype_predefined_types.dsubml \
                -a subtype \
                --use-stdlib
	@ echo "\n---------------------------------------\n"
	@ echo "Predefined types: with REFL."
	@ ./$(TARGET) -f test/subtype_predefined_types.dsubml \
                -a subtype_with_REFL \
                --use-stdlib
	@ echo "\n---------------------------------------\n"
	@ echo "Predefined types: same output"
	@ ./$(TARGET) -f test/subtype_predefined_types.dsubml \
                -a subtype_same_output \
                --use-stdlib
	@ echo "\n---------------------------------------\n"
	@ echo "Simple tests: without REFL"
	@ ./$(TARGET) -f test/subtype_simple.dsubml \
                -a subtype
	@ echo "\n---------------------------------------\n"
	@ echo "Simple tests: with REFL"
	@ ./$(TARGET) -f test/subtype_simple.dsubml \
                -a subtype_with_REFL
	@ echo "\n---------------------------------------\n"
	@ echo "Simple tests: same output"
	@ ./$(TARGET) -f test/subtype_simple.dsubml \
                -a subtype_same_output

test: all
	@ ./$(TARGET) -f test/subtype_predefined_types.dsubml \
                -a subtype_same_output \
                --use-stdlib
	@ ./$(TARGET) -f test/subtype_predefined_types.dsubml \
                -a subtype_same_output \
                --use-stdlib


# Generate the interface for CPPO files.
mli:
	@ $(OCAMLBUILD) $(MLI)

clean:
	@ rm -f *~
	@ $(OCAMLBUILD) -clean
