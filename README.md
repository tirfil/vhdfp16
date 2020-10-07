# vhdfp16
FP16 Half precision floating point (IEEE754 2008) adder + multiplier

# VERSION 2.

adder + mult

sequential version (state machine) and pipeline version

fix issue (process correctly infinity and zero)

discrease delay in adder from 7 to 5 cycle clock.

Not conform to IEEE754 "default" rounding rules ( **Round to nearest** ) but ...

... conform to rounding rules **Round down, or round toward minus infinity**

https://www.keil.com/support/man/docs/armlib/armlib_chr1358938950865.htm

=================================================================================

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
| CLRACC | IN | Clear accumulator |

Notes: 
-----
Python programs availables for generating testbench files used by TextIO.

Refinement should be possible to reduce clock cycles or pipelining.

testbench comparison sometime fails due to unavoidable precision error:
compare input and output file for checking (using a diff tool)

# multiplier - accumulator 

Target: Intel MAX10 
-------------------

*Flow Status	Successful - Wed Mar 04 16:30:05 2020</br>*
*Quartus Prime Version	17.0.0 Build 595 04/25/2017 SJ Lite Edition</br>*
*Revision Name	fp16multacc</br>*
*Top-level Entity Name	fp16multacc</br>*
*Family	MAX 10</br>*
*Device	10M08SCE144A7G</br>*
*Timing Models	Final</br>*
*Total logic elements	__428__ / 8,064 ( 5 % )</br>*
*Total registers	198</br>*
*Total pins	53 / 101 ( 52 % )</br>*
*Total virtual pins	0</br>*
*Total memory bits	0 / 387,072 ( 0 % )</br>*
*Embedded Multiplier 9-bit elements	__2__ / 48 ( 4 % )</br>*
*Total PLLs	0 / 1 ( 0 % )</br>*
*UFM blocks	0 / 1 ( 0 % )</br>*
*ADC blocks	0</br>*

[<img src="https://raw.githubusercontent.com/tirfil/vhdfp16/master/IMAGE/fp16mulacc.jpg">](https://raw.githubusercontent.com/tirfil/vhdfp16/master/IMAGE/fp16mulacc.jpg)]

