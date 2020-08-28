--###############################
--# Project Name : 
--# File         : 
--# Author       : Philippe THIRION <https://github.com/tirfil>
--# Description  : 
--# Modification History
--# 20200827 improvement: less state
--# 20200827 infinity + zero
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
type state_t is (S_IDLE,S_0,S_2,S_3,S_4);
signal state : state_t;
signal M1,M2,M3 : unsigned(11 downto 0);
signal X1,X2,X3 : unsigned(4 downto 0);
signal S1,S2,S3	: std_logic;
--signal i : integer range 0 to 15;

function to_left(vec : unsigned) return integer is
variable I : integer range 10 downto 0;
begin
	I := 0;
	while vec(vec'left - I)='0' and I/=vec'left loop
		I:= I+1;
	end loop;
	return I;
end function;

begin

	P_OTO: process(MCLK, nRST)
	variable value : integer range 0 to 10;
	variable dif : unsigned(4 downto 0);
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
					dif := X1 - X2;
					X3 <= X1;
					if (dif < mantissa) then
						M2 <= shift_right(M2,to_integer(dif));
					else 
						M2 <= (others=>'0');
					end if;
				else
					dif := X2 - X1;
					X3 <= X2;
					if (dif < mantissa) then
						M1 <= shift_right(M1,to_integer(dif));
					else 
						M1 <= (others=>'0');
					end if;
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
					-- infinity test
					if (X3 = "11110") then
						X3 <= (others=>'1');
						M3 <= (others=>'0');
					else
						X3 <= X3 + 1;
					end if;
					state <= S_4;
				elsif (M3(10) = '1') then
					state <= S_4;
				elsif M3(10 downto 0) = "00000000000" then -- zero
					X3 <= (others=>'0');
					S3 <= '0';
					state <= S_4;
				else 
					value := to_left(M3(10 downto 0));
					--report integer'image(to_integer(M3));
					-- zero test
					if (X3 >= value) then
						M3 <= shift_left(M3,value);
						X3 <= X3 - value;
					else
						M3 <= (others=>'0');
						X3 <= (others=>'0');
					end if;
					state <= S_4;
				end if;
			elsif (state = S_4) then
				--report integer'image(to_integer(M3));
				OUT0 <= S3 & std_logic_vector(X3) & std_logic_vector(M3(9 downto 0));
				DONE <= '1';
				state <= S_IDLE;
			end if;
			
		end if;
	end process P_OTO;

end rtl;

