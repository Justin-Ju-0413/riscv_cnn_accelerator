param(
    [string]$SocDir = "C:\Users\16084\Documents\New project\e203_hbirdv2",
    [string]$Board = "davinci_a7_100t",
    [string]$AppDir = "C:\Users\16084\Documents\New project\riscv_cnn_accelerator\third_party\nuclei-sdk\application\baremetal\cnn_accel_demo",
    [string]$AppName = "cnn_accel_demo"
)

$ErrorActionPreference = "Stop"

$rtlSrc = Join-Path $SocDir "rtl\e203"
$boardSystem = Join-Path $SocDir "fpga\$Board\src\system.v"
$installRtl = Join-Path $SocDir "fpga\install\rtl"
$coreDir = Join-Path $installRtl "e203\core"
$itcm = Join-Path $AppDir "$AppName.itcm.verilog"
$dtcm = Join-Path $AppDir "$AppName.dtcm.verilog"

foreach ($path in @($rtlSrc, $boardSystem, $itcm, $dtcm)) {
    if (-not (Test-Path $path)) {
        throw "Required path not found: $path"
    }
}

if (Test-Path $installRtl) {
    Remove-Item -LiteralPath $installRtl -Recurse -Force
}
New-Item -ItemType Directory -Force $installRtl | Out-Null

Copy-Item -Path $rtlSrc -Destination $installRtl -Recurse -Force
Copy-Item -Path $boardSystem -Destination (Join-Path $installRtl "system.v") -Force

$defines = Join-Path $coreDir "e203_defines.v"
$defineText = Get-Content $defines -Raw
if (-not $defineText.StartsWith('`define FPGA_SOURCE')) {
    Set-Content -Path $defines -Value ('`define FPGA_SOURCE' + "`r`n" + $defineText) -NoNewline
}

Copy-Item -Path $itcm -Destination (Join-Path $coreDir "$AppName.itcm.verilog") -Force
Copy-Item -Path $dtcm -Destination (Join-Path $coreDir "$AppName.dtcm.verilog") -Force

$itcmVivado = (Join-Path $coreDir "$AppName.itcm.verilog") -replace "\\", "/"
$dtcmVivado = (Join-Path $coreDir "$AppName.dtcm.verilog") -replace "\\", "/"
$header = @(
    '`ifndef E203_FPGA_MEM_INIT_VH',
    '`define E203_FPGA_MEM_INIT_VH',
    ('`define E203_ITCM_INIT_FILE "' + $itcmVivado + '"'),
    ('`define E203_DTCM_INIT_FILE "' + $dtcmVivado + '"'),
    '`endif'
)
Set-Content -Path (Join-Path $coreDir "e203_fpga_mem_init.vh") -Value $header

Write-Host "Prepared FPGA install RTL: $installRtl"
Write-Host "ITCM: $itcmVivado"
Write-Host "DTCM: $dtcmVivado"
