# UVM Sequences Directory

This directory is responsible for all test stimulus generation. In UVM, sequences dictate what operations will be pushed to the sequencer, acting as the dynamic test scenario scripts that exercise the device.

## Files Overview

### `ahb_sequences.sv`
**Purpose**: Defines multiple specific action patterns (scripts) used by tests.
**Logic Breakdown**:
It contains a collection of classes extending `ahb_base_seq` that define different transaction scenarios using `uvm_do_with` generation loops.
- `ahb_base_seq`: Clean container defining generic attributes.
- `sequence_addr0`: Sends exactly 20 back-to-back explicit write and read sequences to incrementing addresses (`i*4`), forcing tight timing pipelines.
- `sequence_addr1`: Loops 20 times generating entirely random addresses but constrains the transaction to strictly be fixed length 32-bit (`hsize == 3'b010`).
- `sequence_addr2`: Loops 20 times randomizing target address AND selecting diverse, random bit dimensions via arrays (`hsize` inside 3'b000, 3'b001, 3'b010). Focuses on exercising variable byte lane functionality.
- `sequence_hsize`: Fixed bit-width behavior focusing strictly on large volume generic data.

### `ahb_seq_pkg.sv`
**Purpose**: Container File.
**Logic Breakdown**:
- Imports the UVM Library and internal agents packages, combining sequences into a compilable subset to be invoked from the top-level test classes.
