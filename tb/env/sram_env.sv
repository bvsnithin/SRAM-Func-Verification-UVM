/* -----------------------------------------------------------------------------------------
 File: sram_env.sv
 Description: This file implements the SRAM Testbench Environment.
 The Environment is the "office" where all the verification components live. 
 it sets up and organizes the Agent and Scoreboard, making sure they are 
 connected and ready to work together to test the memory controller.
 ----------------------------------------------------------------------------------------- */

class sram_env extends uvm_env;
        `uvm_component_utils(sram_env)

        ahb_agent       agent;
        sram_scoreboard scoreboard;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            agent = ahb_agent::type_id::create("agent", this);
            scoreboard = sram_scoreboard::type_id::create("scoreboard", this);
        endfunction

        virtual function void connect_phase(uvm_phase phase);
            agent.monitor.item_collected_port.connect(scoreboard.item_collected_export);
        endfunction
endclass