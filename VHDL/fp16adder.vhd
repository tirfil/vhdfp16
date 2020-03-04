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
		IN1			: in	std_logic_vector(15 downto 0);
		IN2			: in	std_logic_vector(15 downto 0);
		OUT0		: out	std_logic_vector(15 downto 0);
		START		: in	std_logic;
		DONE		: out	std_logic
	);
end fp16adder;

architecture rtl of fp16adder is
constant mantissa : integer := 12;
type state_t is (S_IDLE,S_0,S_10,S_11,S_2,S_3,S_4,S_31);
signal state : state_t;
signal M1,M2,M3 : unsigned(11 downto 0);
signal X1,X2,X3 : unsigned(4 downto 0);
signal S1,S2,S3	: std_logic;
signal dif : unsigned(4 downto 0);
signal i : integer range 0 to 15;
begin

	P_OTO: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			DONE <= '0';
			OUT0 <= (others=>'0');
			M3 <= (others=>'0');
			X3 <= (others=>'0');
			S3 <= '0';
		elsif (MCLK'event and MCLK = '1') then
			if (state = S_IDLE) then
				DONE <= '0';
				OUT0 <= (others=>'0');
				M3 <= (others=>'0');
				X3 <= (others=>'0');
				S3 <= '0';
				if (START='1') then
					state <= S_0;
					M1(9 downto 0) <= unsigned(IN1(9 downto 0));
					M1(11 downto 10) <= "01";
					M2(9 downto 0) <= unsigned(IN2(9 downto 0));
					M2(11 downto 10) <= "01";
					X1 <= unsigned(IN1(14 downto 10));
					X2 <= unsigned(IN2(14 downto 10));
					S1 <= IN1(15);
					S2 <= IN2(15);
				end if;
			elsif ( state = S_0 ) then -- exponent
				if (X1 > X2) then
					dif <= X1 - X2;
					state <= S_10;
				else
					dif <= X2 - X1;
					state <= S_11;
				end if;
			elsif (state = S_10 ) then -- shift
				X3 <= X1;
				if (dif < mantissa) then
					M2 <= shift_right(M2,to_integer(dif));
				else 
					M2 <= (others=>'0');
				end if;
				state <= S_2;
			elsif (state = S_11 ) then -- shift
				X3 <= X2;
				if (dif < mantissa) then
					M1 <= shift_right(M1,to_integer(dif));
				else 
					M1 <= (others=>'0');
				end if;
				state <= S_2;
			elsif (state = S_2) then -- addition
				if (S1 = S2) then -- same sign
					M3 <= M1 + M2;
					S3 <= S1;
					--report "Same sign";
				elsif (S1 = '0') then -- +-
					if (M1 > M2) then
						M3 <= M1 - M2;
						S3 <= '0';
					else
						M3 <= M2 - M1;
						S3 <= '1';
					end if;
				else	-- -+
					if (M2 > M1 ) then
						M3 <= M2 - M1;
						S3 <= '0';
					else
						M3 <= M1 - M2;
						S3 <= '1';
					end if;
				end if;
				state <= S_3;
			elsif (state = S_3) then -- normalize
				if (M3(11) = '1') then -- addition overflow
					M3 <= shift_right(M3,1);
					X3 <= X3 + 1;
					state <= S_4;
				else 
					state <= S_31;
					i <= 0;
				end if;
			elsif (state = S_31) then
				if (M3(10) = '1') then
					state <= S_4;
				elsif (i = mantissa) then -- zero
					X3 <= (others=>'0');
					S3 <= '0';
					--report "Zero";
					state <= S_4;
				else
					M3 <= shift_left(M3,1);
					X3 <= X3 - 1;
					state <= S_31;
					i <= i+1;
				end if;
			elsif (state = S_4) then
				OUT0 <= S3 & std_logic_vector(X3) & std_logic_vector(M3(9 downto 0));
				DONE <= '1';
				state <= S_IDLE;
			end if;
			
		end if;
	end process P_OTO;

end rtl;

