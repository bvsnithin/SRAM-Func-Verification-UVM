/* -----------------------------------------------------------------------------------------
 File: test_pkg.sv
 Description: This package contains the test classes.
 
 This package acts as a container for all the different test scenarios. 
 By grouping them together, it makes it easier to organize and run 
 various tests (like the base test or low-power test) without having 
 to compile each one separately.
 ----------------------------------------------------------------------------------------- */

package test_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import ahb_agents_pkg::*;
    import ahb_seq_pkg::*;
    import sram_env_pkg::*;

    `include "base_test.sv"
    `include "addr0_test.sv"
    `include "addr1_test.sv"
    `include "hsize_test.sv"
    `include "low_power_test.sv"

endpackage
