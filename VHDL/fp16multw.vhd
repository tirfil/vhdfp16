--###############################
--# Project Name : 
--# File         : 
--# Author       : Philippe THIRION <https://github.com/tirfil>
--# Description  : 
--# Modification History
--# Add MWAIT
--###############################

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fp16multw is
	port(
		MCLK		: in	std_logic;
		nRST		: in	std_logic;
		IN1			: in	std_logic_vector(15 downto 0);
		IN2			: in	std_logic_vector(15 downto 0);
		OUT0		: out	std_logic_vector(15 downto 0);
		START		: in	std_logic;
		DONE		: out	std_logic;
		MWAIT		: in	std_logic
	);
end fp16multw;

architecture rtl of fp16multw is
--constant mantissa : integer := 12;
type state_t is (S_IDLE,S_0,S_1,S_2);
signal state : state_t;
signal M1,M2,M3 : unsigned(10 downto 0);
signal X1,X2,X3 : unsigned(4 downto 0);
signal S1,S2,S3	: std_logic;
signal MR : unsigned(21 downto 0);
--signal i : integer range 0 to 15;

function to_left(vec : unsigned) return integer is
variable I : integer range 10 downto 0;
begin
	I := 0;
	while vec(vec'left - I)='0' and I/=vec'left-vec'right loop
		I:= I+1;
	end loop;
	return I;
end function;

begin

	P_OTO: process(MCLK, nRST)
	variable value : integer range 0 to 10;
	begin
		if (nRST = '0') then
			DONE <= '0';
			OUT0 <= (others=>'0');
			--M3 <= (others=>'0');
			X3 <= (others=>'0');
			S3 <= '0';
		elsif (MCLK'event and MCLK = '1') then
			if (state = S_IDLE) then
				DONE <= '0';
				OUT0 <= (others=>'0');
				--M3 <= (others=>'0');
				X3 <= (others=>'0');
				S3 <= '0';
				if (START='1') then
					state <= S_0;
					M1(9 downto 0) <= unsigned(IN1(9 downto 0));
					M1(10) <= '1';
					M2(9 downto 0) <= unsigned(IN2(9 downto 0));
					M2(10) <= '1';
					X1 <= unsigned(IN1(14 downto 10));
					X2 <= unsigned(IN2(14 downto 10));
					S1 <= IN1(15);
					S2 <= IN2(15);
				end if;
			elsif ( state = S_0 ) then
				S3 <= S1 xor S2;
				MR <= M1 * M2;
				X3 <= X1 + X2 - 14;
				--if (S1 = S2) then
					--X3 <= X1 + X2 - 14;
				--else
					--X3 <= X1 + X2 - 14;
				--end if;
				state <= S_1;
				--i <= 0;
			elsif ( state = S_1 ) then
				if (MR(21) = '1') then
					--M3 <= MR(21 downto 11);
					state <= S_2;
				elsif MR(21 downto 11) = "00000000000" then
					--M3 <= (others=>'0');
					S3 <= '0';
					state <= S_2;
				else
					value := to_left(MR(21 downto 11));
					MR <= shift_left(MR,value);
					X3 <= X3 - value;
					state <= S_2;
				--elsif (i = mantissa) then
					--M3 <= (others=>'0');
					--state <= S_2;
				--else
					----report "SHIFT";
					--MR <= shift_left(MR,1);
					--i <= i + 1;
					--X3 <= X3 - 1;
				end if;
			elsif ( state = S_2 ) then
				--OUT0 <= S3 & std_logic_vector(X3) & std_logic_vector(M3(9 downto 0));
				if (MWAIT = '0') then
					OUT0 <= S3 & std_logic_vector(X3) & std_logic_vector(MR(20 downto 11));
					DONE <= '1';
					state <= S_IDLE;
				end if;
			end if;
		end if;
	end process P_OTO;

end rtl;

