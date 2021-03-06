# Simple script for compiling a vhdl file for simulation
# fcampi@sfu.ca / atino@sfu.ca

# Cleaning the work folder (This should not be done if compiling incrementally)
\rm -rf work

# Creating and mapping to logic name work the local work library
vlib work
vmap work work

# Compiling the VHDL code for simulation
vcom ../vhdl/aes128key.vhd 
vcom ../vhdl/aes128keyTB.vhd #-novopt 
