/* -----------------------------------------------------------------------------------------
 File: low_power_test.sv
 Description: Low power test class.
 
 This is a specialized test that checks if the SRAM's "energy-saving" 
 features are working. It runs specific commands to make sure that 
 the controller only uses electricity for the parts of the memory 
 that are actually being used, rather than keeping everything on all the time.
 ----------------------------------------------------------------------------------------- */

class low_power_test extends base_test;
    `uvm_component_utils(low_power_test)

    function new(string name = "low_power_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        sequence_addr2 seq;
        seq = sequence_addr2::type_id::create("seq");
        phase.raise_objection(this);
        seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask
endclass
