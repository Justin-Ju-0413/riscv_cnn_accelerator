param(
    [ValidateSet("bit", "setup")]
    [string]$Action = "bit",
    [ValidateSet("soc", "heartbeat", "heartbeat_direct")]
    [string]$BuildMode = "soc",
    [string]$SocDir = "C:\Users\16084\Documents\New project\e203_hbirdv2",
    [string]$FpgaName = "davinci_a7_100t",
    [string]$VivadoBat = "D:\Xilinx\Vivado\2023.2\bin\vivado.bat"
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

if ($BuildMode -in @("heartbeat", "heartbeat_direct")) {
    $topName = if ($BuildMode -eq "heartbeat_direct") { "heartbeat_direct_system.v" } else { "heartbeat_system.v" }
    $heartbeatTop = Join-Path $boardDir "src\$topName"
    if (-not (Test-Path $heartbeatTop)) {
        throw "Heartbeat top not found: $heartbeatTop"
    }

    $installedTop = Join-Path $installRtl "system.v"
    $vsrcFiles = @($vsrcFiles | Where-Object { $_ -ne $installedTop })
    $vsrcFiles += (Get-Item -LiteralPath $heartbeatTop).FullName
}

$normalize = {
    param([string]$PathValue)
    ($PathValue -replace "\\", "/")
}

$normalizedFpgaRoot = & $normalize $fpgaRoot
$normalizedSources = $vsrcFiles | ForEach-Object { & $normalize $_ }

$env:BASEDIR = $normalizedFpgaRoot
$env:VSRCS = ($normalizedSources -join "`n")
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
Write-Host "Build mode: $BuildMode"
Write-Host "VSRCS count: $($vsrcFiles.Count)"
Write-Host "Launching: $VivadoBat $($args -join ' ')"

Push-Location $boardDir
try {
    & $VivadoBat @args
} finally {
    Pop-Location
}
