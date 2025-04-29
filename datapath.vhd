-- Jacob Murrah COMP-4300 Lab 4
-- datapath_aubie.vhd

-- Jacob Murrah COMP-4300 Lab 2
-- alu_operation_code values
-- 0000 unsigned add
-- 0001 unsigned sub 
-- 0010 2's compl add
-- 0011 2's compl sub
-- 0100 2's compl mul
-- 0101 2's compl divide
-- 0110 logical and
-- 0111 bitwise and
-- 1000 logical or
-- 1001 bitwise or
-- 1010 logical not (op1) 
-- 1011 bitwise not (op1)
-- 1100-1111 output all zeros

-- error code values
-- 0000 = no error
-- 0001 = overflow/underflow 
-- 0010 = divide by zero
use work.dlx_types.all;
use work.bv_arithmetic.all;

entity alu is
    generic (
        prop_delay : time := 15 ns
    );
    port (
        operand1, operand2 : in  dlx_word;
        operation        : in  alu_operation_code;
        result           : out dlx_word;
        error            : out error_code
    );
end entity alu;

architecture behavior of alu is
    constant ZEROS : dlx_word := (others => '0');
    constant ONES  : dlx_word := (others => '1');
    signal ov_flag_signal   : boolean;
    signal div_zero_signal  : boolean;
begin
    aluProcess : process(operand1, operand2, operation) is
        variable bv_result : dlx_word;
        variable ov_flag   : boolean;
        variable div_zero  : boolean;
    begin
        div_zero_signal <= false;
        case operation is
            when "0000" => -- unsigned add
                bv_addu(operand1, operand2, bv_result, ov_flag);
                result <= bv_result after prop_delay;
                if ov_flag then
                    error <= "0001" after prop_delay;
                else
                    error <= "0000" after prop_delay;
                end if;
            when "0001" => -- unsigned subtract
                bv_subu(operand1, operand2, bv_result, ov_flag);
                result <= bv_result after prop_delay;
                if ov_flag then
                    error <= "0001" after prop_delay;
                else
                    error <= "0000" after prop_delay;
                end if;
            when "0010" => -- two's comp add
                bv_add(operand1, operand2, bv_result, ov_flag);
                result <= bv_result after prop_delay;
                if ov_flag then
                    error <= "0001" after prop_delay;
                else
                    error <= "0000" after prop_delay;
                end if;
            when "0011" => -- two's comp subtract
                bv_sub(operand1, operand2, bv_result, ov_flag);
                result <= bv_result after prop_delay;
                if ov_flag then
                    error <= "0001" after prop_delay;
                else
                    error <= "0000" after prop_delay;
                end if;
            when "0100" => -- two's comp multiply
                bv_mult(operand1, operand2, bv_result, ov_flag);
                result <= bv_result after prop_delay;
                if ov_flag then
                    error <= "0001" after prop_delay;
                else
                    error <= "0000" after prop_delay;
                end if;
            when "0101" => -- two's comp divide
                bv_div(operand1, operand2, bv_result, div_zero, ov_flag);
                result <= bv_result after prop_delay;
                if (div_zero = true) then
                    error <= "0010" after prop_delay;
                    div_zero_signal <= div_zero;
                elsif (ov_flag = true) then
                    error <= "0001" after prop_delay;
                else
                    error <= "0000" after prop_delay;
                end if;
            when "0111" => -- bitwise and
                result <= operand1 and operand2 after prop_delay;
                error  <= "0000" after prop_delay;
            when "1001" => -- bitwise or
                result <= operand1 or operand2 after prop_delay;
                error  <= "0000" after prop_delay;
            when "1010" => -- logical not of operand1
                if operand1 = ZEROS then
                    result <= ONES after prop_delay;
                else
                    result <= ZEROS after prop_delay;
                end if;
                error  <= "0000" after prop_delay;
            when "1011" => -- bitwise not of operand1
                result <= not operand1 after prop_delay;
                error  <= "0000" after prop_delay;
            when "1100" => -- pass operand1
                result <= operand1 after prop_delay;
                error  <= "0000" after prop_delay;
            when "1101" => -- pass operand2
                result <= operand2 after prop_delay;
                error  <= "0000" after prop_delay;
            when "1110" => -- pass all zeros
                result <= ZEROS after prop_delay;
                error  <= "0000" after prop_delay;
            when "1111" => -- pass all ones
                result <= ONES after prop_delay;
                error  <= "0000" after prop_delay;
            when others =>
                result <= ZEROS after prop_delay;
                error  <= "0000" after prop_delay;
        end case;
        ov_flag_signal <= ov_flag;
    end process aluProcess;
