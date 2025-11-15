# RTL Directory

This directory contains the RTL code for the SRAM Controller design. The design bridges an Advanced High-performance Bus (AHB) interface to a dual-bank SRAM memory model, with advanced low-power byte-lane enabling.

## Files Overview

### `ahb_slave_if.sv`
**Purpose**: Implements the AHB Slave interface logic.
**Logic Breakdown**:
- Acts as the pipelined front-end of the controller.
- **Address Phase**: Captures the AHB master's control signals (`haddr`, `hwrite`, `hsize`, `htrans`, `hsel`) on the rising edge of the clock when `hready` is high. It stores these in internal registers (`addr_reg`, `write_reg`, `size_reg`, `active_reg`) for processing in the subsequent data phase.
- **Data Phase**: The registered signals are driven out to the SRAM controller (`sram_addr`, `sram_wdata`, `sram_write`, `sram_size`, `sram_en`). This ensures the two-phase AHB pipeline is converted into a standard memory interface.

### `sram_ctrl.sv`
**Purpose**: Top-level SRAM Controller combining the AHB interface and the SRAM model.
**Logic Breakdown**:
- Instantiates the `ahb_slave_if` and `sram_model`.
- **Low-Power Logic**: Resolves which exact bytes of memory need to be active based on the transfer size (`sram_size`). For example, an 8-bit write only enables 1 byte lane instead of all 4, significantly reducing dynamic power consumption.
- **Bank Selection**: Bit 15 of the address (`s_addr[15]`) operates as the bank selector, routing the operation to Bank 0 or Bank 1.
- Generates the `sram_en` monitoring signals that are tracked by the UVM testbench.

### `sram_model.sv`
**Purpose**: A behavioral dual-bank SRAM memory model.
**Logic Breakdown**:
- Simulates two 32KB memory banks (`Bank0` and `Bank1`), where each bank is composed of four 8-bit sub-blocks (Byte Lanes 0 to 3).
- **Writes**: Synchronous writes to specific byte lanes conditionally gated by the `we` (Write Enable) and `en` (Chip Enable) signals. This perfectly models the low-power aspect.
- **Reads**: Zero-wait-state combinational reads. It reads the full 32-bit word from the selected bank based on the decoded `row_addr` (`addr[14:2]`).

