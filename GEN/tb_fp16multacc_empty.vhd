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

entity tb_fp16multacc is
end tb_fp16multacc;

architecture stimulus of tb_fp16multacc is

-- COMPONENTS --
	component fp16multacc
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
	end component;

--
-- SIGNALS --
	signal MCLK		: std_logic;
	signal nRST		: std_logic;
	signal IN1		: std_logic_vector(15 downto 0);
	signal IN2		: std_logic_vector(15 downto 0);
	signal OUT0		: std_logic_vector(15 downto 0);
	signal START		: std_logic;
	signal DONE		: std_logic;
	signal CLRACC		: std_logic;

--
	signal RUNNING	: std_logic := '1';

begin

-- PORT MAP --
	I_fp16multacc_0 : fp16multacc
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			IN1		=> IN1,
			IN2		=> IN2,
			OUT0		=> OUT0,
			START		=> START,
			DONE		=> DONE,
			CLRACC		=> CLRACC
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
	begin
		nRST <= '0';
		wait for 1000 ns;
		nRST <= '1';

		RUNNING <= '0';
		wait;
	end process GO;

end stimulus;
