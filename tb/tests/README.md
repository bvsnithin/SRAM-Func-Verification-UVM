# UVM Tests Directory

These are the primary control tests to be executed by the Xcelium simulator using the `+UVM_TESTNAME=` argument. UVM isolates "test intent" (the specific thing we want to happen) into modular classes.

## Files Overview

### `base_test.sv`
**Purpose**: Foundational standard for testing operations.
**Logic Breakdown**:
- Generates the `sram_env` allowing everything inside to boot up.
- Every test in this directory inherits from `base_test`. It avoids duplicating basic structural boilerplate, ensuring consistency. Additionally, it features debugging tasks like `print_topology()` acting as global utilities.

### `addr0_test.sv`
**Purpose**: Runs the tightly coupled Read/Write sweep test.
**Logic Breakdown**:
- Triggers `sequence_addr0` utilizing the UVM Objection mechanism (`raise_objection` / `drop_objection`) keeping simulation alive until the specific 20 cycles are exhausted. Ensures basic linear pipeline capability works.

### `addr1_test.sv`
**Purpose**: Runs heavily randomized 32-bit testing.
**Logic Breakdown**:
- Triggers `sequence_addr1`. Verifies logic decoding bounds when 32-bit boundaries are heavily saturated across 64KB limitations.

### `addr2_test.sv` (if applicable) & `hsize_test.sv`
**Purpose**: Executes complex size mutations and alignments.
**Logic Breakdown**:
- Drives `sequence_hsize` ensuring that regardless of random inputs, basic operations succeed.

### `low_power_test.sv`
**Purpose**: Target test maximizing verification of specific specialized behavior.
**Logic Breakdown**:
- Specifically invokes sequences aimed at creating variable 8-bit, 16-bit, and 32-bit queries. Monitors inside `ahb_monitor` track the power traces during these events asserting they match expected limits.

### `test_pkg.sv`
**Purpose**: Groups and connects test classes.
**Logic Breakdown**:
- Pulls `uvm_pkg`, the agent packages, the environment, and sequence datasets to give complete scope to all testing modules within it.
