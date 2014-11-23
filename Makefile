OCAMLMAKEFILE = OCamlMakefile

RESULT = tardis

SOURCES = src/freqTable.ml src/huffman.ml

OCAMLDOCFLAGS = -charset utf-8
DOC_FILES = $(wildcard src/*.mli)

all: bc

include $(OCAMLMAKEFILE)