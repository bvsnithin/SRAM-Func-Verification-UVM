/* -----------------------------------------------------------------------------------------
 File: top.sv
 Description: This file stores the top level testbench for the SRAM Controller.
 
 This is the main "meeting point" for the entire project. It connects the design 
 (the SRAM Controller) to the testbench components. It also generates the clock 
 and reset signals that make the hardware "tick" and starts the UVM testing 
 process to automatically run the simulation.
 ----------------------------------------------------------------------------------------- */
     
 `include "uvm_macros.svh"
 
 module top;
    import uvm_pkg::*;
    import ahb_agents_pkg::*;
    import sram_env_pkg::*;
    import test_pkg::*;

    // 1. Clock and Reset Generation
    logic hclk;
    logic hresetn;

    initial begin
        hclk = 0;
        forever #5 hclk = ~hclk; // 100MHz clock
    end

    initial begin
        hresetn = 0;
        #20 hresetn = 1;
    end

    // 2. Instantiate the Physical Interface
    ahb_if p_if(hclk, hresetn);

    // 3. Instantiate the DUT (RTL)
    sram_ctrl dut (
        .hclk    (p_if.hclk),
        .hresetn (p_if.hresetn),
        .haddr   (p_if.haddr),
        .hsize   (p_if.hsize),
        .hsel    (p_if.hsel),
        .hwrite  (p_if.hwrite),
        .htrans  (p_if.htrans),
        .hwdata  (p_if.hwdata),
        .hrdata  (p_if.hrdata),
        .hready  (p_if.hready),
        .hreadyout(p_if.hready),
        .hresp   (p_if.hresp),
        .bank_sel(p_if.bank_sel),
        .sram_en (p_if.sram_en)
    );

    // 4. Pass the Interface to UVM Configuration Database
    initial begin
        uvm_config_db#(virtual ahb_if)::set(null, "*", "vif", p_if);
        run_test();
    end
 endmodule