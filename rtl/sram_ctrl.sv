/* -----------------------------------------------------------------------------------------
 File: sram_ctrl.sv
 Description: This file implements the Top-level SRAM Controller.
 This is the main controller that connects the AHB bus to the SRAM memory. 
 It takes signals from the AHB interface (like address and data) and decides 
 which part of the memory needs to be accessed. To save power, it only activates 
 the specific memory bank and the specific bytes (8-bit, 16-bit, or 32-bit) 
 that are actually being read from or written to.
 ----------------------------------------------------------------------------------------- */

module sram_ctrl(
    input wire hclk,
    input wire hresetn,

    // AHB inputs 
    input wire [31:0] haddr,
    input wire [31:0] hwdata,
    input wire        hwrite,
    input wire [1:0]  htrans,
    input wire [2:0]  hsize,
    input wire        hsel,
    input wire        hready,
    
    // AHB outputs
    output wire [31:0] hrdata,
    output wire        hreadyout,
    output wire [1:0]  hresp,

    // Low Power Monitoring Signals
    output wire [1:0] bank_sel,     // Which bank is active (bit0: Bank0, bit1: Bank1)
    output wire [3:0] sram_en       // Which of the 4 SRAMs in a bank are active
);

    wire [15:0] s_addr;
    wire [31:0] s_wdata;
    wire        s_write;
    wire [2:0]  s_size;
    wire        s_en;
    wire [31:0] s_rdata;

    // Instantiate AHB Slave Interface
    ahb_slave_if u_ahb_slave (
        .hclk       (hclk),
        .hresetn    (hresetn),
        .haddr      (haddr),
        .hwdata     (hwdata),
        .hwrite     (hwrite),
        .htrans     (htrans),
        .hsize      (hsize),
        .hsel       (hsel),
        .hready     (hready),
        .hrdata     (hrdata),
        .hreadyout  (hreadyout),
        .hresp      (hresp),
        .sram_addr  (s_addr),
        .sram_wdata (s_wdata),
        .sram_write (s_write),
        .sram_size  (s_size),
        .sram_en    (s_en),
        .sram_rdata (s_rdata)
    );

    // Byte Lane / SRAM Selection Logic (Low Power)
    reg [3:0] sram_en_reg;
    assign sram_en = sram_en_reg;

    always @(*) begin
        sram_en_reg = 4'b0000;
        if (s_en) begin
            case (s_size)
                3'b000: // 8-bit
                    sram_en_reg[s_addr[1:0]] = 1'b1;
                3'b001: // 16-bit
                    sram_en_reg = (s_addr[1]) ? 4'b1100 : 4'b0011;
                3'b010: // 32-bit
                    sram_en_reg = 4'b1111;
                default: sram_en_reg = 4'b1111;
            endcase
        end
    end

    // Bank Selection (Address 15 selects bank)
    assign bank_sel = (s_en) ? (s_addr[15] ? 2'b10 : 2'b01) : 2'b00;

    // Write Enable mask for SRAM model
    wire [3:0] sram_we = (s_write) ? sram_en_reg : 4'b0000;

    // Instantiate SRAM Model
    sram_model u_sram_model (
        .hclk    (hclk),
        .hresetn (hresetn),
        .addr    (s_addr),
        .wdata   (s_wdata),
        .we      (sram_we),
        .en      (s_en),
        .rdata   (s_rdata)
    );

endmodule
