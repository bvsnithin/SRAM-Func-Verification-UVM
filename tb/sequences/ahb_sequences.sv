/* -----------------------------------------------------------------------------------------
 File: ahb_sequences.sv
 Description: This file contains the AHB sequences.
 
 This file contains the actual "scripts" for the tests. Each sequence 
 is a list of steps, like "write data A, then read it back". These 
 sequences tell the testbench exactly what actions to perform during 
 a simulation to prove the memory works correctly.
 ----------------------------------------------------------------------------------------- */

// Base Sequence
class ahb_base_seq extends uvm_sequence #(ahb_transaction);
    `uvm_object_utils(ahb_base_seq)
    function new(string name = "ahb_base_seq");
        super.new(name);
    endfunction
endclass

// sequence_addr0: fixed bit width, 20 read and write addresses in sequence
class sequence_addr0 extends ahb_base_seq;
    `uvm_object_utils(sequence_addr0)
    function new(string name = "sequence_addr0");
        super.new(name);
    endfunction
    
    virtual task body();
        for (int i = 0; i < 20; i++) begin
            // Write
            `uvm_do_with(req, {req.haddr == i*4; req.hwrite == 1'b1; req.hsize == 3'b010;})
            // Read
            `uvm_do_with(req, {req.haddr == i*4; req.hwrite == 1'b0; req.hsize == 3'b010;})
        end
    endtask
endclass

// sequence_addr1: fixed bit width, randomly generates read and write addresses
class sequence_addr1 extends ahb_base_seq;
    `uvm_object_utils(sequence_addr1)
    function new(string name = "sequence_addr1");
        super.new(name);
    endfunction
    
    virtual task body();
        repeat(20) begin
            `uvm_do_with(req, {req.hsize == 3'b010;})
        end
    endtask
endclass

// sequence_addr2: randomly wide (8/16/32bit), randomly generates read and write addresses
class sequence_addr2 extends ahb_base_seq;
    `uvm_object_utils(sequence_addr2)
    function new(string name = "sequence_addr2");
        super.new(name);
    endfunction
    
    virtual task body();
        repeat(20) begin
            `uvm_do_with(req, {req.hsize inside {3'b000, 3'b001, 3'b010};})
        end
    endtask
endclass

// sequence_hsize: fixed bit width, read/write addr and data randomly generated
class sequence_hsize extends ahb_base_seq;
    `uvm_object_utils(sequence_hsize)
    function new(string name = "sequence_hsize");
        super.new(name);
    endfunction
    
    virtual task body();
        repeat(20) begin
            `uvm_do_with(req, {req.hsize == 3'b010;})
        end
    endtask
endclass
