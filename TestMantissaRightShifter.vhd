--------------------------------------------------------------------------------
-- Module Name:   TestMantissaRightShifter
-- Project Name:  FloatingPointAdder32
-- Description:   VHDL test bench for module MantissaRightShifter
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity TestMantissaRightShifter is
end TestMantissaRightShifter;
 
architecture behavior of TestMantissaRightShifter is 
	 
    COMPONENT MantissaRightShifter
    PORT(
         x : IN  std_logic_vector(0 to 22);
         pos : IN  std_logic_vector(0 to 4);
         y : OUT  std_logic_vector(0 to 22)
        );
    END COMPONENT;
    
   -- Inputs
   signal x : std_logic_vector(0 to 22) := (others => '0');
   signal pos : std_logic_vector(0 to 4) := (others => '0');

 	-- Outputs
   signal y : std_logic_vector(0 to 22);

begin
   uut: MantissaRightShifter PORT MAP (
          x => x,
          pos => pos,
          y => y
        );

   stim_proc: process
   begin
		x <= "01010100010111101010010";
		
		pos <= "00000";
		wait for 100 ns;
		
		pos <= "00001";
		wait for 100 ns;
		
		pos <= "00101";
		wait for 100 ns;
		
		pos <= "10101";
		wait for 100 ns;
		
		pos <= "10110";
      wait;
   end process;

end;