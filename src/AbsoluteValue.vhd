----------------------------------------------------------------------------------
-- Module Name:    	AbsoluteValue
-- Project Name: 		32 bit floating point adder
-- Description: 		Absolute value of a n-bit value
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity AbsoluteValue is
	generic (
		n 	: integer												-- Data size
	);
	port (
		x	: 	in 	std_logic_vector(0 to n-1);			-- Input data
		y	: 	out	std_logic_vector(0 to n-2)				-- Output data
	);
end AbsoluteValue;

architecture Behavioral of AbsoluteValue is

	component TwoComplement
		generic (
			n	:	integer
		);
		port (
			x	: 	in 	std_logic_vector(0 to n-1);
			y	: 	out	std_logic_vector(0 to n-1)
		);
	end component;
	
	signal x_c2 : std_logic_vector(0 to n-2);

begin

	two_complement: TwoComplement
		generic map (
			n => n-1
		)
		port map (
         x => x(1 to n-1),
			y => x_c2
		);
	
	y <= 	x_c2 when x(0) = '1'
			else x(1 to n-1);
	
end Behavioral;