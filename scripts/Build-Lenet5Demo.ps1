param(
    [string]$GccRoot = "D:\Xilinx\Vitis\2023.2\gnu\riscv\nt\riscv64-unknown-elf",
    [string]$SocDir = "C:\Users\16084\Documents\New project\e203_hbirdv2",
    [string]$Board = "davinci_a7_100t"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$srcDir = Join-Path $repoRoot "sw\lenet5_demo"
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

# Also check that include files exist
$incDir = Join-Path $repoRoot "sw\inc"
foreach ($inc in @("custom_insn.h", "lenet5_weights.h", "lenet5_shifts.h", "mnist_test_images.h")) {
    $incPath = Join-Path $incDir $inc
    if (-not (Test-Path $incPath)) {
        throw "Required include not found: $incPath"
    }
}

New-Item -ItemType Directory -Force -Path $buildDir | Out-Null

$elf = Join-Path $buildDir "lenet5.elf"
$verilog = Join-Path $buildDir "lenet5.verilog"
$dump = Join-Path $buildDir "lenet5.dump"
$map = Join-Path $buildDir "lenet5.map"
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
    "-I", (Get-ShortPath $incDir),
    $startupArg,
    $mainArg
)

Write-Host "Compiling LeNet-5 firmware..."
Write-Host "GCC: $gcc"
Write-Host "Source: $main"
Write-Host "Linker: $linker"

& $gcc @gccArgs
if ($LASTEXITCODE -ne 0) {
    throw "GCC failed with exit code $LASTEXITCODE"
}

Write-Host "GCC compilation successful."

# Check ELF section sizes with objdump
$sizeInfo = & $objdump "-h" $elfArg 2>&1
Write-Host "ELF sections:"
foreach ($line in $sizeInfo) {
    if ($line -match "\.(text|rodata|data|bss)") {
        Write-Host "  $line"
    }
}

$elfSize = (Get-Item $elfArg).Length
Write-Host "ELF file size: $elfSize bytes"

# Generate verilog hex
& $objcopy "-O" "verilog" $elfArg (Get-ShortPath $verilog)
if ($LASTEXITCODE -ne 0) {
    throw "objcopy failed with exit code $LASTEXITCODE"
}

# Generate disassembly
& $objdump "-d" $elfArg | Set-Content -Encoding ASCII $dump
if ($LASTEXITCODE -ne 0) {
    throw "objdump failed with exit code $LASTEXITCODE"
}

# Split ITCM/DTCM
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

$itcmSize = (Get-Item $itcmOut).Length
$dtcmSize = (Get-Item $dtcmOut).Length
Write-Host "ITCM hex size: $itcmSize bytes"
Write-Host "DTCM hex size: $dtcmSize bytes"

# Convert to 64-bit word format
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

# Install to SoC FPGA tree
$prepare = Join-Path $repoRoot "scripts\Prepare-Fpga-Install.ps1"
& powershell -NoProfile -ExecutionPolicy Bypass -File $prepare -SocDir $SocDir -Board $Board -AppDir $buildDir -AppName "lenet5" -ExtraDefines "E203_FORCE_BOOTROM_BOOT"

Write-Host "LENET5_ELF=$elf"
Write-Host "LENET5_VERILOG=$verilog"
Write-Host "LENET5_ITCM=$itcmOut"
Write-Host "LENET5_DTCM=$dtcmOut"
Write-Host ""
Write-Host "Next step: Build FPGA bitstream"
Write-Host "  powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Invoke-Vivado-Fpga.ps1 -BuildMode cnn_sysclk_ila -Action bit"
