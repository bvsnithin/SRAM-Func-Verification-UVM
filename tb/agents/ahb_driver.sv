/* -----------------------------------------------------------------------------------------
 File: ahb_driver.sv
 Description: This file implements the AHB Driver.
 
 The Driver is like a "postman" for the testbench. It takes a high-level 
 request (like "write 10 to address 0x100") and translates it into 
 the electrical signals (on/off signals on wires) that the SRAM 
 Controller can understand and act upon.
 ----------------------------------------------------------------------------------------- */

class ahb_driver extends uvm_driver #(ahb_transaction);
    `uvm_component_utils(ahb_driver)
    
    virtual ahb_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual ahb_if)::get(this, "", "vif", vif))
            `uvm_fatal("NO_VIF", "Virtual interface not found")
    endfunction

    virtual task run_phase(uvm_phase phase);
        // Wait for initial power-on reset to deassert before driving any bus transactions.
        wait(vif.hresetn === 1'b1);
        @(vif.cb); // one settling cycle after reset
        forever begin
            seq_item_port.get_next_item(req);
            drive_transaction(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_transaction(ahb_transaction tr);
        // Address Phase
        @(vif.cb);
        vif.cb.haddr  <= tr.haddr;
        vif.cb.hwrite <= tr.hwrite;
        vif.cb.hsize  <= tr.hsize;
        vif.cb.htrans <= 2'b10; // NONSEQ
        vif.cb.hsel   <= 1'b1;
        
        if (tr.hwrite) begin
            // Data Phase: present write data
            @(vif.cb);
            vif.cb.hwdata <= tr.hwrdata;
            vif.cb.hsel   <= 1'b0;
            vif.cb.htrans <= 2'b00; // IDLE
            `AHB_LOG("DRV_WRITE", "Driving Write", tr.haddr, tr.hwrdata)
            // IDLE bubble: let the write clock into SRAM before next transaction
            @(vif.cb);
        end else begin
            // Data Phase: hrdata driven by RTL combinationally from addr_reg
            // addr_reg is registered in ahb_slave_if, so valid one cycle after addr phase
            @(vif.cb);
            vif.cb.hsel   <= 1'b0;
            vif.cb.htrans <= 2'b00; // IDLE
            // Wait one extra cycle for the combinational rdata path to settle
            // after the registered addr_reg / active_reg are applied
            @(vif.cb);
            tr.hrdata = vif.cb.hrdata;
            `AHB_LOG("DRV_READ", "Driving Read", tr.haddr, tr.hrdata)
        end
    endtask
endclass