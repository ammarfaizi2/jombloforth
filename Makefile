all: jombloforth

jombloforth.o: jombloforth.asm
	nasm -g -F dwarf -f elf64 -o jombloforth.o jombloforth.asm

jombloforth: jombloforth.o
	ld -o jombloforth jombloforth.o

dump: jombloforth.o
	objdump -d -M intel jombloforth.o

dumpall: jombloforth.o
	objdump -j .data -j .text -d -M intel jombloforth.o

.PHONY: dump dumpall all
