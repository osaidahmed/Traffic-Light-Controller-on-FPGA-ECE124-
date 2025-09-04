-- NAMES: Moatasem Nada, Omar Saidahmed
-- Session: 202
-- Group: 6

library ieee;
use ieee.std_logic_1164.all;

--=============================================================================
-- ENTITY DECLARATION
-- Defines the interface for the synchronizer module.
--=============================================================================
entity synchronizer is
    port (
        clk   : in  std_logic; -- System clock (global 50MHz clock)
        reset : in  std_logic; -- Synchronous reset input
        din   : in  std_logic; -- Asynchronous input signal to be synchronized
        dout  : out std_logic  -- Synchronized output signal
    );
end synchronizer;

--=============================================================================
-- ARCHITECTURE
-- Describes the internal behavior of the synchronizer.
--=============================================================================
architecture circuit of synchronizer is
    -- Internal signal representing a 2-stage shift register to pass the signal
    -- through two clock cycles, reducing the chance of metastability.
    signal sreg : std_logic_vector(1 downto 0);
begin

    --=================================================
    -- PROCESS: Sequential Logic
    -- This process triggers on the rising edge of the clock to capture the input signal.
    --=================================================
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                -- Clear both stages of the shift register on reset
                sreg <= "00";
            else
                -- Shift operation:
                -- Stage 0 takes in the asynchronous din
                sreg(0) <= din;
                -- Stage 1 takes the value from Stage 0
                sreg(1) <= sreg(0);
            end if;
        end if;
    end process;

    -- Output the value of the second stage, which is now a stable, synchronized signal
    dout <= sreg(1);

end architecture;
