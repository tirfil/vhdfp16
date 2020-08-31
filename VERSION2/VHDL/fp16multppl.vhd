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

entity fp16multppl is
	port(
		MCLK		: in	std_logic;
		nRST		: in	std_logic;
		ENABLE		: in	std_logic;
		IN1			: in	std_logic_vector(15 downto 0);
		IN2			: in	std_logic_vector(15 downto 0);
		OUT0		: out	std_logic_vector(15 downto 0)
	);
end fp16multppl;

architecture rtl of fp16multppl is
signal L0_M1 : unsigned(10 downto 0);
signal L0_M2 : unsigned(10 downto 0);
signal L0_X1 : unsigned(4 downto 0);
signal L0_X2 : unsigned(4 downto 0);
signal L0_S1 : std_logic;
signal L0_S2 : std_logic;

signal L1_MR : unsigned(21 downto 0);
signal L1_X3 : unsigned(5 downto 0);
signal L1_S3 : std_logic;
signal L1_ZERO : std_logic;  -- zero

signal L2_MR : unsigned(21 downto 0);
signal L2_X3 : unsigned(5 downto 0);
signal L2_S3 : std_logic;
signal L2_ZERO : std_logic;  -- zero
signal L2_INFINITY : std_logic;  -- infinity

signal L3_OUT0: std_logic_vector(15 downto 0);

begin

	P_LAYER_0: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			L0_M1 <= (others=>'0');
			L0_M2 <= (others=>'0');
			L0_X1 <= (others=>'0');
			L0_X2 <= (others=>'0');
			L0_S1 <= '0';
			L0_S2 <= '0';
		elsif (MCLK'event and MCLK = '1') then
			if (ENABLE='1') then
				L0_M1(9 downto 0) <= unsigned(IN1(9 downto 0));
				L0_M1(10) <= '1';
				L0_M2(9 downto 0) <= unsigned(IN2(9 downto 0));
				L0_M2(10) <= '1';					
				L0_X1 <= unsigned(IN1(14 downto 10));
				L0_X2 <= unsigned(IN2(14 downto 10));
				L0_S1 <= IN1(15);
				L0_S2 <= IN2(15);				
			end if;
		end if;
	end process P_LAYER_0;
	
	P_LAYER_1: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			L1_MR <= (others=>'0');
			L1_X3 <= (others=>'0');
			L1_S3 <= '0';
			L1_ZERO <= '0';
		elsif (MCLK'event and MCLK = '1') then
			if (ENABLE='1') then
				L1_ZERO <= '0';	
				if ('0' & L0_X1 & L0_M1(9 downto 0) = x"0000") then
					L1_ZERO <= '1';
				end if;	
				if ('0' & L0_X2 & L0_M2(9 downto 0) = x"0000") then
					L1_ZERO <= '1';
				end if;	
				L1_S3 <= L0_S1 xor L0_S2;
				L1_MR <= L0_M1 * L0_M2;
				L1_X3 <= ('0' & L0_X1) + ('0' & L0_X2);
			end if;
		end if;
	end process P_LAYER_1;

	P_LAYER_2: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			L2_MR <= (others=>'0');
			L2_X3 <= (others=>'0');
			L2_S3 <= '0';
			L2_ZERO <= '0';
			L2_INFINITY <= '0';
		elsif (MCLK'event and MCLK = '1') then
			if (ENABLE='1') then
				L2_S3 <= L1_S3;
				L2_ZERO <= L1_ZERO;
				L2_INFINITY <= '0';
				if (L1_MR(21) = '1') then
					L2_MR <= L1_MR;
					-- with carry
					--report "high";
					if (L1_X3 > 44) then
						L2_INFINITY <= '1';
					elsif (L1_X3 > 14) then
						L2_X3 <= L1_X3 - 14;
					else
						L2_ZERO <= '1';
					end if;
				else
					-- without carry
					--report "shift left";
					L2_MR <= shift_left(L1_MR,1);
					if (L1_X3 > 45) then
						L2_INFINITY <= '1';
					elsif (L1_X3 > 15) then
						L2_X3 <= L1_X3 - 15;
					else
						L2_ZERO <= '1';
					end if;
			    end if;
		      end if;
		 end if;
	end process P_LAYER_2;
	
	P_LAYER_3: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			L3_OUT0 <= (others=>'0');
		elsif (MCLK'event and MCLK = '1') then
			if (ENABLE='1') then
				if (L2_INFINITY = '1') then  -- infinity
					L3_OUT0 <= L2_S3 & "11111" & "0000000000";
				elsif (L2_ZERO = '1') then
					L3_OUT0 <= (others=>'0');
				else
					L3_OUT0 <= L2_S3 & std_logic_vector(L2_X3(4 downto 0)) & std_logic_vector(L2_MR(20 downto 11));
				end if;
			end if;
		end if;
	end process P_LAYER_3;
	
	OUT0 <= L3_OUT0;
	
end rtl;

