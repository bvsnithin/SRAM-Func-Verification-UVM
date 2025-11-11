/* -----------------------------------------------------------------------------------------
 File: ahb_seq_pkg.sv
 Description: This package contains the sequences.
 
 This package groups all the different "scripts" (sequences) together. 
 Think of it as a book that contains all the different instruction 
 manuals for the various tasks the testbench might want to perform on the bus.
 ----------------------------------------------------------------------------------------- */

package ahb_seq_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import ahb_agents_pkg::*;

    `include "ahb_sequences.sv"

endpackage
