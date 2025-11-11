/* -----------------------------------------------------------------------------------------
 File: ahb_if.sv
 Description: This file defines the AHB Interface.
 
 Think of the interface as a physical "connector" or "port." It defines 
 all the wires and signals (like clock, reset, address, and data) 
 that are used to link the testbench to the memory controller. It 
 makes it easy to handle all these complex signals as a single package.
 ----------------------------------------------------------------------------------------- */

interface ahb_if(input logic hclk, input logic hresetn);

    //AHB Signals
    logic [31:0] haddr;
    logic [31:0] hwdata;
    logic [31:0] hrdata;
    logic        hwrite;
    logic [1:0]  htrans;
    logic [2:0]  hsize;
    logic        hsel;
    logic        hready; // Always High
    logic [1:0]  hresp;  // Always OKAY

    // Low Power Monitoring Signals (Internal to RTL)
    logic [1:0]  bank_sel;     // Which bank is active (0 or 1)
    logic [3:0]  sram_en;      // Which of the 4 SRAMs in a bank are active
  
    // Clocking block for synchronous driving/sampling.
    // DRIVER outputs: TB drives these TO the DUT.
    // MONITOR inputs: DUT drives these back TO the TB.
    // NOTE: haddr/hwdata/etc. are driver outputs only — do NOT redeclare
    // as inputs here. Reading them back via clocking block would apply a
    // #1step skew, making the monitor sample one cycle behind.
    // The monitor reads driver-controlled signals directly as vif.hXxx.
    clocking cb @(posedge hclk);
        output haddr, hwdata, hwrite, htrans, hsize, hsel;
        input  hrdata, bank_sel, sram_en;
    endclocking

endinterface