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

entity fix2float16 is
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
end fix2float16;

architecture rtl of fix2float16 is
function to_left(vec : unsigned) return integer is
	variable I : integer range 15 downto 0;
	begin
		I := 0;
		while vec(vec'left - I)='0' and I/=vec'left loop
		I:= I+1;
		end loop;
		return I;
end function;
type state_t is (S_IDLE,S_START,S_END);
signal state : state_t;
signal dot : integer range 0 to 15;
signal data : unsigned(15 downto 0);
signal exponent : unsigned(4 downto 0);
signal sign : std_logic;
signal zero : std_logic;
begin

	POTO: process(MCLK, nRST)
	variable value : integer range 0 to 31;
	begin
		if (nRST = '0') then
			state <= S_IDLE;
			zero <= '0';
			sign <= '0';
			data <= (others=>'0');
			exponent <= (others=>'0');
			DONE <= '0';
		elsif (MCLK'event and MCLK = '1') then
			if (state = S_IDLE) then
				zero <= '0';
				sign <= '0';
				data <= (others=>'0');
				exponent <= (others=>'0');
				DONE <= '0';		
				if (START = '1') then
					sign <= FIXSIGN;
					dot <= to_integer(unsigned(FIXDOT));
					data <= unsigned(FIXIN);
					state <= S_START;
				end if;
			elsif (state = S_START) then
				if data = x"0000" then
					zero <= '1';
				else
					--report(integer'image(to_left(data)));
					value := 1 + to_left(data);
					data <= shift_left(data,value);
					exponent <=  to_unsigned((31 - value - dot),5);
					state <= S_END;
				end if;
			elsif( state = S_END ) then
				if (zero='1') then
					FLOAT16 <= sign & "000000000000000";
				else
					FLOAT16 <= sign & std_logic_vector(exponent) & std_logic_vector(data(15 downto 6));
				end if;
				DONE <= '1';
				state <= S_IDLE;
			end if;
		end if;
	end process POTO;

end rtl;

