# Functional Verification of SRAM Controller based on UVM

## Project Overview
This project is a functional verification of an SRAM controller based on the AHB (Advanced High-performance Bus) protocol, reproduced from the paper “Functional Verification of SRAM Controller based on UVM”. The SRAM controller enables seamless communication between an AHB bus and a SRAM memory through an AHB slave interface.

The design prioritizes low power operation by dividing the SRAM into two banks, and supports 8/16/32-bit data transfers efficiently. This repository implements the design and verification of the SRAM controller using UVM methodology.

## AHB (Advanced High-performance Bus)

AHB (Advanced High-performance Bus) is a part of the AMBA (Advanced Microcontroller Bus Architecture) specification used in ARM-based systems. It is a high-speed bus protocol designed for communication between masters (like CPUs or DMA controllers) and slaves (like SRAM, ROM, or peripherals).

**Key Features of AHB:**
* High-performance, pipelined bus transfers.
* Supports multiple data widths: 8, 16, 32 bits.
* Single or burst data transfers.
* Simple slave interface design with ready/response signals.

**Important AHB Signals:**

| Signal	| Description |
| --- | --- |
| HADDR	| Address bus: indicates the memory or register location to access. |
| HWDATA	| Data to be written to the slave. |
| HRDATA	| Data read from the slave. |
| HWRITE	| Read/Write control (1 = Write, 0 = Read). |
| HREADY	| Indicates slave is ready for the next transfer. |
| HRESP	| Transfer response (OKAY, ERROR). |

In simple terms, the master places an address and control signals on the bus. The slave responds with data (for read) or accepts data (for write), along with a status response.

### AHB in This Project

In this design, the SRAM controller acts as an AHB slave. It connects the AHB bus to the SRAM memory and performs read/write operations according to the AHB protocol.
Single transfer mode is implemented:
* HREADY is always high (no wait states)
* HRESP is always OKAY

The controller supports 8/16/32-bit transfers by selectively enabling the SRAM sub-blocks.
The controller splits the 64 KB SRAM into two banks (Bank0 and Bank1) for low-power operation.

---

## Design of the SRAM Controller

### SRAM Organization

* 64 KB total memory, split into 2 banks (32 KB each).
* Each bank contains 4 SRAM blocks of 8-bit width.
* 8-bit transfer: only 1 SRAM used
* 16-bit transfer: 2 SRAMs used
* 32-bit transfer: 4 SRAMs used
* Power optimization: selected SRAM consumes 10× more power than unselected, reducing overall consumption.

### High-Level Architecture

```mermaid
flowchart LR

    A[AHB Bus Slave Interface]

    subgraph """
        direction TB
        
        subgraph Bank0
            direction LR
            s3[sram3]
            s2[sram2]
            s1[sram1]
            s0[sram0]
        end
        
        subgraph Bank1
            direction LR
            s7[sram7]
            s6[sram6]
            s5[sram5]
            s4[sram4]
        end
    end

    A <--> SRAM_Controller
```

**Explanation of the Diagram:**
* The AHB slave interface receives read/write requests from the master.
* The SRAM controller decodes the request and selects the appropriate SRAM blocks.
* Banks and sub-blocks are selected based on address and transfer width, enabling low-power operation.



