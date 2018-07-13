----------------------------------------------------------------------------------
-- Module Name:    	StageTwo
-- Project Name: 		32 bit floating point adder
-- Description: 		Stage two of the pipeline
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity StageTwo is
	port (
		CLK							:	in		std_logic;								-- Clock signal
		special_case_flag_in		:	in		std_logic;								-- Whether the operands leads to a special case
		special_case_result_in	:	in		std_logic_vector(31 downto 0);	-- Special case result
		operand_1_in				:	in		std_logic_vector(36 downto 0);	-- Operand with the lowest exponent
		operand_2_in				:	in		std_logic_vector(36 downto 0);	-- Operand with the highest exponent
		exp_difference_in			:	in		std_logic_vector(0 to 7);			-- Difference between operand A and operand B exponents
		exp_difference_abs_in	:	in		std_logic_vector(0 to 7);			-- Difference between the highest and the lowest exponent
		special_case_flag_out	:	out	std_logic;								-- special_case_flag
		special_case_result_out	:	out	std_logic_vector(31 downto 0);	-- special_case_result
		sum							:	out	std_logic_vector(36 downto 0);	-- Sum between the two operands
		overflow						:	out	std_logic;								--	Sum overflow
		
		-- Debug
		operand_1_out				:	out	std_logic_vector(36 downto 0);	-- operand_1_in
		operand_1_shifted			:	out	std_logic_vector(36 downto 0)		-- operand_1_in with shifted mantissa
	);
end StageTwo;

architecture Behavioral of StageTwo is
	
	constant registers_number : integer := 145;
	
	-- Operand with the lowest exponent
	alias sign_1_in is operand_1_in(36);
	alias exponent_1_in is operand_1_in(35 downto 28);
	alias mantissa_1_in is operand_1_in(27 downto 0);
	
	-- Temporary signals
	-- "_dff" is used to indicate the signal before entering the registers
	
	-- Operand with the lowest exponent
	signal operand_1_dff	:	std_logic_vector(36 downto 0);
	alias sign_1_dff is operand_1_dff(36);
	alias exponent_1_dff is operand_1_dff(35 downto 28);
	alias mantissa_1_dff is operand_1_dff(27 downto 0);
	
	-- Operand with the highest exponent
	signal operand_2_dff	:	std_logic_vector(36 downto 0);
	alias sign_2_dff is operand_2_dff(36);
	alias exponent_2_dff is operand_2_dff(35 downto 28);
	alias mantissa_2_dff is operand_2_dff(27 downto 0);
	
	-- Sum between the two operands
	signal sum_dff	:	std_logic_vector(36 downto 0);
	alias sign_sum_dff is sum_dff(36);
	alias exponent_sum_dff is sum_dff(35 downto 28);
	alias mantissa_sum_dff is sum_dff(27 downto 0);
	
	--	Sum overflow
	signal sum_overflow	:	std_logic;
	signal overflow_dff	:	std_logic;
	
	signal M1_M2_sum					:	std_logic_vector(27 downto 0);		-- M1 + M2
	signal M1_M2_difference			:	std_logic_vector(27 downto 0);		-- M1 - M2
	signal M1_M2_difference_sign	:	std_logic;									-- Sign of M1 - M2
	signal M2_M1_difference			:	std_logic_vector(27 downto 0);		-- M2 - M1
	
	-- Registers
	signal D, Q : std_logic_vector(0 to registers_number - 1);
	
	component RegisterN
		generic (
			n : integer
		);
		port (
			CLK	:	in		std_logic;
			D		: 	in 	std_logic_vector(0 to n-1);
			Q		: 	out	std_logic_vector(0 to n-1)
		);
	end component;
	
	-- Mantissa right shifter
	component MantissaRightShifter
		port (
			x				:	in 	std_logic_vector(27 downto 0);
			pos			:	in		std_logic_vector(4 downto 0);
			y				:	out	std_logic_vector(27 downto 0)
		);
	end component;
	
	-- Ripple carry adder
	component RippleCarryAdder
		generic (
			n : integer
		);
		port (
			x, y 		: in  	std_logic_vector(0 to n-1);
			s			: out		std_logic_vector(0 to n-1);
			overflow	: out		std_logic
		);
	end component;
	
	-- Ripple carry subtractor
	component RippleCarrySubtractor
		generic (
			n : integer
		);
		port (
			x, y 			: in  	std_logic_vector(0 to n-1);
			s				: out		std_logic_vector(0 to n-1);
			result_sign	: out		std_logic
		);
	end component;

begin

	-- Copy operand 2
	operand_2_dff <= operand_2_in;
	
	-- Copy sign and exponent of O1
	sign_1_dff 		<=	sign_1_in;
	exponent_1_dff <=	exponent_1_in;
	
	-- Mantissa right shifter
	mantissa_right_shifter: MantissaRightShifter
		port map (
			x 				=> mantissa_1_in,
			pos 			=> exp_difference_abs_in(3 to 7),
			y 				=> mantissa_1_dff
		);
	
	-- M1 - M2
	mantissa_sub_1: RippleCarrySubtractor
		generic map (
			n => 28
		)
		port map (
         x 				=> mantissa_1_dff,
			y 				=> mantissa_2_dff,
			s 				=> M1_M2_difference,
			result_sign	=>	M1_M2_difference_sign
		);
	
	-- M2 - M1
	mantissa_sub_2: RippleCarrySubtractor
		generic map (
			n => 28
		)
		port map (
         x => mantissa_2_dff,
			y => mantissa_1_dff,
			s => M2_M1_difference
		);
	
	-- Sign
	sign_sum_dff <= sign_2_dff when M1_M2_difference_sign = '1' else
						 sign_1_dff;
	
	-- Exponent
	exponent_sum_dff <= exponent_2_dff;
	
	-- Mantissa
	mantissa_sum: RippleCarryAdder
		generic map (
			n => 28
		)
		port map (
         x 				=> mantissa_1_dff,
			y 				=> mantissa_2_dff,
			s 				=> M1_M2_sum,
			overflow 	=> sum_overflow
		);
	
	mantissa_sum_dff <=	M1_M2_sum when sign_1_dff = sign_2_dff else
								M1_M2_difference when M1_M2_difference_sign = '0' else
								M2_M1_difference when M1_M2_difference_sign = '1' else
								(others => '-');
	overflow_dff	<=	'1'	when	(sum_overflow = '1' and sign_1_dff = sign_2_dff) else
							'0';
	
	-- Connect the registers
	registers: RegisterN
		generic map (
			n => registers_number
		)
		port map (
         CLK => CLK,
			D => D,
			Q => Q
		);
	
	D <= 	special_case_flag_in &
			special_case_result_in &
			sum_dff &
			overflow_dff &
			operand_1_in &
			operand_1_dff;
	
	special_case_flag_out <= Q(0);
	special_case_result_out <= Q(1 to 32);
	sum <= Q(33 to 69);
	overflow <= Q(70);
	operand_1_out <= Q(71 to 107);
	operand_1_shifted <= Q(108 to 144);
	
end Behavioral;