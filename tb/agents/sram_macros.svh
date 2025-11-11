/* -----------------------------------------------------------------------------------------
 File: sram_macros.svh
 Description: This file defines the macros used in the project.
 
 Macros are like "shorthand" or "shortcuts" for common pieces of code. 
 Instead of typing out a long logging message every time, we can use 
 a simple macro (like AHB_LOG) to do the work for us. This makes the 
 code cleaner and easier to read.
 ----------------------------------------------------------------------------------------- */

 `ifndef SRAM_MACROS_SVH
 `define SRAM_MACROS_SVH

 // Macro for standard AHB transaction logging
 `define AHB_LOG(ID, MSG, ADDR, DATA) \
    `uvm_info(ID, $sformatf("%s | Addr: 0x%0h | Data: 0x%0h", MSG, ADDR, DATA), UVM_LOW)

// Macro specifically for Low Power Bank/Byte-lane verification
`define LP_CHECK(BANK, BYTE_LANE) \
   `uvm_info("LOW_PWR_MON", $sformatf("Activating Bank: %0d | Byte Lanes: %b", BANK, BYTE_LANE), UVM_HIGH)

`endif