param(
    [string]$BitFile = "C:\Users\16084\Documents\New project\e203_hbirdv2\fpga\davinci_a7_100t\obj\system.bit",
    [string]$VivadoBat = "D:\Xilinx\Vivado\2023.2\bin\vivado.bat"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $VivadoBat)) {
    throw "Vivado launcher not found: $VivadoBat"
}
if (-not (Test-Path $BitFile)) {
    throw "Bitstream not found: $BitFile"
}

$scriptPath = Join-Path $PSScriptRoot "program_vivado_bit.tcl"
if (-not (Test-Path $scriptPath)) {
    throw "Programming TCL script not found: $scriptPath"
}

& $VivadoBat -nojournal -nolog -mode batch -source $scriptPath -tclargs $BitFile
