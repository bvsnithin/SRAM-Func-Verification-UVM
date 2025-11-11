/* -----------------------------------------------------------------------------------------
 File: ahb_transaction.sv
 Description: This file defines the AHB transaction data structure.
 
 This file defines what a single "request" on the bus looks like. It includes 
 information like the address to access, the data to write, and whether to 
 read or write. It also includes rules (constraints) to make sure the address 
 is valid and correctly aligned (e.g., 32-bit data must start at an address 
 divisible by 4).
 ----------------------------------------------------------------------------------------- */



class ahb_transaction extends uvm_sequence_item;

    `uvm_object_utils(ahb_transaction)

    rand bit [31:0] haddr;
    rand bit [31:0] hrdata;
    rand bit [2:0] hsize;       // 000 = 8 bit, 001 = 16 bit, 010 = 32 bit
    rand bit hwrite;
    rand bit [31:0] hwrdata;


    //Constraint for 64k address space
    constraint addr_range {
        haddr < 32'h10000;
    }


    /* 
    In computer systems, alignment refers to how data is arranged in memory. 
    Some systems require data to be stored at specific addresses based on the size of the data. 
    This helps the system access the data more efficiently.

    8-bit data can be stored at any address.
    16-bit data needs to be stored at an even address (because it's 2 bytes, and even addresses make access faster).
    32-bit data needs to be stored at addresses that are divisible by 4 (because it's 4 bytes).
    */
    //Ensure address alignment based on size
    constraint addr_alignment {
        (hsize == 3'b001) -> (haddr[0] == 0);
        (hsize == 3'b010) -> (haddr[1:0] == 0);
    }


    function new(string name = "ahb_transaction");
        super.new(name);
    endfunction: new

endclass: ahb_transaction