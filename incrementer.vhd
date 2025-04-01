-- Jacob Murrah COMP-4300 Lab 3
use work.dlx_types.all;
use work.bv_arithmetic.all;

entity pcplusone is
    generic (
	prop_delay: Time := 5 ns
    );
    port (
	input: in dlx_word; 
	clock: in bit; 
	output: out dlx_word
    );
end entity pcplusone;

architecture behavioral of pcplusone is
    constant ZEROS : dlx_word := (others => '0');
begin
    pcPlusOneProcess : process(input, clock) is
	variable bv_result : dlx_word;
        variable ov_flag   : boolean;
    begin
	if rising_edge(clock) then
	    bv_addu(input, integer_to_bv(1, 32), bv_result, ov_flag); 
	    if ov_flag then
		output <= ZEROS after prop_delay;
	    else
		output <= bv_result after prop_delay;
	    end if;
	end if;
    end process pcPlusOneProcess;
end architecture behavioral;

