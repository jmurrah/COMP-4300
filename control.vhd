-- Jacob Murrah COMP-4300 Lab 4
use work.bv_arithmetic.all;
use work.dlx_types.all;

entity aubie_controller is
    generic (
        prop_delay : time := 15 ns
    );
    port (
        ir_control           : in  dlx_word;
        alu_out              : in  dlx_word;
        alu_error            : in  error_code;
        clock                : in  bit;
        regfilein_mux        : out threeway_muxcode;
        memaddr_mux          : out threeway_muxcode;
        addr_mux             : out bit;
        pc_mux               : out bit;
        alu_func             : out alu_operation_code;
        regfile_index        : out register_index;
        regfile_readnotwrite : out bit;
        regfile_clk          : out bit;
        mem_clk              : out bit;
        mem_readnotwrite     : out bit;
        ir_clk               : out bit;
        imm_clk              : out bit;
        addr_clk             : out bit;
        pc_clk               : out bit;
        op1_clk              : out bit;
        op2_clk              : out bit;
        result_clk           : out bit
    );
end aubie_controller;

architecture behavior of aubie_controller is
begin
    behav : process(clock)
        type state_type is range 1 to 20;
        variable state       : state_type := 1;
        variable opcode      : byte;
        variable destination : register_index;
        variable operand1    : register_index;
        variable operand2    : register_index;
    begin
        if clock'event and clock = '1' then
            -- Decode instruction fields from the IR
            opcode      := ir_control(31 downto 24);
            destination := ir_control(23 downto 19);
            operand1    := ir_control(18 downto 14);
            operand2    := ir_control(13 downto 9);

            case state is
                when 1 =>
                    -- State 1: Mem[PC] -> InstrReg; go to state 2.
                    memaddr_mux <= "00" after prop_delay;
                    mem_readnotwrite <= '1' after prop_delay;

                    mem_clk <= '1' after prop_delay;
                    ir_clk <= '1' after prop_delay;

                    state := 2;

                when 2 =>
                    -- State 2: Decide instruction
                    if opcode(7 downto 4) = "0000" then -- ALU op; go to state 3.
                        state := 3;
                    elsif opcode = X"20" then -- STO; go to state 9.
                        state := 9;
                    elsif opcode = X"30" or opcode = X"31" then -- LD or LDI; go to state 7.
                        state := 7;
                    elsif opcode = X"22" then -- STOR; go to state 14.
                        state := 14;
                    elsif opcode = X"32" then -- LDR; go to state 12.
                        state := 12;
                    elsif opcode = X"40" or opcode = X"41" then -- JMP or JZ; go to state 16.
                        state := 16;
                    elsif opcode = X"10" then -- NOOP; go to state 19.
                        state := 19;
                    else -- error handling
                        null;
                    end if;

                when 3 =>
                    -- State 3: Regs[IR[op1]] -> Op1; go to state 4.
                    regfile_index <= operand1 after prop_delay;
                    regfile_readnotwrite <= '1' after prop_delay;

                    regfile_clk <= '1' after prop_delay;
                    op1_clk <= '1' after prop_delay;

                    state := 4;

                when 4 =>
                    -- State 4: Regs[IR[op2]] -> Op2; go to state 5.
                    regfile_index <= operand2 after prop_delay;
                    regfile_readnotwrite <= '1' after prop_delay;

                    regfile_clk <= '1' after prop_delay;
                    op2_clk <= '1' after prop_delay;

                    state := 5;

                when 5 =>
                    -- State 5: ALUout -> Result; go to state 6.
		    alu_func <= opcode(3 downto 0) after prop_delay;
                    result_clk <= '1' after prop_delay;

                    state := 6;

                when 6 =>
                    -- State 6: Result -> Regs[IR[dest]], PC+1 -> PC; go to state 1.
                    regfilein_mux <= "00" after prop_delay;
                    regfile_index <= destination after prop_delay;
                    regfile_readnotwrite <= '0' after prop_delay;
                    pc_mux <= '0' after prop_delay;

                    regfile_clk <= '1' after prop_delay;
                    pc_clk <= '1' after prop_delay;

                    state := 1;

                when 7 =>
                    -- State 7: (LD/LDI) PC+1 -> PC; load Mem[PC] -> Addr/Immed; go to state 8.
                    pc_mux <= '0' after prop_delay;
                    pc_clk <= '1' after prop_delay;

                    memaddr_mux <= "00" after prop_delay;
                    mem_readnotwrite <= '1' after prop_delay;

                    if opcode = x"30" then -- LD
                        addr_mux <= '1' after prop_delay;
                        mem_clk <= '1' after prop_delay;
                        addr_clk <= '1' after prop_delay;
                    else -- LDI
                        mem_clk <= '1' after prop_delay;
                        imm_clk <= '1' after prop_delay;
                    end if;

                    state := 8;

                when 8 =>
                    -- State 8: (LD/LDI) Addr/Immed -> Regs[IR[dest]], PC+1 -> PC; go to state 1.
                    if opcode = x"30" then -- LD
                        memaddr_mux <= "01" after prop_delay;
                        mem_readnotwrite <= '1' after prop_delay;
                        regfilein_mux <= "01" after prop_delay;
                        mem_clk <= '1' after prop_delay;
                    else -- LDI
                        regfilein_mux <= "10" after prop_delay;
                        imm_clk <= '1' after prop_delay;
                    end if;

                    regfile_index <= destination after prop_delay;
                    regfile_readnotwrite <= '0' after prop_delay;

                    regfile_clk <= '1' after prop_delay * 3;

                    pc_mux <= '0' after prop_delay * 3;
                    pc_clk <= '0' after prop_delay, '1' after prop_delay * 3;

                    state := 1;

                when 9 =>
                    -- STO: PC+1 -> PC; go to state 10.
                    pc_mux <= '0' after prop_delay;
                    pc_clk <= '1' after prop_delay;

                    state := 10;

                when 10 =>
                    -- STO: Mem[PC] -> Addr; go to state 11.
                    memaddr_mux <= "00" after prop_delay;
                    mem_readnotwrite <= '1' after prop_delay;
                    addr_mux <= '1' after prop_delay;

                    mem_clk <= '1' after prop_delay;
                    addr_clk <= '1' after prop_delay;

                    state := 11;

                when 11 =>
                    -- STO: Regs[IR[src]] -> Mem[Addr], PC+1 -> PC; go to state 1.
                    memaddr_mux <= "00" after prop_delay;
                    regfile_index <= operand1 after prop_delay;
                    regfile_readnotwrite <= '1' after prop_delay;
                    regfile_clk <= '1' after prop_delay;
                    
                    mem_readnotwrite <= '0' after prop_delay;
                    mem_clk <= '1' after prop_delay;

                    pc_mux <= '0' after prop_delay;
                    pc_clk <= '1' after prop_delay;

                    state := 1;

                when 12 =>
                    -- LDR: Regs[IR[op1]] -> Addr; go to state 13.
                    addr_mux <= '0' after prop_delay;
                    regfile_index <= operand1 after prop_delay;
                    regfile_readnotwrite <= '1' after prop_delay;

                    regfile_clk <= '1' after prop_delay;
                    addr_clk <= '1' after prop_delay;

                    state := 13;

                when 13 =>
                    -- LDR: Mem[Addr] -> Regs[IR[dest]], PC+1 -> PC; go to state 1.
                    memaddr_mux <= "01" after prop_delay;
                    mem_readnotwrite <= '1' after prop_delay;
                    regfilein_mux <= "01" after prop_delay;
                    regfile_index <= destination after prop_delay;
                    regfile_readnotwrite <= '0' after prop_delay;

                    mem_clk <= '1' after prop_delay;
                    regfile_clk <= '1' after prop_delay;

                    pc_mux <= '0' after prop_delay;
                    pc_clk <= '1' after prop_delay;

                    state := 1;

                when 14 =>
                    -- STOR: Regs[IR[dest]] -> Addr; go to state 15.
                    regfile_index <= destination after prop_delay;
                    regfile_readnotwrite <= '1' after prop_delay;
		    addr_mux <= '0' after prop_delay;

                    regfile_clk <= '1' after prop_delay;
                    addr_clk <= '1' after prop_delay;

                    state := 15;

                when 15 =>
                    -- STOR: Regs[IR[op1]] -> Mem[Addr], PC+1 -> PC; go to state 1.
                    regfile_index <= operand1 after prop_delay;
                    regfile_readnotwrite <= '1' after prop_delay;
                    memaddr_mux <= "01" after prop_delay;
                    mem_readnotwrite <= '0' after prop_delay;

                    regfile_clk <= '1' after prop_delay;
                    mem_clk <= '1' after prop_delay;

                    pc_mux <= '0' after prop_delay;
                    pc_clk <= '1' after prop_delay;

                    state := 1;

                when 16 =>
                    -- JMP/JZ: PC+1 -> PC; go to state 17.
                    pc_mux <= '0' after prop_delay;
                    pc_clk <= '1' after prop_delay;

                    state := 17;

                when 17 =>
                    -- JMP/JZ: Mem[PC] -> Addr; for JZ also read Regs[IR[op1]] to check if zero
                    memaddr_mux <= "00" after prop_delay;
                    mem_readnotwrite <= '1' after prop_delay;
                    addr_mux <= '1' after prop_delay;

                    mem_clk <= '1' after prop_delay;
                    addr_clk <= '1' after prop_delay;

                    if opcode = x"41" then -- JZ
                        regfile_index <= operand1 after prop_delay;
                        regfile_readnotwrite <= '1' after prop_delay;
                        regfile_clk <= '1' after prop_delay;

                        op1_clk <= '1' after prop_delay;
                        op2_clk <= '1' after prop_delay;
                        
                        alu_func <= "0111" after prop_delay;
                        result_clk <= '1' after prop_delay;
                    end if;

                    state := 18;

                when 18 =>
                    -- JMP/JZ: For JMP, Addr -> PC; for JZ, if alu_out = 0 then Addr -> PC else PC+1; go to state 1.
                    if (opcode = x"40") or (opcode = x"41" and alu_out = x"00000000") then
                        pc_mux <= '1' after prop_delay;
                    else
                        pc_mux <= '0' after prop_delay;
                    end if;

                    pc_clk <= '1' after prop_delay;

                    state := 1;

                when 19 =>
                    -- NOOP: PC+1 -> PC; go to state 1.
                    pc_mux <= '0' after prop_delay;
                    pc_clk <= '1' after prop_delay;

                    state := 1;

                when others =>
                    null;

            end case;
        elsif clock'event and clock = '0' then
            -- Reset all the register clocks
            regfile_clk <= '0' after prop_delay;
            mem_clk <= '0' after prop_delay;
            ir_clk <= '0' after prop_delay;
            imm_clk <= '0' after prop_delay;
            addr_clk <= '0' after prop_delay;
            pc_clk <= '0' after prop_delay;
            op1_clk <= '0' after prop_delay;
            op2_clk <= '0' after prop_delay;
            result_clk <= '0' after prop_delay;
        end if;
    end process behav;
end behavior;

