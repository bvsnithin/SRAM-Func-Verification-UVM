/* -----------------------------------------------------------------------------------------
 File: base_test.sv
 Description: Base test class.
 
 The base test is like a "starter kit" or template for all other tests. 
 It sets up the common environment and rules that every test needs, 
 ensuring that each specific test (like the low-power one) starts from 
 a consistent and ready-to-use state.
 ----------------------------------------------------------------------------------------- */

class base_test extends uvm_test;
    `uvm_component_utils(base_test)

    sram_env env;

    function new(string name = "base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = sram_env::type_id::create("env", this);
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction

    virtual task run_phase(uvm_phase phase);
        // Default behavior
    endtask
endclass
