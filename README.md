# FPGA Traffic Light Controller

This repository contains the VHDL source code for a synchronous Traffic Light Controller (TLC) designed for an FPGA. The controller manages a standard North-South and East-West intersection, with additional logic for pedestrian crossing requests and a special offline/maintenance mode.

## Features
Synchronous Design: All state transitions are synchronized to a 50MHz system clock.

Hierarchical Structure: The design is modular, with a top-level entity connecting specialized components like a state machine, synchronizers, and input filters.

State Machine Core: A robust, 16-state Moore FSM controls the entire traffic light sequence. The FSM is implemented using a standard three-process VHDL model for clarity and reliability.

Pedestrian Crossing: Handles asynchronous pedestrian requests for both NS and EW directions. Inputs are debounced, synchronized, and latched until serviced by the FSM.

Offline Mode: An external switch can place the controller into an offline/maintenance mode where traffic lights flash (NS Red, EW Amber).

Metastability Protection: Asynchronous inputs (pushbuttons, reset, mode switch) are passed through a 2-flop synchronizer to prevent metastability issues.

<img width="2096" height="1445" alt="image" src="https://github.com/user-attachments/assets/9efcfcfb-5969-473b-9b49-b9d063012e33" />
