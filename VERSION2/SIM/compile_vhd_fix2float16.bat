set FLAG=-v -PALL_LIB --syn-binding --ieee=synopsys --std=93c -fexplicit
rem set FLAG=-v -PALL_LIB --syn-binding --std=08 -fexplicit
ghdl -a --work=WORK --workdir=ALL_LIB %FLAG% ../VHDL/fix2float16.vhd
rem ghdl -a --work=WORK --workdir=ALL_LIB %FLAG% ../VHDL/fp16mult.vhd

