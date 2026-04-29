param(
    [Parameter(Mandatory=$true)]
    [string]$InputFile,
    [Parameter(Mandatory=$true)]
    [string]$OutputFile,
    [int]$DataWidth = 64  # Default 64-bit for E203 ITCM
)

# Convert byte-level Verilog hex to word-level format
# Input: "@00000000\n17 01 01 10 13 01 01 00 ..."
# Output: 64-bit hex words, one per line

$bytes = @()
$addrMode = $false
foreach ($line in Get-Content $InputFile) {
    $line = $line.Trim()
    if ($line.StartsWith("@")) {
        $addrMode = $true
        continue
    }
    if ($line -eq "") { continue }
    $tokens = $line -split '\s+'
    foreach ($t in $tokens) {
        if ($t -match '^[0-9a-fA-F]+$') {
            $bytes += [byte]::Parse($t, [System.Globalization.NumberStyles]::HexNumber)
        }
    }
}

# Convert bytes to 32-bit little-endian words
$words32 = @()
for ($i = 0; $i -lt $bytes.Count; $i += 4) {
    $b0 = [uint32]$bytes[$i]
    $b1 = if ($i+1 -lt $bytes.Count) { [uint32]$bytes[$i+1] } else { [uint32]0 }
    $b2 = if ($i+2 -lt $bytes.Count) { [uint32]$bytes[$i+2] } else { [uint32]0 }
    $b3 = if ($i+3 -lt $bytes.Count) { [uint32]$bytes[$i+3] } else { [uint32]0 }
    $word = $b0 -bor ($b1 -shl 8) -bor ($b2 -shl 16) -bor ($b3 -shl 24)
    $words32 += $word
}

# Pack into target-width words (64-bit = 2x 32-bit)
$bytesPerWord = $DataWidth / 8
$words32PerLine = $bytesPerWord / 4
$writer = [System.IO.StreamWriter]::new($OutputFile, $false, [System.Text.Encoding]::ASCII)
try {
    for ($i = 0; $i -lt $words32.Count; $i += $words32PerLine) {
        $lo = $words32[$i]
        $hi = if ($i+1 -lt $words32.Count) { [uint64]$words32[$i+1] } else { [uint64]0 }
        $w64 = [uint64]$lo -bor ($hi -shl 32)
        $writer.WriteLine($w64.ToString("X16"))
    }
} finally {
    $writer.Close()
}

Write-Host "Converted $($words32.Count) 32-bit words to $( [math]::Ceiling($words32.Count / $words32PerLine) ) $DataWidth-bit words"
Write-Host "Output: $OutputFile"
