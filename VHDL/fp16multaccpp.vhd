--###############################
--# Project Name : 
--# File         : 
--# Author       : Philippe THIRION <https://github.com/tirfil>
--# Description  : 
--# Modification History
--# pp = pipeline
--###############################

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fp16multaccpp is
	port(
		MCLK		: in	std_logic;
		nRST		: in	std_logic;
		IN1		: in	std_logic_vector(15 downto 0);
		IN2		: in	std_logic_vector(15 downto 0);
		OUT0		: out	std_logic_vector(15 downto 0);
		START		: in	std_logic;
		DONE		: out	std_logic;
		CLRACC		: in	std_logic;
		READY		: out	std_logic
	);
end fp16multaccpp;

architecture struct of fp16multaccpp is
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
	component fp16multw
		port(
			MCLK		: in	std_logic;
			nRST		: in	std_logic;
			IN1			: in	std_logic_vector(15 downto 0);
			IN2			: in	std_logic_vector(15 downto 0);
			OUT0		: out	std_logic_vector(15 downto 0);
			START		: in	std_logic;
			DONE		: out	std_logic;
			MWAIT		: in 	std_logic
		);
	end component;
	
	signal outmult : std_logic_vector(15 downto 0);
	signal outadd  : std_logic_vector(15 downto 0);
	signal inadd : std_logic_vector(15 downto 0);
	
	signal donemult : std_logic;
	signal doneadd  : std_logic;
	
	signal mwait : std_logic;
	signal startadd : std_logic;
	signal acc_empty : std_logic;
	
	signal accumulator : std_logic_vector(15 downto 0);
begin

	I_fp16mult_0 : fp16multw
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			IN1			=> IN1,
			IN2			=> IN2,
			OUT0		=> outmult,
			START		=> START,
			DONE		=> donemult,
			MWAIT		=> mwait
		);
		
	I_fp16adder_0 : fp16adder
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			IN1			=> accumulator,
			IN2			=> inadd,
			--IN2			=> outmult,
			OUT0		=> outadd,
			START		=> startadd,
			DONE		=> doneadd
		);
		
	P_ACC: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			accumulator <= (others=>'0');
			DONE <= '0';
			acc_empty <= '1';
			startadd <= '0';
			inadd <= (others=>'0');
		elsif (MCLK'event and MCLK = '1') then
			startadd <= '0';
			DONE <= '0';
			if (CLRACC='1') then
				accumulator <= (others=>'0');
				acc_empty <= '1';
			elsif (donemult = '1') then
				if (acc_empty = '1') then
					accumulator <= outmult;
					acc_empty <= '0';
					DONE <= '1';
				else 
					inadd <= outmult;
					startadd <= '1';
				end if;
			elsif (doneadd = '1') then
					accumulator <= outadd;
					DONE <= '1';
			end if;
			--DONE <= doneadd; -- delay by one cycle
		end if;
	end process P_ACC;	
	
	P_PP: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			mwait <= '0';
			ready <= '1';
		elsif (MCLK'event and MCLK = '1') then
			-- READY
			if (CLRACC='1') then
				READY <= '1';
			elsif (START = '1') then
				READY <= '0';
			elsif (donemult = '1') then
				READY <= '1';
			end if;
			--- mwait
			if (CLRACC='1') then
				mwait <= '0';
			elsif (startadd = '1') then
				mwait <= '1';
			elsif (doneadd = '1') then
				mwait <= '0';
			end if;	
		end if;	
	end process P_PP;

	--P_ACC: process(MCLK, nRST)
	--begin
		--if (nRST = '0') then
			--accumulator <= (others=>'0');
			--DONE <= '0';
		--elsif (MCLK'event and MCLK = '1') then
			--if (CLRACC='1') then
				--accumulator <= (others=>'0');
			--elsif (doneadd = '1') then
				--accumulator <= outadd;
			--end if;
			--DONE <= doneadd; -- delay by one cycle
		--end if;
	--end process P_ACC;
	
	OUT0 <= accumulator;

end struct;

