// Monitor
class ahb_monitor extends uvm_monitor;
    `uvm_component_utils(ahb_monitor)
        
    virtual ahb_if vif;
    uvm_analysis_port #(ahb_transaction) item_collected_port;
    ahb_transaction tr_cov;

    covergroup ahb_cov;
        option.per_instance = 1;
        cp_addr: coverpoint tr_cov.haddr[15:0] {
            bins bank0 = {[16'h0000:16'h7FFF]};
            bins bank1 = {[16'h8000:16'hFFFF]};
        }
        cp_size: coverpoint tr_cov.hsize {
            bins b8  = {3'b000};
            bins b16 = {3'b001};
            bins b32 = {3'b010};
        }
        cp_write: coverpoint tr_cov.hwrite;
        cross cp_addr, cp_size, cp_write;
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        item_collected_port = new("item_collected_port", this);
        ahb_cov = new();
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual ahb_if)::get(this, "", "vif", vif))
            `uvm_fatal("NO_VIF", "Virtual interface not found")
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            @(vif.cb);
            // Read driver-controlled signals directly (not via cb) to avoid
            // the #1step input skew — they are output-only in the clocking block
            if (vif.hsel && (vif.htrans == 2'b10 || vif.htrans == 2'b11)) begin
                fork
                    capture_data_phase(vif.haddr, vif.hwrite, vif.hsize);
                join_none
            end
        end
    endtask

    // Helper task to handle the data phase in parallel with the next address phase
    task capture_data_phase(bit [31:0] addr, bit write, bit [2:0] size);
        ahb_transaction tr;
        // Data Phase: RTL's ahb_slave_if presents addr_reg/active_reg to SRAM
        @(vif.cb);
        
        tr = ahb_transaction::type_id::create("tr");
        tr.haddr  = addr;
        tr.hwrite = write;
        tr.hsize  = size;
        
        if (write) begin
            // hwdata is a driver output — read directly to avoid cb skew
            tr.hwrdata = vif.hwdata;
            `AHB_LOG("MON_WRITE", "Collected Write", tr.haddr, tr.hwrdata)
        end else begin
            // Wait one extra cycle for the SRAM combinational read path to settle
            // (addr_reg & active_reg are registered in ahb_slave_if; rdata is
            // combinational from those registers, valid one cycle later)
            @(vif.cb);
            tr.hrdata = vif.cb.hrdata;
            `AHB_LOG("MON_READ", "Collected Read", tr.haddr, tr.hrdata)
        end
        
        // Sample coverage
        tr_cov = tr;
        ahb_cov.sample();
        
        // Low Power Log (Bank sel check)
        `LP_CHECK((vif.cb.bank_sel == 2'b10 ? 1 : 0), vif.cb.sram_en)

        item_collected_port.write(tr);
    endtask
    
endclass