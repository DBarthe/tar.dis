
OCAMLMAKEFILE = OCamlMakefile

RESULT = tardis

SOURCES =	src/source.ml \
			src/freqTable.ml \
			src/prefixCode.ml \
			src/huffman.ml \
			src/tardis.ml \
			src/tardisSpec.ml \
			src/tardisWriter.ml \
			src/tardisReader.ml \
			src/main.ml

INCDIRS = lib/my/src/
LIBS = lib/my/libmy

OCAMLDOCFLAGS = -charset utf-8
DOC_FILES = $(wildcard src/*.mli)

all: libmy bc

libmy:
	make -C lib/my INCDIRS= LIBS=
clean-libmy:
	make clean -C lib/my INCDIRS= LIBS=


include $(OCAMLMAKEFILE)

