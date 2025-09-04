-- NAMES: Moatasem Nada, Omar Saidahmed
-- Session: 202
-- Group: 6

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--=============================================================================
-- ENTITY DECLARATION -- Defines the inputs and outputs of the FSM
--=============================================================================
entity State_Machine is
    port (
        -- Inputs
        clk, input, reset, sm_clken, blink_sig, NS_Request, EW_Request : in  std_logic;
        sw_sync_out, NS_Out, EW_Out                                     : in  std_logic;
        
        -- Outputs
        NS_Green, NS_Amber, NS_Red, NS_Crossing, NS_Clear               : out std_logic;
        EW_Green, EW_Amber, EW_Red, EW_Crossing, EW_Clear               : out std_logic;
        fourbit                                                         : out std_logic_vector(3 downto 0) -- State display for LEDs
    );
end entity;

--=============================================================================
-- ARCHITECTURE -- Describes the behavior of the FSM using three processes
--=============================================================================
architecture Behaviour of State_Machine is

    -- Define all the possible states for the traffic light controller
    type state_names is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15);
    
    -- Signals to hold the state of the machine
    signal current_state, next_state : state_names;

begin

    --=================================================
    -- PROCESS 1: State Register (Clocked)
    -- Updates the current state on the rising edge of the clock.
    -- This process represents the memory of the FSM.
    --=================================================
    Register: process (clk)
    begin
        if (rising_edge(clk)) then
            if reset = '1' then
                current_state <= S0; -- Go to initial state on reset
            elsif sm_clken = '1' then
                current_state <= next_state; -- Advance to next state on clock enable
            end if;
        end if;
    end process;

    --=================================================
    -- PROCESS 2: Transition Logic (Combinatorial)
    -- Determines the next state based on the current state and inputs.
    --=================================================
    Transition: process (current_state, EW_Out, NS_Out, sw_sync_out)
    begin
        case current_state is
            when S0 =>
                if (EW_Out = '1' and NS_Out = '0') then next_state <= S6; else next_state <= S1; end if;
            when S1 =>
                if (EW_Out = '1' and NS_Out = '0') then next_state <= S6; else next_state <= S2; end if;
            when S2 => next_state <= S3;
            when S3 => next_state <= S4;
            when S4 => next_state <= S5;
            when S5 =>
                if (EW_Out = '0' and NS_Out = '1') then next_state <= S14; else next_state <= S6; end if;
            when S6 => next_state <= S7;
            when S7 => next_state <= S8;
            when S8 =>
                if (EW_Out = '0' and NS_Out = '1') then next_state <= S14; else next_state <= S9; end if;
            when S9 =>
                if (EW_Out = '0' and NS_Out = '1') then next_state <= S14; else next_state <= S10; end if;
            when S10 => next_state <= S11;
            when S11 => next_state <= S12;
            when S12 => next_state <= S13;
            when S13 =>
                if (sw_sync_out = '1') then next_state <= S14; else next_state <= S0; end if;
            when S14 => next_state <= S15;
            when S15 =>
                if (sw_sync_out = '1') then next_state <= S15; else next_state <= S0; end if;
        end case;
    end process;

    --=================================================
    -- PROCESS 3: Output Logic (Combinatorial)
    -- Determines the output values based only on the current state (Moore FSM).
    --=================================================
    Decoder_Section: process (current_state, blink_sig, sw_sync_out)
    begin
        -- Default assignments can prevent unintended latches, but a full case is better.
        case current_state is
            when S0 | S1 =>
                NS_Green <= blink_sig; NS_Amber <= '0'; NS_Red <= '0'; NS_Crossing <= '0'; NS_Clear <= '0';
                EW_Green <= '0';       EW_Amber <= '0'; EW_Red <= '1'; EW_Crossing <= '0'; EW_Clear <= '0';
            when S2 | S3 | S4 | S5 =>
                NS_Green <= '1'; NS_Amber <= '0'; NS_Red <= '0'; NS_Crossing <= '1'; NS_Clear <= '0';
                EW_Green <= '0'; EW_Amber <= '0'; EW_Red <= '1'; EW_Crossing <= '0'; EW_Clear <= '0';
            when S6 =>
                NS_Green <= '0'; NS_Amber <= '1'; NS_Red <= '0'; NS_Crossing <= '0'; NS_Clear <= '1';
                EW_Green <= '0'; EW_Amber <= '0'; EW_Red <= '1'; EW_Crossing <= '0'; EW_Clear <= '0';
            when S7 =>
                NS_Green <= '0'; NS_Amber <= '1'; NS_Red <= '0'; NS_Crossing <= '0'; NS_Clear <= '0';
                EW_Green <= '0'; EW_Amber <= '0'; EW_Red <= '1'; EW_Crossing <= '0'; EW_Clear <= '0';
            when S8 | S9 | S10 | S11 | S12 | S13 =>
                NS_Green <= '0'; NS_Amber <= '0'; NS_Red <= '1'; NS_Crossing <= '0'; NS_Clear <= '0';
                EW_Green <= blink_sig; EW_Amber <= '0'; EW_Red <= '0'; EW_Crossing <= '0'; EW_Clear <= '0';
            when S14 =>
                NS_Green <= '0'; NS_Amber <= '0'; NS_Red <= '1'; NS_Crossing <= '0'; NS_Clear <= '0';
                EW_Green <= '0'; EW_Amber <= '1'; EW_Red <= '0'; EW_Crossing <= '0'; EW_Clear <= '1';
            when S15 =>
                if sw_sync_out = '1' then -- Offline/maintenance mode
                    NS_Green <= '0'; NS_Amber <= '0'; NS_Red <= blink_sig; NS_Crossing <= '0'; NS_Clear <= '0';
                    EW_Green <= '0'; EW_Amber <= blink_sig; EW_Red <= '0'; EW_Crossing <= '0'; EW_Clear <= '0';
                else -- Transition state back to S0
                    NS_Green <= '0'; NS_Amber <= '0'; NS_Red <= '1'; NS_Crossing <= '0'; NS_Clear <= '0';
                    EW_Green <= '0'; EW_Amber <= '1'; EW_Red <= '0'; EW_Crossing <= '0'; EW_Clear <= '0';
                end if;
        end case;
        
        -- Output state number as 4-bit value for LED display
        case current_state is
            when S0 => fourbit <= "0000";
            when S1 => fourbit <= "0001";
            when S2 => fourbit <= "0010";
            when S3 => fourbit <= "0011";
            when S4 => fourbit <= "0100";
            when S5 => fourbit <= "0101";
            when S6 => fourbit <= "0110";
            when S7 => fourbit <= "0111";
            when S8 => fourbit <= "1000";
            when S9 => fourbit <= "1001";
            when S10 => fourbit <= "1010";
            when S11 => fourbit <= "1011";
            when S12 => fourbit <= "1100";
            when S13 => fourbit <= "1101";
            when S14 => fourbit <= "1110";
            when S15 => fourbit <= "1111";
        end case;
    end process;
end Behaviour;
