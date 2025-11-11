#!/bin/bash
# -----------------------------------------------------------------------------------------
# File: setupX.bash
# Description: This script prepares your computer to run the simulation by pointing it 
# to the right software tools (like Cadence Xcelium). It sets up the 
# paths and shortcuts needed so that when you type a command to run a 
# test, the computer knows exactly where to find the simulation "engine."
# -----------------------------------------------------------------------------------------

export UVMHOME="/opt/coe/cadence/XCELIUM/tools/methodology/UVM/CDNS-1.1d/sv"
source /opt/coe/cadence/XCELIUM/setup.XCELIUM.linux.bash
source /opt/coe/cadence/VMANAGER/setup.VMANAGER.linux.bash
alias imc="/opt/coe/cadence/VMANAGER/bin/imc"
echo Success

