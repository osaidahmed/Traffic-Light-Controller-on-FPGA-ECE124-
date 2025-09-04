-- ... (Header with names, etc.)
library ieee;
use ieee.std_logic_1164.all;

-- Define the entity for PB_inverters, which inverts the active-low reset and pushbuttons
entity PB_inverters is
    port (
        rst_n         : in  std_logic;                    -- Active-low reset input
        rst           : out std_logic;                    -- Active-high reset output (inverted rst_n)
        pb_n_filtered : in  std_logic_vector(3 downto 0); -- Active-low pushbuttons (filtered)
        pb            : out std_logic_vector(3 downto 0)  -- Active-high pushbuttons (inverted pb_n_filtered)
    );
end PB_inverters;

-- Behavior of the PB_inverters entity
architecture ckt of PB_inverters is
begin
    rst <= not(rst_n); -- Invert the active-low reset signal to produce an active-high reset
    pb  <= not(pb_n_filtered); -- Invert each of the 4 pushbutton inputs to convert them from active-low to active high
end ckt;
