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
--library std;
use std.textio.all;

entity tb_fp16adder is
end tb_fp16adder;

architecture stimulus of tb_fp16adder is

	constant FILE_IN : string := "fp16.txt";
	file fptr_in		   : text;
	constant FILE_OUT : string := "fp16out.txt";
	file fptr_out		   : text;

-- COMPONENTS --
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

--
-- SIGNALS --
	signal MCLK		: std_logic;
	signal nRST		: std_logic;
	signal IN1		: std_logic_vector(15 downto 0);
	signal IN2		: std_logic_vector(15 downto 0);
	signal OUT0		: std_logic_vector(15 downto 0);
	signal START	: std_logic;
	signal DONE		: std_logic;

--
	signal RUNNING	: std_logic := '1';
	
	

begin

-- PORT MAP --
	I_fp16adder_0 : fp16adder
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			IN1			=> IN1,
			IN2			=> IN2,
			OUT0		=> OUT0,
			START		=> START,
			DONE		=> DONE
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
		start <= '0';
		IN1 <= (others=>'0');
		IN2 <= (others=>'0');
		wait for 1000 ns;
		nRST <= '1';
		while (not endfile(fptr_in)) loop
			--report "Debug";
			readline(fptr_in, fline_in);
			wait until mclk='1' and mclk'event;
			start <= '1';
			read(fline_in,arg1);
			IN1 <= to_stdlogicvector(arg1);
			read(fline_in,arg2);
			IN2 <= to_stdlogicvector(arg2);
			wait until mclk='1' and mclk'event;
			start <= '0';
			wait until DONE = '1';
			wait until mclk='0' and mclk'event;
			--read(fline_in,arg3);
			--assert OUT0=to_stdlogicvector(arg3) report "Check error" severity note;
			--assert OUT0/=to_stdlogicvector(arg3) report "Test OK" severity note;
			--if (OUT0 /= to_stdlogicvector(arg3)) then
				--count := count + 1;
			--end if;
			write(fline_out,arg1);
			write(fline_out,string'(" "));
			write(fline_out,arg2);
			write(fline_out,string'(" "));
			write(fline_out,to_bitvector(OUT0));
			writeline(fptr_out,fline_out);
			wait until mclk='1' and mclk'event;
		end loop;
		file_close(fptr_in);
		file_close(fptr_out);
		report "End of Test => Error: " & integer'image(count);
		RUNNING <= '0';
		wait;
	end process GO;

end stimulus;
