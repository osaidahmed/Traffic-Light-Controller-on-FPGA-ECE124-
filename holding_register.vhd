-- ... (Header with names, etc.)
library ieee;
use ieee.std_logic_1164.all;

entity holding_register is
    port (
        clk           : in  std_logic;  -- Clock Input
        reset         : in  std_logic;  -- Global reset signal, clears the register
        register_clr  : in  std_logic;  -- Signal from the state machine to clear the register
        din           : in  std_logic;  -- Input data from synchronizer
        dout          : out std_logic   -- Output of the holding register
    );
end holding_register;

architecture circuit of holding_register is
    signal sreg_signal : std_logic; -- Internal signal to hold register value
    signal d_signal    : std_logic; -- Intermediate signal to hold the next value for sreg_signal
begin

    -- Logic to determine next value of register:
    -- The register stays high if it's already high OR if a new input (din) becomes high.
    -- The register is cleared only when reset OR register_clr is active.
    d_signal <= (sreg_signal or din) and (not(reset or register_clr));

    -- System: process is triggered on rising edge of clock
    process(clk)
    begin
        if (rising_edge(clk)) then
            -- Load the next value into the internal register
            sreg_signal <= d_signal;
        end if;
    end process;
    
    -- Global output to reflect the new value
    dout <= d_signal;

end architecture;
