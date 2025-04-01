-- Jacob Murrah COMP-4300 Lab 3
use work.dlx_types.all;
use work.bv_arithmetic.all;

entity threeway_mux is
    generic (
	prop_delay : Time := 5 ns
    );
    port (
	input_2, input_1, input_0 : in dlx_word; 
	which: in threeway_muxcode; 
	output: out dlx_word
    );
end entity threeway_mux;

architecture behavioral of threeway_mux is
begin
    threewayMuxProcess : process(input_2, input_1, input_0, which) is
    begin
	if which = "10" then
	    output <= input_2 after prop_delay;
	elsif which = "01" then
	    output <= input_1 after prop_delay;
	elsif which = "00" then
	    output <= input_0 after prop_delay;
	end if;
    end process threewayMuxProcess;
end architecture behavioral;

