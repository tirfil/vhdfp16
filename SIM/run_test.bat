set FLAG=-v -PALL_LIB --syn-binding --ieee=synopsys --std=93c -fexplicit

ghdl -a --work=WORK --workdir=ALL_LIB %FLAG% ..\TEST\tb_%1.vhd
ghdl -e --work=WORK --workdir=ALL_LIB %FLAG% tb_%1
ghdl -r --work=WORK --workdir=ALL_LIB %FLAG% tb_%1 --wave=tb_%1.ghw

