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
	procedure enter (
		A , B , Z: in std_logic_vector
	) is 
	begin
		wait until mclk'event and mclk='1';
		IN1 <= A; 
		IN2 <= B; -- 0.5
		start <= '1';
		wait until mclk'event and mclk='1';
		start <= '0';
		wait until DONE <= '1';
		wait for 0 ns;
		assert (OUT0=Z) report "ERROR" severity note;
		wait until mclk'event and mclk='1';
	end enter;
	begin
		start <= '0';
		clracc <= '0';
		nRST <= '0';
		IN1 <= (others=>'0');
		IN2 <= (others=>'0');
		wait for 1000 ns;
		nRST <= '1';
		enter("0101011001000000","0011100000000000","0101001001000000"); -- 100 0.5 50 (5420)
		enter("0101100010110000","0011010000000000","0101010101111000"); -- 150 0.25 87.5 (5578)
		enter("0101001001000000","0011000000000000","0101010111011100"); -- 50 0.125 93.75 (55DC)
		wait until mclk'event and mclk='1';
		clracc <= '1';
		wait until mclk'event and mclk='1';
		clracc <= '0';
		wait until mclk'event and mclk='1';
		--enter("0110010100000000","0010111001100110","0101100000000000"); -- 1280 0.1 128 (5800)
		enter("0110010100000000","0010111001100110","0101011111111111"); -- 1280 0.1 128 (57FF)
		--enter("0101000100000000","1011000011001101","0101011110100000"); -- 40 -0.15 122 (57A0)
		enter("0101000100000000","1011000011001101","0101011110011111"); -- 40 -0.15 122 (579F)
		--enter("1100010100000000","1011110011001101","0101100000000000"); -- -5 -1.2  128 (5800)
		enter("1100010100000000","1011110011001101","0101011111111111"); -- -5 -1.2  128 (57FF)
		enter("1110001100000000","0011000010010010","0000000000000000"); -- -896 1/7 0 (0000)
		wait until mclk'event and mclk='1';
		clracc <= '1';
		wait until mclk'event and mclk='1';
		clracc <= '0';
		wait until mclk'event and mclk='1';		
		wait until mclk'event and mclk='1';
		RUNNING <= '0';
		wait;
	end process GO;

end stimulus;
