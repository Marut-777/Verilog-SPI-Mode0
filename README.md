# Verilog SPI Mode 0 Master-Slave

A beginner-level SPI Mode 0 master–slave communication project implemented in Verilog and verified through simulation.

## Features

- SPI Mode 0 communication (CPOL = 0, CPHA = 0).
- Master transmits a byte to the slave.
- Slave returns a response byte to the master.
- Testbench checks transmitted and received data.

## Example Simulation

- Master-to-slave byte: `0xA5`
- Slave-to-master response: `0x3C`
- Expected result: PASS when the received values match.

## Files

- `design.sv` — SPI master and slave RTL.
- `testbench.sv` — SPI simulation testbench.
- `SPI_Mode0_Waveform.png` — EPWave waveform screenshot.

## Simulation Environment

Simulated using Icarus Verilog and EPWave on EDA Playground.

This is an educational SPI Mode 0 simulation, not a hardware-validated SPI controller.
