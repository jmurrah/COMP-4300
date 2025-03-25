-- Jacob Murrah COMP-4300 Lab 2
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

architecture behavioral of alu is
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
                if operand2 = ZEROS then
                    result <= ZEROS after prop_delay;
                    error  <= "0010" after prop_delay;
                else
                    bv_div(operand1, operand2, bv_result, div_zero, ov_flag);
                    result <= bv_result after prop_delay;
                    if ov_flag then
                        error <= "0001" after prop_delay;
                    else
                        error <= "0000" after prop_delay;
                    end if;
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
        div_zero_signal <= div_zero;
    end process aluProcess;
end architecture behavioral;
