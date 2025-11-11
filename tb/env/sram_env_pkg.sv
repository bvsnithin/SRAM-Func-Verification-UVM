/* -----------------------------------------------------------------------------------------
 File: sram_env_pkg.sv
 Description: This package contains the Environment class and includes other TB components.
 
 This package acts as the "master folder" for all environment-related components. 
 It brings together the environment itself and the scoreboard, making them 
 available as a single package for the tests to use.
 ----------------------------------------------------------------------------------------- */

package sram_env_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import ahb_agents_pkg::*;

    `include "sram_scoreboard.sv"
    `include "sram_env.sv"

endpackage
