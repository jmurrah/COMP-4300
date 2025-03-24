-- Jacob Murrah COMP-4300 Lab 2
entity alu is
    generic (prop_delay : time := 15 ns);
    port (
        operand1, operand2: in dlx_word;
        operation: in alu_operation_code;
        result: out dlx_word;
        error: out error_code
    );
end entity alu;

architecture behavioral of alu is
begin
    aluProcess : process(operand1, operand2, operation) is
    begin
        case operation is
            when "0000" => -- unsigned add
                result <= bv_addu(operand1, operand2) after prop_delay;
                error  <= "0000" after prop_delay;
            when "0001" => -- unsigned subtract
                result <= bv_subu(operand1, operand2) after prop_delay;
                error  <= "0000" after prop_delay;
            when "0010" => -- two's comp add
                result <= bv_add(operand1, operand2) after prop_delay;
                error  <= "0000" after prop_delay;
            when "0011" => -- two's comp subtract
                result <= bv_sub(operand1, operand2) after prop_delay;
                error  <= "0000" after prop_delay;
            when "0100" => -- two's comp multiply
                result <= bv_mult(operand1, operand2) after prop_delay;
                error  <= "0000" after prop_delay;
            when "0101" => -- two's comp divide
                if operand2 = (others => '0') then
                    result <= (others => '0') after prop_delay;
                    error  <= "0010" after prop_delay;  -- divide by zero error
                else
                    result <= bv_div(operand1, operand2) after prop_delay;
                    error  <= "0000" after prop_delay;
                end if;
            when "0111" => -- bitwise and
                result <= operand1 and operand2 after prop_delay;
                error  <= "0000" after prop_delay;
            when "1001" => -- bitwise or
                result <= operand1 or operand2 after prop_delay;
                error  <= "0000" after prop_delay;
            when "1010" => -- logical not of operand1
                if operand1 = (zeros => '0') then
                    result <= (ones => '1') after prop_delay;
                else
                    result <= (zeros => '0') after prop_delay;
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
                result <= (zeros => '0') after prop_delay;
                error  <= "0000" after prop_delay;
            when "1111" => -- pass all ones
                result <= (ones => '1') after prop_delay;
                error  <= "0000" after prop_delay;
        end case;
    end process aluProcess;
end architecture behavioral;
