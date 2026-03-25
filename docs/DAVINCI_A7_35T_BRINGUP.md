# Davinci A7-35T Bring-Up Notes

## Current Position

The repository now contains a dedicated FPGA shell target for the
Darvinci/Da Vinci Artix-7 board:

- [system.v](/home/gstar/Desktop/e203_hbirdv2/fpga/davinci_a7_35t/src/system.v)
- [nuclei-master.xdc](/home/gstar/Desktop/e203_hbirdv2/fpga/davinci_a7_35t/constrs/nuclei-master.xdc)
- [Makefile](/home/gstar/Desktop/e203_hbirdv2/fpga/davinci_a7_35t/Makefile)

## What Is Already Fixed

- FPGA part is locked to `xc7a35tfgg484-2`
- shell input clock is locked to `CLK50MHZ`
- low-frequency clock is kept as `CLK32768KHZ`
- SoC still runs from shell-generated `clk_16M`
- soft-core JTAG is exported as separate `mcu_TCK/TMS/TDI/TDO` board pins
- software target remains:
  - `SOC=evalsoc`
  - `BOARD=nuclei_fpga_eval`
  - `CORE=n300`
  - `DOWNLOAD=ilm`

## What Still Needs Manual Board Confirmation

The current Davinci shell is a real synthesis skeleton, but the board XDC is
still intentionally conservative. These items must be filled from the board
manual or schematic before the first bitstream attempt:

1. `CLK50MHZ` package pin
2. `CLK32768KHZ` package pin
3. reset button pins for `fpga_rst` and `mcu_rst`
4. the board-accessible header pins used for soft-core JTAG
5. the USB-UART-connected FPGA pins to map onto `gpioA[17]` and `gpioA[16]`

## Recommended First Wiring Policy

- soft-core JTAG:
  - use one accessible expansion header
  - dedicate four pins to `mcu_TCK/TMS/TDI/TDO`
  - attach the external FTDI/JTAG adapter there
- UART:
  - reserve one board USB-UART pair
  - map TX/RX to `gpioA[17]` / `gpioA[16]`

## Current Intended First Bring-Up Flow

1. `bash scripts/run_preboard_verification.sh`
2. `FPGA_NAME=davinci_a7_35t bash scripts/check_phase5_board_env.sh`
3. fill the real Davinci pin assignments in the XDC
4. `FPGA_NAME=davinci_a7_35t bash scripts/print_fpga_bringup_commands.sh`
5. `make -C /home/gstar/Desktop/e203_hbirdv2/fpga setup FPGA_NAME=davinci_a7_35t`
6. `make -C /home/gstar/Desktop/e203_hbirdv2/fpga bit FPGA_NAME=davinci_a7_35t`
7. bitstream download, then UART/JTAG validation
