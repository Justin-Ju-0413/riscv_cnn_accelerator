param(
    [string]$BitFile = "C:\Users\16084\Documents\New project\e203_hbirdv2\fpga\davinci_a7_100t\obj\system.bit",
    [string]$ProbesFile = "C:\Users\16084\Documents\New project\e203_hbirdv2\fpga\davinci_a7_100t\obj\davinci_a7_100t.runs\impl_1\system.ltx",
    [string]$OutputDir = "C:\Users\16084\Documents\Graduation_Design_Library\04_Experiments\Board_BringUp\2026-04-28_board_connection_check\ila_capture",
    [string]$VivadoBat = "D:\Xilinx\Vivado\2023.2\bin\vivado.bat"
)

$ErrorActionPreference = "Stop"

foreach ($path in @($VivadoBat, $BitFile, $ProbesFile)) {
    if (-not (Test-Path $path)) {
        throw "Required path not found: $path"
    }
}

New-Item -ItemType Directory -Force $OutputDir | Out-Null

$scriptPath = Join-Path $PSScriptRoot "capture_vivado_ila.tcl"
if (-not (Test-Path $scriptPath)) {
    throw "ILA capture TCL script not found: $scriptPath"
}

& $VivadoBat -nojournal -nolog -mode batch -source $scriptPath -tclargs $BitFile $ProbesFile $OutputDir
