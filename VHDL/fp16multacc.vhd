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

entity fp16multacc is
	port(
		MCLK		: in	std_logic;
		nRST		: in	std_logic;
		IN1		: in	std_logic_vector(15 downto 0);
		IN2		: in	std_logic_vector(15 downto 0);
		OUT0		: out	std_logic_vector(15 downto 0);
		START		: in	std_logic;
		DONE		: out	std_logic;
		CLRACC		: in	std_logic
	);
end fp16multacc;

architecture struct of fp16multacc is
	component fp16adder
		port(
			MCLK		: in	std_logic;
			nRST		: in	std_logic;
			IN1		: in	std_logic_vector(15 downto 0);
			IN2		: in	std_logic_vector(15 downto 0);
			OUT0		: out	std_logic_vector(15 downto 0);
			START		: in	std_logic;
			DONE		: out	std_logic
		);
	end component;
	component fp16mult
		port(
			MCLK		: in	std_logic;
			nRST		: in	std_logic;
			IN1			: in	std_logic_vector(15 downto 0);
			IN2			: in	std_logic_vector(15 downto 0);
			OUT0		: out	std_logic_vector(15 downto 0);
			START		: in	std_logic;
			DONE		: out	std_logic
		);
	end component;
	
	signal outmult : std_logic_vector(15 downto 0);
	signal outadd  : std_logic_vector(15 downto 0);
	
	signal donemult : std_logic;
	signal doneadd  : std_logic;
	
	signal accumulator : std_logic_vector(15 downto 0);
begin

	I_fp16mult_0 : fp16mult
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			IN1			=> IN1,
			IN2			=> IN2,
			OUT0		=> outmult,
			START		=> START,
			DONE		=> donemult
		);
		
	I_fp16adder_0 : fp16adder
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			IN1			=> accumulator,
			IN2			=> outmult,
			OUT0		=> outadd,
			START		=> donemult,
			DONE		=> doneadd
		);

	P_ACC: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			accumulator <= (others=>'0');
			DONE <= '0';
		elsif (MCLK'event and MCLK = '1') then
			if (CLRACC='1') then
				accumulator <= (others=>'0');
			elsif (doneadd = '1') then
				accumulator <= outadd;
			end if;
			DONE <= doneadd; -- delay by one cycle
		end if;
	end process P_ACC;
	
	OUT0 <= accumulator;

end struct;

