# hello_e203

Minimal freestanding board image for E203 FPGA bring-up.

- Linked at ITCM base `0x80000000`.
- Uses the mask ROM boot path by requiring `bootrom_n=0` in the FPGA top, so reset starts at `0x00001000` and the ROM jumps to ITCM.
- Configures GPIOA IOF bits 16/17 for UART0 RX/TX.
- Prints staged UART text and toggles GPIOA bit 0 as an LED/stage marker.

Build from the repo root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Build-HelloE203.ps1
```
