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
  
    logic        reset_trigger = 1'b0; // Verification-driven reset trigger
  
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

    // :::::::::::: AHB Protocol Assertions ::::::::::::
    property hresp_always_okay;
        @(posedge hclk)
        disable iff(!hresetn)
        hresp == 2'b00;
    endproperty

    property hreadyout_always_high;
        @(posedge hclk)
        disable iff(!hresetn)
        hready == 1'b1;
    endproperty

    // When a 16-bit transfer is active (hsize == 3'b001), the address must be half-word aligned
    property aligned_16bit_addr;
        @(posedge hclk)
        disable iff(!hresetn)
        (hsel && htrans[1] && hsize == 3'b001) |-> (haddr[0] == 1'b0);
    endproperty

    // When a 32-bit transfer is active (hsize == 3'b010), the address must be 32 bit algined
    property aligned_32bit_addr;
        @(posedge hclk)
        disable iff(!hresetn)
        (hsel && htrans[1] && hsize == 3'b010) |-> (haddr[1:0] == 2'b00);
    endproperty

    property valid_htrans;
        @(posedge hclk)
        disable iff(!hresetn)
        htrans inside {2'b00, 2'b10};
    endproperty

    assert_hresp:           assert property(hresp_always_okay)
                            else $error("ASSERT FAIL: hresp is not OKAY");

    assert_hready:          assert property (hreadyout_always_high)
                            else $error("ASSERT FAIL: hreadyout is not high");

    assert_align16:         assert property (aligned_16bit_addr)
                            else $error("ASSERT FAIL: 16-bit address misaligned");

    assert_align32:         assert property (aligned_32bit_addr)
                            else $error("ASSERT FAIL: 32-bit address misaligned");

    assert_valid_htrans:    assert property (valid_htrans)
                            else $error("ASSERT FAIL: invalid htrans value");

    // :::::::::::: SRAM Controller Assertions :::::::::::::::
    property bank0_sel_when_addr15_low;
        @(posedge hclk) disable iff (!hresetn)
        (hsel && htrans[1] && !haddr[15]) |=> (bank_sel == 2'b01);
    endproperty

    property bank1_sel_when_addr15_high;
        @(posedge hclk) disable iff (!hresetn)
        (hsel && htrans[1] && haddr[15]) |=> (bank_sel == 2'b10);
    endproperty

    property no_bank_when_idle;
        @(posedge hclk) disable iff (!hresetn)
        !(hsel && htrans[1]) |=> (bank_sel == 2'b00);
    endproperty

    property byte_lane_8bit;
        @(posedge hclk) disable iff (!hresetn)
        (hsel && htrans[1] && hsize == 3'b000) |=> ($countones(sram_en) == 1);
    endproperty

    property byte_lane_16bit;
        @(posedge hclk) disable iff (!hresetn)
        (hsel && htrans[1] && hsize == 3'b001) |=> ($countones(sram_en) == 2);
    endproperty

    property byte_lane_32bit;
        @(posedge hclk) disable iff (!hresetn)
        (hsel && htrans[1] && hsize == 3'b010) |=> (sram_en == 4'b1111);
    endproperty

    property no_write_during_reset;
        @(posedge hclk)
        (!hresetn) |-> (sram_en == 4'b0000 && bank_sel == 2'b00);
    endproperty

    property read_data_valid;
        @(posedge hclk) disable iff (!hresetn)
        (hsel && htrans[1] && !hwrite) |=> (!$isunknown(hrdata));
    endproperty

    assert_bank0:           assert property (bank0_sel_when_addr15_low)
                            else $error("ASSERT FAIL: bank0 not selected when addr[15]=0");

    assert_bank1:           assert property (bank1_sel_when_addr15_high)
                            else $error("ASSERT FAIL: bank1 not selected when addr[15]=1");

    assert_no_bank:         assert property (no_bank_when_idle)
                            else $error("ASSERT FAIL: bank active during idle");

    assert_byte8:           assert property (byte_lane_8bit)
                            else $error("ASSERT FAIL: wrong number of byte lanes active for 8-bit size");

    assert_byte16:          assert property (byte_lane_16bit)
                            else $error("ASSERT FAIL: wrong number of byte lanes active for 16-bit size");

    assert_byte32:          assert property (byte_lane_32bit)
                            else $error("ASSERT FAIL: wrong number of byte lanes active for 32-bit size");

    assert_no_wr_rst:       assert property (no_write_during_reset)
                            else $error("ASSERT FAIL: write active during reset");

    assert_read_valid:      assert property (read_data_valid)
                            else $error("ASSERT FAIL: read data contains X or Z");

endinterface