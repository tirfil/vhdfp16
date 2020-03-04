--###############################
--# Project Name : 
--# File         : 
--# Author       : 
--# Description  : 
--# Modification History
--#
--###############################

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fp16adder is
	port(
		MCLK		: in	std_logic;
		nRST		: in	std_logic;
		IN1		: in	std_logic_vector(15 downto 0);
		IN2		: in	std_logic_vector(15 downto 0);
		OUT0		: out	std_logic_vector(15 downto 0);
		START		: in	std_logic;
		DONE		: out	std_logic
	);
end fp16adder;

architecture rtl of fp16adder is

begin

	TODO: process(MCLK, nRST)
	begin
		if (nRST = '0') then

		elsif (MCLK'event and MCLK = '1') then

	end process TODO;

end rtl;

