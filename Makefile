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

test: all
	@ ./$(TARGET)

# Generate the interface for CPPO files.
mli:
	@ $(OCAMLBUILD) $(MLI)

clean:
	@ rm -f *~
	@ $(OCAMLBUILD) -clean
