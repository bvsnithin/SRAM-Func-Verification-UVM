/* -----------------------------------------------------------------------------------------
 File: ahb_sequencer.sv
 Description: This file implements the AHB Sequencer.
 The Sequencer acts as a "traffic controller." It manages the flow of 
 messages (transactions) from the test scripts to the driver, making 
 sure each request is handed off at the right time.
 ----------------------------------------------------------------------------------------- */

typedef uvm_sequencer #(ahb_transaction) ahb_sequencer;
