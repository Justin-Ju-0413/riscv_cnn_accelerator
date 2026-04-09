param(
    [ValidateSet("bit", "setup")]
    [string]$Action = "bit",
    [string]$SocDir = "E:\riscv-workspace\repos\e203_hbirdv2",
    [string]$FpgaName = "davinci_a7_100t",
    [string]$VivadoBat = "C:\Xilinx\Vivado\2023.2\bin\vivado.bat"
)

$ErrorActionPreference = "Stop"

$fpgaRoot = Join-Path $SocDir "fpga"
$boardDir = Join-Path $fpgaRoot $FpgaName
$installRtl = Join-Path $fpgaRoot "install\rtl"

if (-not (Test-Path $VivadoBat)) {
    throw "Vivado launcher not found: $VivadoBat"
}
if (-not (Test-Path $boardDir)) {
    throw "Board directory not found: $boardDir"
}
if (-not (Test-Path $installRtl)) {
    throw "Installed RTL directory not found: $installRtl. Run 'make -C $fpgaRoot FPGA_NAME=$FpgaName install' first."
}

$vsrcFiles = Get-ChildItem -Path $installRtl -Recurse -File -Filter *.v |
    Sort-Object FullName |
    Select-Object -ExpandProperty FullName

if (-not $vsrcFiles -or $vsrcFiles.Count -eq 0) {
    throw "No Verilog sources found under $installRtl"
}

$normalize = {
    param([string]$PathValue)
    ($PathValue -replace "\\", "/")
}

$toTclList = {
    param([string[]]$Values)
    (($Values | ForEach-Object { "{${_}}" }) -join " ")
}

$normalizedFpgaRoot = & $normalize $fpgaRoot
$normalizedSources = $vsrcFiles | ForEach-Object { & $normalize $_ }

$env:BASEDIR = $normalizedFpgaRoot
$env:VSRCS = & $toTclList $normalizedSources
$env:EXTRA_VSRCS = ""

$commonArgs = @(
    "-nojournal",
    "-mode"
)

if ($Action -eq "setup") {
    $args = $commonArgs + @(
        "gui",
        "-source", "script/board.tcl",
        "-source", "script/prologue_setup.tcl",
        "-source", "script/init_setup.tcl"
    )
} else {
    $args = $commonArgs + @(
        "batch",
        "-source", "script/board.tcl",
        "-source", "script/prologue.tcl",
        "-source", "script/init.tcl",
        "-source", "script/impl.tcl"
    )
}

Write-Host "Vivado board dir: $boardDir"
Write-Host "VSRCS count: $($vsrcFiles.Count)"
Write-Host "Launching: $VivadoBat $($args -join ' ')"

Push-Location $boardDir
try {
    & $VivadoBat @args
} finally {
    Pop-Location
}
