-- Jacob Murrah COMP-4300 Lab 1
entity twobitdecoder is
    generic (prop_delay : time := 10 ns);
    port (
        encoded : in  bit_vector(1 downto 0);
        out0    : out bit;
        out1    : out bit;
        out2    : out bit;
        out3    : out bit
    );
end twobitdecoder;

architecture behavioral of twobitdecoder is
begin
    decoderProcess : process(encoded) is
    begin
        out0 <= '0';
        out1 <= '0';
        out2 <= '0';
        out3 <= '0';
        if encoded = "00" then
            out0 <= '1' after prop_delay;
        end if;
        if encoded = "01" then
            out1 <= '1' after prop_delay;
        end if;
        if encoded = "10" then
            out2 <= '1' after prop_delay;
        end if;
        if encoded = "11" then
            out3 <= '1' after prop_delay;
        end if;
    end process decoderProcess;
end architecture behavioral;
