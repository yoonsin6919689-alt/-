param(
  [string]$RepoDir = (Join-Path $env:USERPROFILE 'Downloads\Legacy-Party-Pack'),
  [string]$ServerDir = (Join-Path $env:USERPROFILE 'Downloads\26.2-199'),
  [string]$RawBase = 'https://raw.githubusercontent.com/yoonsin6919689-alt/-/main'
)

$ErrorActionPreference = 'Stop'

$props    = Join-Path $ServerDir 'server.properties'
$pack     = Join-Path $RepoDir 'legacy-party-pack.zip'
$mobile   = Join-Path $RepoDir 'legacy-mobile-pack.zip'
$mappings = Join-Path $RepoDir 'geyser\custom_mappings'
$geyser   = Join-Path $ServerDir 'plugins\Geyser-Spigot'

if (-not (Test-Path $pack))  { throw "resource pack not found: $pack" }
if (-not (Test-Path $props)) { throw "server.properties not found: $props" }

$sha1 = (Get-FileHash -Algorithm SHA1 -Path $pack).Hash
Write-Host "SHA1: $sha1"

$enc = New-Object System.Text.UTF8Encoding($false)
$lines = [System.IO.File]::ReadAllLines($props, $enc)
$packUrl = "$RawBase/legacy-party-pack.zip"
$hasPack = $false
for ($i = 0; $i -lt $lines.Count; $i++) {
  if ($lines[$i] -match '^resource-pack=') {
    $lines[$i] = "resource-pack=$packUrl"
    $hasPack = $true
  } elseif ($lines[$i] -match '^resource-pack-sha1=') {
    $lines[$i] = "resource-pack-sha1=$sha1"
  }
}
if (-not $hasPack) { $lines += "resource-pack=$packUrl" }
[System.IO.File]::WriteAllLines($props, $lines, $enc)
Write-Host "server.properties updated: $packUrl"

if (Test-Path $geyser) {
  $mapDir = Join-Path $geyser 'custom_mappings'
  New-Item -ItemType Directory -Force -Path $mapDir | Out-Null
  Copy-Item (Join-Path $mappings '*.json') $mapDir -Force
  Write-Host "Geyser custom mappings copied"

  $cfgPath = Join-Path $geyser 'config.yml'
  if (Test-Path $cfgPath) {
    $mobileUrl = "$RawBase/legacy-mobile-pack.zip"
    $cfg = [System.IO.File]::ReadAllLines($cfgPath, $enc)
    $out = New-Object 'System.Collections.Generic.List[string]'
    $skipping = $false
    $done = $false
    foreach ($line in $cfg) {
      if ($skipping) {
        if ($line -match '^\s+-\s') { continue }
        $skipping = $false
      }
      if ($line -match '^\s{2}resource-pack-urls:') {
        $out.Add('  resource-pack-urls:')
        $out.Add('    - "' + $mobileUrl + '"')
        $done = $true
        $skipping = $true
        continue
      }
      $out.Add($line)
    }
    if (-not $done) {
      $out.Add('  resource-pack-urls:')
      $out.Add('    - "' + $mobileUrl + '"')
    }
    [System.IO.File]::WriteAllLines($cfgPath, $out, $enc)
    Write-Host "Geyser config updated: $mobileUrl"
  }
} else {
  Write-Host "[WARN] Geyser folder not found: $geyser"
}

$dl = Join-Path $env:USERPROFILE 'Downloads\legacy-mobile-pack.mcpack'
Copy-Item $mobile $dl -Force
Write-Host "Bedrock pack copied: $dl"
