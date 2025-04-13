use work.bv_arithmetic.all;
use work.dlx_types.all;

entity aubie_controller is
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
                    state := 2;

                when 2 =>
                    -- State 2: Decide instruction
                    if opcode(7 downto 4) = "0000" then -- ALU op; go to state 3.
                        state := 3;
                    elsif opcode = X"20" then -- STO
                        null;
                    elsif opcode = X"30" or opcode = X"31" then -- LD or LDI; go to state 7.
                        state := 7;
                    elsif opcode = X"22" then -- STOR; go to state 9.
                        null;
                    elsif opcode = X"32" then -- LDR; go to state 12.
                        null;
                    elsif opcode = X"40" or opcode = X"41" then -- JMP or JZ; go to state 16.
                        null;
                    elsif opcode = X"10" then -- NOOP; go to state 19.
                        null;
                    else -- error handling
                        null;
                    end if;

                when 3 =>
                    -- State 3: Regs[IR[op1]] -> Op1; go to state 4.
                    state := 4;

                when 4 =>
                    -- State 4: Regs[IR[op2]] -> Op2; go to state 5.
                    state := 5;

                when 5 =>
                    -- State 5: ALUout -> Result; go to state 6.
                    state := 6;

                when 6 =>
                    -- State 6: Result -> Regs[IR[dest]], PC+1 -> PC; go to state 1.
                    state := 1;

                when 7 =>
                    -- State 7: (LD/LDI) PC+1 -> PC; load Mem[PC] -> Addr/Immed; go to state 8.
                    state := 8;

                when 8 =>
                    -- State 8: (LD/LDI) Addr/Immed -> Regs[IR[dest]], PC+1 -> PC; go to state 1.
                    state := 1;

                when 9 =>
                    -- STO: PC+1 -> PC; go to state 10.
                    state := 10;

                when 10 =>
                    -- STO: Mem[PC] -> Addr; go to state 11.
                    state := 11;

                when 11 =>
                    -- STO: Regs[IR[src]] -> Mem[Addr], PC+1 -> PC; go to state 1.
                    state := 1;

                when 12 =>
                    -- LDR: Regs[IR[op1]] -> Addr; go to state 13.
                    state := 13;

                when 13 =>
                    -- LDR: Mem[Addr] -> Regs[IR[dest]], PC+1 -> PC; go to state 1.
                    state := 1;

                when 14 =>
                    -- STOR: Regs[IR[dest]] -> Addr; go to state 15.
                    state := 15;

                when 15 =>
                    -- STOR: Regs[IR[op1]] -> Mem[Addr], PC+1 -> PC; go to state 1.
                    state := 1;

                when 16 =>
                    -- JMP/JZ: PC+1 -> PC; go to state 17.
                    state := 17;

                when 17 =>
                    -- JMP/JZ: Mem[PC] -> Addr, Regs[IR[op1]] -> Ctl (JZ only); go to state 18.
                    state := 18;

                when 18 =>
                    -- JMP/JZ: For JMP, Addr -> PC; for JZ, if Result = 0 then Addr -> PC else PC+1; go to state 1.
                    state := 1;

                when 19 =>
                    -- NOOP: PC+1 -> PC; go to state 1.
                    state := 1;

                when others =>
                    null;
            end case;

        elsif clock'event and clock = '0' then
            -- Reset all the register clocks
            null;
        end if;
    end process behav;
end behavior;

