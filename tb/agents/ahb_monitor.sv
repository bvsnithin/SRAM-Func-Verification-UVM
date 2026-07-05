// Monitor
class ahb_monitor extends uvm_monitor;
    `uvm_component_utils(ahb_monitor)
        
    virtual ahb_if vif;
    uvm_analysis_port #(ahb_transaction) item_collected_port;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        item_collected_port = new("item_collected_port", this);
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

        
        // Low Power Log (Bank sel check)
        `LP_CHECK((vif.cb.bank_sel == 2'b10 ? 1 : 0), vif.cb.sram_en)

        item_collected_port.write(tr);
    endtask
    
endclass