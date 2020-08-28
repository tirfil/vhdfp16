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

entity fp16adderppl is
	port(
		MCLK		: in	std_logic;
		nRST		: in	std_logic;
		ENABLE		: in	std_logic;
		IN1			: in	std_logic_vector(15 downto 0);
		IN2			: in	std_logic_vector(15 downto 0);
		OUT0		: out	std_logic_vector(15 downto 0)
	);
end fp16adderppl;

architecture rtl of fp16adderppl is
signal L0_M1 : unsigned(11 downto 0);
signal L0_M2 : unsigned(11 downto 0);
signal L0_X1 : unsigned(4 downto 0);
signal L0_X2 : unsigned(4 downto 0);
signal L0_S1 : std_logic;
signal L0_S2 : std_logic;

signal L1_M1 : unsigned(11 downto 0);
signal L1_M2 : unsigned(11 downto 0);
signal L1_X3 : unsigned(4 downto 0);
signal L1_S1 : std_logic;
signal L1_S2 : std_logic;

signal L2_M3 : unsigned(11 downto 0);
signal L2_X3 : unsigned(4 downto 0);
signal L2_S3 : std_logic;

signal L3_M3 : unsigned(11 downto 0);
signal L3_X3 : unsigned(4 downto 0);
signal L3_S3 : std_logic;

signal L4_OUT0 : std_logic_vector(15 downto 0);


begin

	-- input
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
			if (ENABLE = '1') then
				L0_M1(9 downto 0) <= unsigned(IN1(9 downto 0));
				L0_M1(11 downto 10) <= "01";
				L0_M2(9 downto 0) <= unsigned(IN2(9 downto 0));
				L0_M2(11 downto 10) <= "01";
				L0_X1 <= unsigned(IN1(14 downto 10));
				L0_X2 <= unsigned(IN2(14 downto 10));
				L0_S1 <= IN1(15);
				L0_S2 <= IN2(15);
			end if;
		end if;
	end process P_LAYER_0;
	
	-- compute exponent
	P_LAYER_1: process(MCLK, nRST)
	constant mantissa : integer := 12;
	variable dif : unsigned(4 downto 0);
	begin
		if (nRST = '0') then
			L1_M1 <= (others=>'0');
			L1_M2 <= (others=>'0');
			L1_X3 <= (others=>'0');
			L1_S1 <= '0';
			L1_S2 <= '0';
		elsif (MCLK'event and MCLK = '1') then
			if (ENABLE = '1') then
				L1_S1 <= L0_S1;
				L1_S2 <= L0_S2;
				if (L0_X1 > L0_X2) then
					dif := L0_X1 - L0_X2;
					L1_X3 <= L0_X1;
					L1_M1 <= L0_M1;
					if (dif < mantissa) then
						L1_M2 <= shift_right(L0_M2,to_integer(dif));
					else 
						L1_M2 <= (others=>'0');
					end if;
				else
					dif := L0_X2 - L0_X1;
					L1_X3 <= L0_X2;
					L1_M2 <= L0_M2;
					if (dif < mantissa) then
						L1_M1 <= shift_right(L0_M1,to_integer(dif));
					else 
						L1_M1 <= (others=>'0');
					end if;
				end if;
			end if;
		end if;
	end process P_LAYER_1;

	-- sign management + addition
	P_LAYER_2: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			L2_M3 <= (others=>'0');
			L2_X3 <= (others=>'0');
			L2_S3 <= '0';
		elsif (MCLK'event and MCLK = '1') then
			if (ENABLE = '1') then
				L2_X3 <= L1_X3;
				if (L1_S1 = L1_S2) then -- same sign
					L2_M3 <= L1_M1 + L1_M2;
					L2_S3 <= L1_S1;
				elsif (L1_S1 = '0') then -- +-
					if (L1_M1 > L1_M2) then
						L2_M3 <= L1_M1 - L1_M2;
						L2_S3 <= '0';
					else
						L2_M3 <= L1_M2 - L1_M1;
						L2_S3 <= '1';
					end if;
				else	-- -+
					if (L1_M2 > L1_M1 ) then
						L2_M3 <= L1_M2 - L1_M1;
						L2_S3 <= '0';
					else
						L2_M3 <= L1_M1 - L1_M2;
						L2_S3 <= '1';
					end if;
				end if;
			end if;
		end if;
	end process P_LAYER_2;
	
	-- normalization
	P_LAYER_3: process(MCLK, nRST)
	function to_left(vec : unsigned) return integer is
	variable I : integer range 10 downto 0;
	begin
		I := 0;
		while vec(vec'left - I)='0' and I/=vec'left loop
		I:= I+1;
		end loop;
		return I;
	end function;
	variable value : integer range 0 to 10;
	begin
		if (nRST = '0') then
			L3_M3 <= (others=>'0');
			L3_X3 <= (others=>'0');
			L3_S3 <= '0';
		elsif (MCLK'event and MCLK = '1') then
			if (ENABLE = '1') then
				L3_S3 <= L2_S3;
				if (L2_M3(11) = '1') then -- addition overflow
					L3_M3 <= shift_right(L2_M3,1);
					-- infinity test
					if (L2_X3 = "11110") then
						L3_X3 <= (others=>'1');
						L3_M3 <= (others=>'0');
					else
						L3_X3 <= L2_X3 + 1;
					end if;
				elsif (L2_M3(10) = '1') then
					L3_M3 <= L2_M3;
					L3_X3 <= L2_X3;
				elsif L2_M3(10 downto 0) = "00000000000" then -- zero
					L3_M3 <= (others=>'0');
					L3_X3 <= (others=>'0');
					L3_S3 <= '0';
				else 
					value := to_left(L2_M3(10 downto 0));
					if (L2_X3 >= value) then
						L3_M3 <= shift_left(L2_M3,value);
						L3_X3 <= L2_X3 - value;
					else
						L3_M3 <= (others=>'0');
						L3_X3 <= (others=>'0');
					end if;
				end if;
			end if;
		end if;
	end process P_LAYER_3;
	
	P_LAYER_4: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			L4_OUT0 <= (others=>'0');
		elsif (MCLK'event and MCLK = '1') then
			if (ENABLE = '1') then
				L4_OUT0 <= L3_S3 & std_logic_vector(L3_X3) & std_logic_vector(L3_M3(9 downto 0));
			end if;
		end if;
	end process P_LAYER_4;
	
	OUT0 <= L4_OUT0;
		
end rtl;

