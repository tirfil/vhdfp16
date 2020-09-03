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

entity tb_fix2float16 is
end tb_fix2float16;

architecture stimulus of tb_fix2float16 is

	constant FILE_IN 	: string := "ff16.txt";
	file fptr_in		: text;
	constant FILE_OUT 	: string := "ff16out.txt";
	file fptr_out		: text;

-- COMPONENTS --
	component fix2float16
		port(
			MCLK		: in	std_logic;
			nRST		: in	std_logic;
			START		: in	std_logic;
			DONE		: out	std_logic;
			FIXSIGN		: in	std_logic;
			FIXIN		: in	std_logic_vector(15 downto 0);
			FIXDOT		: in	std_logic_vector(3 downto 0);
			FLOAT16		: out	std_logic_vector(15 downto 0)
		);
	end component;

--
-- SIGNALS --
	signal MCLK		: std_logic;
	signal nRST		: std_logic;
	signal START		: std_logic;
	signal DONE		: std_logic;
	signal FIXSIGN		: std_logic;
	signal FIXIN		: std_logic_vector(15 downto 0);
	signal FIXDOT		: std_logic_vector(3 downto 0);
	signal FLOAT16		: std_logic_vector(15 downto 0);

--
	signal RUNNING	: std_logic := '1';

begin

-- PORT MAP --
	I_fix2float16_0 : fix2float16
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			START		=> START,
			DONE		=> DONE,
			FIXSIGN		=> FIXSIGN,
			FIXIN		=> FIXIN,
			FIXDOT		=> FIXDOT,
			FLOAT16		=> FLOAT16
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
		variable arg		: bit_vector(15 downto 0);
		variable arg1		: bit_vector(3 downto 0);
		variable arg2		: bit_vector(15 downto 0);
	begin
		file_open(fstat_in, fptr_in, FILE_IN, read_mode);
		file_open(fstat_out, fptr_out, FILE_OUT, write_mode);
		FIXSIGN <= '0';
		FIXDOT <= (others=>'0');
		FIXIN <= (others=>'0');
		nRST <= '0';
		START <= '0';
		wait for 1001 ns;
		nRST <= '1';
		wait for 40 ns;
		while (not endfile(fptr_in)) loop
			wait for 1 ns;
			readline(fptr_in, fline_in);
			read(fline_in,arg);
			read(fline_in,arg1);
			read(fline_in,arg2);
			FIXIN <= to_stdlogicvector(arg);
			FIXDOT <= to_stdlogicvector(arg1);
			START <= '1';
			wait for 20 ns;
			START <= '0';
			wait until DONE='0' and DONE'event;
			--report(integer'image(to_integer(unsigned(FLOAT16))));
			write(fline_out,arg);
			write(fline_out,string'(" "));
			write(fline_out,arg1);
			write(fline_out,string'(" "));
			write(fline_out,to_bitvector(FLOAT16));
			writeline(fptr_out,fline_out);
			wait until mclk='1' and mclk'event;
		end loop;
		RUNNING <= '0';
		wait;
	end process GO;

end stimulus;
