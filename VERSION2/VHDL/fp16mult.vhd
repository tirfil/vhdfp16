--###############################
--# Project Name : 
--# File         : 
--# Author       : Philippe THIRION <https://github.com/tirfil>
--# Description  : 
--# Modification History
--#
--###############################

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fp16mult is
	port(
		MCLK		: in	std_logic;
		nRST		: in	std_logic;
		IN1			: in	std_logic_vector(15 downto 0);
		IN2			: in	std_logic_vector(15 downto 0);
		OUT0		: out	std_logic_vector(15 downto 0);
		START		: in	std_logic;
		DONE		: out	std_logic
	);
end fp16mult;

architecture rtl of fp16mult is
constant mantissa : integer := 12;
type state_t is (S_IDLE,S_0,S_1,S_2);
signal state : state_t;
signal M1,M2 : unsigned(10 downto 0);
signal X1,X2 : unsigned(4 downto 0);
signal X3 : unsigned(5 downto 0);
signal S1,S2,S3	: std_logic;
signal MR : unsigned(21 downto 0);
signal zero : std_logic;
signal infinity : std_logic;


begin

	P_OTO: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			DONE <= '0';
			OUT0 <= (others=>'0');
			X3 <= (others=>'0');
			S3 <= '0';
			zero <= '0';
			infinity <= '0';
		elsif (MCLK'event and MCLK = '1') then
			if (state = S_IDLE) then
				DONE <= '0';
				OUT0 <= (others=>'0');
				X3 <= (others=>'0');
				S3 <= '0';
				zero <= '0';
				infinity <= '0';
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
				zero <= '0';	
				infinity <= '0';
				-- solve timing issue
				if ('0' & X1 & M1(9 downto 0) = x"0000") then
					zero <= '1';
				end if;	
				if ('0' & X2 & M2(9 downto 0) = x"0000") then
					zero <= '1';
				end if;	
				
				S3 <= S1 xor S2;
				MR <= M1 * M2;
				-- check boundary
				X3 <= ('0' & X1) + ('0' & X2);
				--X3 <= X1 + X2 - 14;
				state <= S_1;
			elsif ( state = S_1 ) then
				if (MR(21) = '1') then
					-- with carry
					--report "high";
					if (X3 > 44) then
						infinity <= '1';
					elsif (X3 > 14) then
						X3 <= X3 - 14;
					else
						zero <= '1';
					end if;
					state <= S_2;
				--elsif MR(21 downto 11) = "00000000000" then
					----S3 <= '0';
					--report "zero";
					--zero <= '1';
					--state <= S_2;
				else
					-- without carry
					--report "shift left";
					MR <= shift_left(MR,1);
					if (X3 > 45) then
						infinity <= '1';
					elsif (X3 > 15) then
						X3 <= X3 - 15;
					else
						zero <= '1';
					end if;
					state <= S_2;
				end if;
			elsif ( state = S_2 ) then
				if (infinity = '1') then
					OUT0 <= S3 & "11111" & "0000000000";
				elsif (zero = '1') then
					OUT0 <= (others=>'0');
				else
					OUT0 <= S3 & std_logic_vector(X3(4 downto 0)) & std_logic_vector(MR(20 downto 11));
				end if;
				DONE <= '1';
				state <= S_IDLE;
			end if;
		end if;
	end process P_OTO;

end rtl;

