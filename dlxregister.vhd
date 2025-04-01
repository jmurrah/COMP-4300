-- Jacob Murrah COMP-4300 Lab 3
use work.dlx_types.all;
use work.bv_arithmetic.all;

entity dlx_register is
    generic (
        prop_delay : time := 10 ns
    );
    port (
	in_val: in dlx_word; 
	clock: in bit; 
	out_val: out dlx_word
    );
end entity dlx_register;

architecture behavioral of dlx_register is
begin
    dlxRegisterProcess : process(in_val, clock) is
    begin
        if clock = '1' then
            out_val <= in_val after prop_delay;
        end if;
    end process dlxRegisterProcess;
end architecture behavioral;
