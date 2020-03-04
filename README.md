# vhdfp16
FP16 Half precision floating point (IEEE754 2008) adder + multiplier

|                   |                |
| ----------------- | -------------- |
| sign : 1 bit      |  (15)          |
| exponent: 5 bits  | (14 downto 10) |
| mantissa: 10 bits | (9 downto 0)   |

Simple interface for adder or multiplier:

| input/output |  dir/size | comment             |
| -------------| ---------- | ------------------- |
| MCLK | IN | Master clock |
| nRST | IN | Active low reset |
| IN1  | IN/16 | Input operand |
| IN2  | IN/16 | Input operand |
| OUT0 | OUT/16 | Result |
| START | IN | Start operation |
| DONE | OUT | Result is available |

Notes: 
-----
Python programs availables for generating testbench files used by TextIO.

Refinement should be possible to reduce clock cycles or pipelining.

testbench comparison sometime failed due to unavoidable precision error:
compare input and output file for checking (using a diff tool)
