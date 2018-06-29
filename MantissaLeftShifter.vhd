----------------------------------------------------------------------------------
-- Module Name:    	MantissaLeftShifter
-- Project Name: 		32 bit floating point adder
-- Description: 		Left shift the mantissa up to 23 positions
------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity MantissaLeftShifter is
	port (
		x		:	in 	std_logic_vector(22 downto 0);	-- Original mantissa
		pos	:	in 	std_logic_vector(4 downto 0);		-- Shift amount
		y		:	out	std_logic_vector(22 downto 0)		-- Shifted mantissa
	);
end MantissaLeftShifter;

architecture Behavioral of MantissaLeftShifter is
	
	-- Generic s-positions left shifter of a n-bit value
	component LeftShifter
		generic (
			n : integer;
			s : integer
		);
		port (
			x 	: in  	std_logic_vector(n-1 downto 0);
			y	: out 	std_logic_vector(n-1 downto 0)
		);
	end component;

	type vector23 is array (natural range <>) of std_logic_vector(22 downto 0);
	signal shiftsVector : vector23(23 downto 0);
	
begin

	gen_shift:
	for i in 0 to 23 generate
		shifter: LeftShifter
			generic map (
				n => 23,
				s => i
			)
			port map (
				x => x(22 downto 0),
				y => shiftsVector(i)
			);
	end generate gen_shift;
	
	y <= 	shiftsVector(0) when pos = "00000" else
			shiftsVector(1) when pos = "00001" else
			shiftsVector(2) when pos = "00010" else
			shiftsVector(3) when pos = "00011" else
			shiftsVector(4) when pos = "00100" else
			shiftsVector(5) when pos = "00101" else
			shiftsVector(6) when pos = "00110" else
			shiftsVector(7) when pos = "00111" else
			shiftsVector(8) when pos = "01000" else
			shiftsVector(9) when pos = "01001" else
			shiftsVector(10) when pos = "01010" else
			shiftsVector(11) when pos = "01011" else
			shiftsVector(12) when pos = "01100" else
			shiftsVector(13) when pos = "01101" else
			shiftsVector(14) when pos = "01110" else
			shiftsVector(15) when pos = "01111" else
			shiftsVector(16) when pos = "10000" else
			shiftsVector(17) when pos = "10001" else
			shiftsVector(18) when pos = "10010" else
			shiftsVector(19) when pos = "10011" else
			shiftsVector(20) when pos = "10100" else
			shiftsVector(21) when pos = "10101" else
			shiftsVector(22) when pos = "10110" else
			shiftsVector(23);

end Behavioral;