end architecture behavior;


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

architecture behavior of dlx_register is
begin
    dlxRegisterProcess : process(in_val, clock) is
    begin
        if clock = '1' then
            out_val <= in_val after prop_delay;
        end if;
    end process dlxRegisterProcess;
end architecture behavior;


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

architecture behavior of pcplusone is
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
end architecture behavior;


-- Jacob Murrah COMP-4300 Lab 3
use work.dlx_types.all;
use work.bv_arithmetic.all;

entity mux is
    generic (
	prop_delay : Time := 5 ns
    );
    port (
	input_1, input_0 : in dlx_word; 
	which: in bit; 
	output: out dlx_word
    );
end entity mux;

architecture behavior of mux is
begin
    muxProcess : process(input_1, input_0, which) is
    begin
	if which = '1' then
	    output <= input_1 after prop_delay;
	else
	    output <= input_0 after prop_delay;
	end if;
    end process muxProcess;
end architecture behavior;


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

architecture behavior of threeway_mux is
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
end architecture behavior;


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


-- Jacob Murrah COMP-4300 Lab 4
use work.dlx_types.all;
use work.bv_arithmetic.all;

entity memory is
    port (
	address : in dlx_word;
	readnotwrite: in bit; 
	data_out : out dlx_word;
	data_in: in dlx_word; 
	clock: in bit
    ); 
end memory;

architecture behavior of memory is
begin
    mem_behav: process(address,clock) is
        -- note that there is storage only for the first 1k of the memory, to speed up the simulation
        type memtype is array (0 to 1024) of dlx_word;
        variable data_memory : memtype;
    begin
	data_memory(0) :=  X"30200000"; -- LD R4, 256
        data_memory(1) :=  X"00000100"; -- address 0x100

        data_memory(2) :=  X"30080000"; -- LD R1, 257
        data_memory(3) :=  X"00000101"; -- address 0x101

        data_memory(4) :=  X"30100000"; -- LD R2, 258
        data_memory(5) :=  X"00000102"; -- address 0x102

        data_memory(6) :=  "00000000000110000100010000000000"; -- ADDU R3, R1, R2

        data_memory(7) :=  "00100000000000001100000000000000"; -- STO R3, 0x103
        data_memory(8) :=  x"00000103"; -- address 0x103
        
        data_memory(9) :=  "00110001000000000000000000000000"; -- LDI R0, 0x104
        data_memory(10) := x"00000104"; -- 0x104

        data_memory(11) := "00100010000000001100000000000000"; -- STOR (R0), R3
        
        data_memory(12) := "00110010001010000000000000000000"; -- LDR R5, (R0)
        
        data_memory(13) := x"40000000"; -- JMP to 261
        data_memory(14) := x"00000105";

        data_memory(256) := "01010101000000001111111100000000"; -- 256
        data_memory(257) := "00000001000000010000000100000001"; -- 257
        data_memory(258) := "00010000000100000001000000010000"; -- 258
        
        data_memory(261) :=  x"00584400"; -- ADDU R11, R1, R2
        
        data_memory(262) := x"4101C000"; -- JZ R7, 267 If R7 == 0, GOTO Addr 267
        data_memory(263) := x"0000010B";

        data_memory(267) := x"00604400"; -- ADDU R12, R1, R2
        
        data_memory(268) := x"10000000"; -- NOOP

	if clock = '1' then
            if readnotwrite = '1' then
                -- do a read
                data_out <= data_memory(bv_to_natural(address)) after 5 ns;
            else
                -- do a write
                data_memory(bv_to_natural(address)) := data_in; 
            end if;
	end if;
    end process mem_behav; 
end behavior;


