-- Jacob Murrah COMP-4300 Lab 3
use work.dlx_types.all;
use work.bv_arithmetic.all;

entity reg_file is
    generic (
        prop_delay : time := 15 ns
    );
    port (
	data_in : in dlx_word;
	readnotwrite, clock: in bit;
        reg_number : in register_index;
	data_out: out dlx_word
    );
end entity reg_file;

architecture behavior of reg_file is
    type reg_type is array (0 to 31) of dlx_word;
begin
    regFileProcess : process(data_in, readnotwrite, clock, reg_number) is
        variable registers : reg_type;
    begin
	if rising_edge(clock) then
            if readnotwrite = '1' then
                data_out <= registers(bv_to_integer(reg_number)) after prop_delay;
            else
                registers(bv_to_integer(reg_number)) := data_in;
            end if;
	end if;
    end process regFileProcess;
end architecture behavior;

