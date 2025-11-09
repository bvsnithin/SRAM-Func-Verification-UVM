/* -----------------------------------------------------------------------------------------
 File: ahb_slave_if.sv
 Description: This file implements the AHB Slave interface logic.
 ----------------------------------------------------------------------------------------- */

module ahb_slave_if(
    input wire hclk,
    input wire hresetn,

    // AHB Signals
    input wire [31:0] haddr,
    input wire [31:0] hwdata,
    input wire        hwrite,
    input wire [1:0]  htrans,
    input wire [2:0]  hsize,
    input wire        hsel,
    input wire        hready,
    
    output wire [31:0] hrdata,
    output wire        hreadyout,
    output wire [1:0]  hresp,

    // Internal Interface to SRAM Controller
    output logic [15:0] sram_addr,
    output logic [31:0] sram_wdata,
    output logic        sram_write,
    output logic [2:0]  sram_size,
    output logic        sram_en,
    input wire [31:0] sram_rdata
);

    // AHB is pipelined. Sample control signals in address phase.
    reg [15:0] addr_reg;
    reg        write_reg;
    reg [2:0]  size_reg;
    reg        active_reg;

    localparam IDLE   = 2'b00;
    localparam BUSY   = 2'b01;
    localparam NONSEQ = 2'b10;
    localparam SEQ    = 2'b11;

    always @(posedge hclk or negedge hresetn) begin
        if (!hresetn) begin
            addr_reg   <= 16'h0;
            write_reg  <= 1'b0;
            size_reg   <= 3'b0;
            active_reg <= 1'b0;
        end else if (hready) begin
            // Sample for the data phase of the current transaction
            active_reg <= hsel && (htrans == NONSEQ || htrans == SEQ);
            addr_reg   <= haddr[15:0];
            write_reg  <= hwrite;
            size_reg   <= hsize;
        end
    end

    // The logic below defines the signals for the Data Phase (which is one cycle after the Address Phase)
    assign sram_addr  = addr_reg;
    assign sram_wdata = hwdata;
    assign sram_write = write_reg && active_reg;
    assign sram_size  = size_reg;
    assign sram_en    = active_reg;

    assign hrdata    = sram_rdata;
    assign hreadyout = 1'b1;  // Always ready
    assign hresp     = 2'b00; // Always OKAY

endmodule
