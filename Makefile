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

.PHONY: all test clean

all:
	@ $(OCAMLBUILD) $(SRC_DIR)/$(TARGET)

test: all
	@ ./$(TARGET)

clean:
	@ rm -f *~
	@ $(OCAMLBUILD) -clean
