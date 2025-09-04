-- Placeholder for pushbutton debounce filter logic
library ieee;
use ieee.std_logic_1164.all;

entity pb_filters is
    port (
        clkin          : in  std_logic;
        rst_n          : in  std_logic;
        rst_n_filtered : out std_logic;
        pb_n           : in  std_logic_vector(3 downto 0);
        pb_n_filtered  : out std_logic_vector(3 downto 0)
    );
end entity;

architecture Behaviour of pb_filters is
begin
    -- Debouncing logic (e.g., using a counter) would go here.
    -- For now, we can pass the signal through directly for initial compilation.
    rst_n_filtered <= rst_n;
    pb_n_filtered  <= pb_n;
end Behaviour;
