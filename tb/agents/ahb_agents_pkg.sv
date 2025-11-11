/* -----------------------------------------------------------------------------------------
 File: ahb_agents_pkg.sv
 Description: This package contains the AHB Agent components.
 
 This package groups all the pieces of the "Agent" together. An Agent 
 is a collection of components (like the Driver and Monitor) that 
 work as a team to handle all the talk between the testbench and 
 a specific interface (like the AHB bus).
 ----------------------------------------------------------------------------------------- */

package ahb_agents_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    `include "sram_macros.svh"
    
    `include "ahb_transaction.sv"
    `include "ahb_sequencer.sv"
    `include "ahb_driver.sv"
    `include "ahb_monitor.sv"
    `include "ahb_agent.sv"

endpackage
