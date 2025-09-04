-- NAMES: Moatasem Nada, Omar Saidahmed
-- Session: 202
-- Group: 6

--=============================================================================
-- LIBRARIES
--=============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--=============================================================================
-- ENTITY DECLARATION -- Top-level of the design
--=============================================================================
ENTITY LogicalStep_Lab4_top IS
    PORT (
        -- INPUTS
        clkin_50      : in  std_logic;                             -- 50 MHz FPGA Clockinput
        rst_n         : in  std_logic;                             -- The RESET input (ACTIVE LOW)
        pb_n          : in  std_logic_vector(3 downto 0);          -- The push-button inputs (ACTIVE LOW)
        sw            : in  std_logic_vector(7 downto 0);          -- The switch inputs

        -- OUTPUTS
        leds          : out std_logic_vector(7 downto 0);          -- For displaying the lab4 project details
        seg7_data     : out std_logic_vector(6 downto 0);          -- 7-bit outputs to a 7-segment
        seg7_char1    : out std_logic;                             -- seg7 digit selectors
        seg7_char2    : out std_logic;                             -- seg7 digit selectors

        -- Simulation outputs for observing internal signals
        sim_sm_clken, sim_blink_sig, NS_d, NS_g, NS_a, EW_d, EW_g, EW_a, STATE : out std_logic -- simulation outputs
    );
END LogicalStep_Lab4_top;

--=============================================================================
-- ARCHITECTURE -- Structural description connecting all components
--=============================================================================
ARCHITECTURE SimpleCircuit OF LogicalStep_Lab4_top IS

    --=================================================
    -- Component Declarations
    -- These are the "blueprints" for the sub-modules used in this file.
    --=================================================

    -- Multiplexer for driving the two 7-segment displays
    component segment7_mux port ( ... ); -- VHDL for this component is not yet provided
    end component;

    -- Clock generator provides sm_clken (1Hz enable) and blink_sig (flash control)
    component clock_generator port ( ... ); -- VHDL for this component is not yet provided
    end component;

    -- Pushbutton filter (debounce logic)
    component pb_filters port (
        clkin         : in  std_logic;                             -- Clock input
        rst_n         : in  std_logic;                             -- Active-low reset
        rst_n_filtered: out std_logic;                             -- Debounced reset
        pb_n          : in  std_logic_vector(3 downto 0);          -- Raw pushbuttons
        pb_n_filtered : out std_logic_vector(3 downto 0)           -- Debounced pushbuttons
    );
    end component;

    -- Inverter for reset and pushbutton signals (converts active-low to active-high)
    component pb_inverters port (
        rst_n         : in  std_logic;                             -- Active-low reset input
        rst           : out std_logic;                             -- Active-high reset output
        pb_n_filtered : in  std_logic_vector(3 downto 0);          -- Filtered pushbuttons
        pb            : out std_logic_vector(3 downto 0)           -- Inverted (active-high) pushbuttons
    );
    end component;

    -- Synchronizer component to bring async signals into sync with 50MHz clock
    component synchronizer port (
        clk           : in  std_logic;                             -- Clock input
        reset         : in  std_logic;                             -- Reset input
        din           : in  std_logic;                             -- Asynchronous input to be synchronized
        dout          : out std_logic                              -- Synchronized output
    );
    end component;

    -- Holding register to latch synchronized pedestrian requests until state machine clears them
    component holding_register port (
        clk           : in  std_logic;                             -- Clock input
        reset         : in  std_logic;                             -- Reset input
        register_clr  : in  std_logic;                             -- Clear signal from state machine
        din           : in  std_logic;                             -- Input from synchronizer
        dout          : out std_logic                              -- Output held until cleared
    );
    end component;

    -- Traffic light controller state machine
    component State_Machine port (
        clk, input, reset, sm_clken, blink_sig, NS_Request, EW_Request : in std_logic;
        NS_Green, NS_Amber, NS_Red                                     : out std_logic;
        NS_Crossing                                                    : out std_logic;
        NS_Clear                                                       : out std_logic;
        EW_Green, EW_Amber, EW_Red, EW_Crossing, EW_Clear               : out std_logic;
        fourbit                                                        : out std_logic_vector(3 downto 0);
        sw_sync_out                                                    : in std_logic;
        NS_Out, EW_Out                                                 : in std_logic
    );
    end component;

    --=================================================
    -- Signal Declarations
    -- These are the "wires" that connect the components together.
    --=================================================
    CONSTANT sim_mode : boolean := FALSE; -- Set to FALSE for board downloads, TRUE for SIMULATIONS

    -- Reset and filter signals
    SIGNAL rst, rst_n_filtered, synch_rst                 : std_logic;
    SIGNAL sm_clken, blink_sig                             : std_logic;
    SIGNAL pb_n_filtered, pb                               : std_logic_vector(3 downto 0);

    -- Pedestrian control and register outputs
    SIGNAL holding_register_out0, sync_out0                : std_logic;
    SIGNAL holding_register_out1, sync_out1                : std_logic;

    -- State machine signal connections
    SIGNAL NS_Request                                      : std_logic;
    SIGNAL NS_Green, NS_Amber, NS_Red                      : std_logic;
    SIGNAL NS_Crossing                                     : std_logic;
    SIGNAL NS_Clear                                        : std_logic;
    SIGNAL EW_Request                                      : std_logic;
    SIGNAL EW_Green, EW_Amber, EW_Red, EW_Crossing, EW_Clear : std_logic;
    SIGNAL NS_Out, EW_Out                                  : std_logic;
    SIGNAL sw_sync_out                                     : std_logic;

BEGIN
    --=================================================
    -- Component Instantiations
    -- This section connects all the declared components using the signals.
    --=================================================

    -- Debounce and invert pushbuttons and reset signals
    INST0: pb_filters   port map (clkin_50, rst_n, rst_n_filtered, pb_n, pb_n_filtered);
    INST1: pb_inverters port map (rst_n_filtered, rst, pb_n_filtered, pb);

    -- Synchronize reset to common clock (used to prevent metastability)
    INST2: synchronizer port map (clkin_50, '0', rst, synch_rst);

    -- Generate 1Hz slow clock enable and blinking signals for TLC sequencing
    INST3: clock_generator port map (sim_mode, synch_rst, clkin_50, sm_clken, blink_sig);

    -- Synchronize and hold pedestrian button for EW direction (pb(1))
    INST4: synchronizer       port map (clkin_50, synch_rst, pb(1), EW_Request);
    INST5: holding_register   port map (clkin_50, synch_rst, EW_Clear, EW_Request, EW_Out);

    -- Synchronize and hold pedestrian button for NS direction (pb(0))
    INST6: synchronizer       port map (clkin_50, synch_rst, pb(0), NS_Request);
    INST7: holding_register   port map (clkin_50, synch_rst, NS_Clear, NS_Request, NS_Out);

    -- Synchronize sw(0) input (used for offline/online mode control)
    INST8: synchronizer       port map (clkin_50, synch_rst, sw(0), sw_sync_out);

    -- Main state machine (handles TLC state transitions, outputs, crossing logic and offline/online mode)
    INST9: State_Machine      port map (clkin_50, synch_rst, sm_clken, blink_sig, NS_Request, EW_Request, NS_Green, NS_Amber, NS_Red, NS_Crossing, NS_Clear, EW_Green, EW_Amber, EW_Red, EW_Crossing, EW_Clear, leds(7 downto 4), sw_sync_out, NS_Out, EW_Out);

    -- Other instantiations for 7-segment displays and LED outputs would follow...
    -- ... Code from the rest of LogicalStep 4.PNG goes here ...

END SimpleCircuit;
