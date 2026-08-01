param(
    [string]$GccRoot = "D:\Xilinx\Vitis\2023.2\gnu\riscv\nt\riscv64-unknown-elf",
    [string]$SocDir = "C:\Users\16084\Documents\New project\e203_hbirdv2",
    [string]$Board = "davinci_a7_100t"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$srcDir = Join-Path $repoRoot "sw\cnn_accel_demo"
$buildDir = Join-Path $srcDir "build"
$gcc = Join-Path $GccRoot "bin\riscv64-unknown-elf-gcc.exe"
$objcopy = Join-Path $GccRoot "bin\riscv64-unknown-elf-objcopy.exe"
$objdump = Join-Path $GccRoot "bin\riscv64-unknown-elf-objdump.exe"

function Get-ShortPath {
    param([string]$PathValue)
    $parent = Split-Path -Parent $PathValue
    if ($parent -and -not (Test-Path $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    $escaped = $PathValue.Replace('"', '""')
    $short = cmd /c "for %I in (""$escaped"") do @echo %~sI"
    if (-not $short) {
        return $PathValue
    }
    return $short.Trim()
}

foreach ($path in @($gcc, $objcopy, $objdump, (Join-Path $srcDir "startup.S"), (Join-Path $srcDir "main.c"), (Join-Path $srcDir "linker.ld"))) {
    if (-not (Test-Path $path)) {
        throw "Required path not found: $path"
    }
}

New-Item -ItemType Directory -Force -Path $buildDir | Out-Null

$elf = Join-Path $buildDir "cnn_accel_demo.elf"
$verilog = Join-Path $buildDir "cnn_accel_demo.verilog"
$dump = Join-Path $buildDir "cnn_accel_demo.dump"
$map = Join-Path $buildDir "cnn_accel_demo.map"
$linker = Join-Path $srcDir "linker.ld"
$startup = Join-Path $srcDir "startup.S"
$main = Join-Path $srcDir "main.c"

$elfArg = Get-ShortPath $elf
$mapArg = Get-ShortPath $map
$linkerArg = Get-ShortPath $linker
$startupArg = Get-ShortPath $startup
$mainArg = Get-ShortPath $main

$commonFlags = @(
    "-march=rv32imac_zicsr",
    "-mabi=ilp32",
    "-mcmodel=medlow",
    "-ffreestanding",
    "-fno-builtin",
    "-fno-pic",
    "-nostdlib",
    "-nostartfiles",
    "-Os",
    "-Wall",
    "-Wextra",
    "-Wno-unused-function"
)

$gccArgs = @()
$gccArgs += $commonFlags
$gccArgs += @(
    "-T", $linkerArg,
    "-Wl,--build-id=none",
    "-Wl,-Map=$mapArg",
    "-o", $elfArg,
    $startupArg,
    $mainArg
)

& $gcc @gccArgs
if ($LASTEXITCODE -ne 0) {
    throw "GCC failed with exit code $LASTEXITCODE"
}

& $objcopy "-O" "verilog" $elfArg (Get-ShortPath $verilog)
if ($LASTEXITCODE -ne 0) {
    throw "objcopy failed with exit code $LASTEXITCODE"
}

& $objdump "-d" $elfArg | Set-Content -Encoding ASCII $dump
if ($LASTEXITCODE -ne 0) {
    throw "objdump failed with exit code $LASTEXITCODE"
}

$itcmOut = $verilog -replace '\.verilog$', '.itcm.verilog'
$dtcmOut = $verilog -replace '\.verilog$', '.dtcm.verilog'
$itcmWriter = [System.IO.StreamWriter]::new($itcmOut, $false, [System.Text.Encoding]::ASCII)
$dtcmWriter = [System.IO.StreamWriter]::new($dtcmOut, $false, [System.Text.Encoding]::ASCII)
try {
    $mode = ""
    foreach ($line in Get-Content $verilog) {
        if ($line.StartsWith("@")) {
            if ($line.StartsWith("@800")) {
                $mode = "itcm"
                $itcmWriter.WriteLine("@000" + $line.Substring(4))
            } elseif ($line.StartsWith("@900")) {
                $mode = "dtcm"
                $dtcmWriter.WriteLine("@000" + $line.Substring(4))
            } else {
                $mode = ""
            }
        } elseif ($mode -eq "itcm") {
            $itcmWriter.WriteLine($line)
        } elseif ($mode -eq "dtcm") {
            $dtcmWriter.WriteLine($line)
        }
    }
} finally {
    $itcmWriter.Close()
    $dtcmWriter.Close()
}

# Convert byte-level hex to 64-bit word-level for Vivado compatibility
$convertScript = Join-Path $repoRoot "scripts\Convert-VerilogHex.ps1"
if (Test-Path $convertScript) {
    Write-Host "Converting ITCM to 64-bit word-level format..."
    $itcm64 = $itcmOut -replace '\.itcm\.verilog$', '_64bit.itcm.verilog'
    & powershell -NoProfile -ExecutionPolicy Bypass -File $convertScript -InputFile $itcmOut -OutputFile $itcm64 -DataWidth 64
    Write-Host "ITCM 64-bit conversion done: $itcm64"
}

if ((Get-Item $itcmOut).Length -eq 0) {
    throw "No ITCM records found in $verilog"
}

$prepare = Join-Path $repoRoot "scripts\Prepare-Fpga-Install.ps1"
& powershell -NoProfile -ExecutionPolicy Bypass -File $prepare -SocDir $SocDir -Board $Board -AppDir $buildDir -AppName "cnn_accel_demo" -ExtraDefines "E203_FORCE_BOOTROM_BOOT"

Write-Host "CNN_ACCEL_DEMO_ELF=$elf"
Write-Host "CNN_ACCEL_DEMO_VERILOG=$verilog"
Write-Host "CNN_ACCEL_DEMO_ITCM=$itcmOut"
Write-Host "CNN_ACCEL_DEMO_DTCM=$dtcmOut"
