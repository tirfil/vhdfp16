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
use std.textio.all;

entity tb_fp16adderppl is
end tb_fp16adderppl;

architecture stimulus of tb_fp16adderppl is

	constant FILE_IN : string := "fp16ppl.txt";
	file fptr_in		   : text;
	constant FILE_OUT : string := "fp16pplout.txt";
	file fptr_out		   : text;

-- COMPONENTS --
	component fp16adderppl
		port(
			MCLK		: in	std_logic;
			nRST		: in	std_logic;
			ENABLE		: in	std_logic;
			IN1		: in	std_logic_vector(15 downto 0);
			IN2		: in	std_logic_vector(15 downto 0);
			OUT0		: out	std_logic_vector(15 downto 0)
		);
	end component;

--
-- SIGNALS --
	signal MCLK		: std_logic;
	signal nRST		: std_logic;
	signal ENABLE		: std_logic;
	signal IN1		: std_logic_vector(15 downto 0);
	signal IN2		: std_logic_vector(15 downto 0);
	signal OUT0		: std_logic_vector(15 downto 0);

--
	signal RUNNING	: std_logic := '1';

begin

-- PORT MAP --
	I_fp16adderppl_0 : fp16adderppl
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			ENABLE		=> ENABLE,
			IN1		=> IN1,
			IN2		=> IN2,
			OUT0		=> OUT0
		);

--
	CLOCK: process
	begin
		while (RUNNING = '1') loop
			MCLK <= '1';
			wait for 10 ns;
			MCLK <= '0';
			wait for 10 ns;
		end loop;
		wait;
	end process CLOCK;

	GO: process
		variable fline_in 		: line;
		variable fline_out 	: line;
		variable fstat_in  	: file_open_status;
		variable fstat_out  : file_open_status;
		variable arg1		: bit_vector(15 downto 0);
		variable arg2		: bit_vector(15 downto 0);
		variable arg3		: bit_vector(15 downto 0);
		variable count		: integer := 0;
	begin
		file_open(fstat_in, fptr_in, FILE_IN, read_mode);
		file_open(fstat_out, fptr_out, FILE_OUT, write_mode);
		nRST <= '0';
		--start <= '0';
		ENABLE <= '1';
		IN1 <= (others=>'0');
		IN2 <= (others=>'0');
		wait for 1001 ns;
		nRST <= '1';
		while (not endfile(fptr_in)) loop
			--report "Debug";
			readline(fptr_in, fline_in);
			--wait until mclk='1' and mclk'event;
			--start <= '1';
			read(fline_in,arg1);
			IN1 <= to_stdlogicvector(arg1);
			read(fline_in,arg2);
			IN2 <= to_stdlogicvector(arg2);
			--wait until mclk='1' and mclk'event;
			--start <= '0';
			--wait until DONE = '1';
			--wait until mclk='0' and mclk'event;
			wait until mclk='1' and mclk'event;
			write(fline_out,arg1);
			write(fline_out,string'(" "));
			write(fline_out,arg2);
			write(fline_out,string'(" "));
			write(fline_out,to_bitvector(OUT0));
			writeline(fptr_out,fline_out);
		end loop;
		file_close(fptr_in);
		file_close(fptr_out);
		--report "End of Test => Error: " & integer'image(count);
		RUNNING <= '0';
		wait;
	end process GO;

end stimulus;
