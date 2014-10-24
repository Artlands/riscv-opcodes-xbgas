SHELL := /bin/sh

ISASIM_H := ../riscv-isa-sim/riscv/encoding.h
ISASIM_HWACHA_H := ../riscv-isa-sim/hwacha/opcodes_hwacha_ut.h
PK_H := ../riscv-pk/pk/encoding.h
ENV_H := ../riscv-tests/env/encoding.h
GAS_H := ../riscv-gcc/binutils-2.21.1/include/opcode/riscv-opc.h
XCC_H := ../riscv-gcc/gcc-4.6.1/gcc/config/riscv/riscv-opc.h 

ALL_OPCODES := opcodes opcodes-pseudo opcodes-rvc opcodes-hwacha opcodes-hwacha-pseudo opcodes-hwacha-ut opcodes-custom

install: $(ISASIM_H) $(PK_H) $(ENV_H) $(GAS_H) $(XCC_H) inst.chisel instr-table.tex

$(ISASIM_H) $(PK_H) $(ENV_H): $(ALL_OPCODES) parse-opcodes
	cp encoding.h $@
	./parse-opcodes -c < opcodes >> $@

$(GAS_H) $(XCC_H): $(ALL_OPCODES) parse-opcodes
	cat $(ALL_OPCODES) | ./parse-opcodes -c > $@

$(ISASIM_HWACHA_H): $(ALL_OPCODES) parse-opcodes
	cat opcodes opcodes-hwacha-ut | ./parse-opcodes -c | \
	sed 's/DECLARE_INSN(/DECLARE_INSN(ut_/g' | \
	cpp -P -D DECLARE_INSN=DECLARE_INSN | sort -o $@

inst.chisel: $(ALL_OPCODES) parse-opcodes
	cat opcodes opcodes-custom | ./parse-opcodes -chisel > $@

instr-table.tex: $(ALL_OPCODES) parse-opcodes
	cat opcodes opcodes-pseudo | ./parse-opcodes -tex > $@

.PHONY : install
