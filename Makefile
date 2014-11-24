OCAMLMAKEFILE = OCamlMakefile

RESULT = tardis

SOURCES = 	src/source.ml \
			src/freqTable.ml \
			src/prefixCode.ml \
			src/huffman.ml \
			src/tardis.ml

OCAMLDOCFLAGS = -charset utf-8
DOC_FILES = $(wildcard src/*.mli)

all: bc

include $(OCAMLMAKEFILE)