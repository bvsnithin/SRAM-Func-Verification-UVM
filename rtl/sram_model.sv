/* -----------------------------------------------------------------------------------------
 File: sram_model.sv
 Description: This file implements the SRAM memory model with 2 banks.
 ----------------------------------------------------------------------------------------- */

module sram_model(
    input wire hclk,
    input wire hresetn,
    
    input wire [15:0] addr,
    input wire [31:0] wdata,
    input wire [3:0]  we,
    input wire        en,
    
    output reg [31:0] rdata
);

    // Bank 0 Memory
    reg [7:0] bank0_0 [0:8191];
    reg [7:0] bank0_1 [0:8191];
    reg [7:0] bank0_2 [0:8191];
    reg [7:0] bank0_3 [0:8191];

    // Bank 1 Memory
    reg [7:0] bank1_0 [0:8191];
    reg [7:0] bank1_1 [0:8191];
    reg [7:0] bank1_2 [0:8191];
    reg [7:0] bank1_3 [0:8191];

    // Initialise memory to zero for clean simulation
    integer i;
    initial begin
        for (i = 0; i < 8192; i = i + 1) begin
            bank0_0[i] = 8'h0; bank0_1[i] = 8'h0; bank0_2[i] = 8'h0; bank0_3[i] = 8'h0;
            bank1_0[i] = 8'h0; bank1_1[i] = 8'h0; bank1_2[i] = 8'h0; bank1_3[i] = 8'h0;
        end
    end

    wire bank_sel = addr[15];
    wire [12:0] row_addr = addr[14:2];

    // Write Logic
    always @(posedge hclk) begin
        if (hresetn && en) begin
            if (~bank_sel) begin // Bank 0
                if (we[0]) bank0_0[row_addr] <= wdata[7:0];
                if (we[1]) bank0_1[row_addr] <= wdata[15:8];
                if (we[2]) bank0_2[row_addr] <= wdata[23:16];
                if (we[3]) bank0_3[row_addr] <= wdata[31:24];
            end else begin      // Bank 1
                if (we[0]) bank1_0[row_addr] <= wdata[7:0];
                if (we[1]) bank1_1[row_addr] <= wdata[15:8];
                if (we[2]) bank1_2[row_addr] <= wdata[23:16];
                if (we[3]) bank1_3[row_addr] <= wdata[31:24];
            end
        end
    end

    // Read Logic (combinational for AHB zero-wait-state)
    always @(*) begin
        if (~bank_sel) begin
            rdata = {bank0_3[row_addr], bank0_2[row_addr], bank0_1[row_addr], bank0_0[row_addr]};
        end else begin
            rdata = {bank1_3[row_addr], bank1_2[row_addr], bank1_1[row_addr], bank1_0[row_addr]};
        end
    end

endmodule
