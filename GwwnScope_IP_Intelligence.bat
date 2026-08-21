@echo off
setlocal EnableExtensions DisableDelayedExpansion
title GwwnScope - IP Intelligence
color 0B
mode con cols=96 lines=48 >nul 2>&1

rem Copyright (c) 2026 CyberGwwn666. All rights reserved.
rem Developer: CyberGwwn666
rem This program performs user-requested IP intelligence lookups.
rem No license is granted to copy, modify, or redistribute this file.

set "POWERSHELL=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if not exist "%POWERSHELL%" (
    echo [ERROR] Windows PowerShell was not found.
    pause
    exit /b 1
)

"%POWERSHELL%" -NoLogo -NoProfile -Command ^
  "$ErrorActionPreference = 'Stop';" ^
  "$width = 78;" ^
  "try { $Host.UI.RawUI.BackgroundColor = 'Black'; $Host.UI.RawUI.ForegroundColor = 'Cyan' } catch {};" ^
  "function Write-Centered {" ^
  "  param([string]$Text, [ConsoleColor]$Color = [ConsoleColor]::Cyan);" ^
  "  $padding = [Math]::Max(0, [int](($width - $Text.Length) / 2));" ^
  "  Write-Host ((' ' * $padding) + $Text) -ForegroundColor $Color;" ^
  "};" ^
  "function Write-Section {" ^
  "  param([string]$Title);" ^
  "  Write-Host;" ^
  "  Write-Host ('[ {0} ]' -f $Title) -ForegroundColor Cyan;" ^
  "  Write-Host ('-' * $width) -ForegroundColor DarkCyan;" ^
  "};" ^
  "function Write-Row {" ^
  "  param([string]$Label, [object]$Value);" ^
  "  if ($null -eq $Value -or [string]::IsNullOrWhiteSpace([string]$Value)) { $Value = 'N/A' };" ^
  "  Write-Host ('{0,-20}: {1}' -f $Label, $Value) -ForegroundColor Cyan;" ^
  "};" ^
  "while ($true) {" ^
  "  Clear-Host;" ^
  "  Write-Host ('=' * $width) -ForegroundColor Cyan;" ^
  "  Write-Centered 'GWWNSCOPE // IP INTELLIGENCE';" ^
  "  Write-Centered 'Developer: CyberGwwn666' DarkCyan;" ^
  "  Write-Centered 'Copyright (c) 2026 CyberGwwn666. All rights reserved.' DarkCyan;" ^
  "  Write-Host ('=' * $width) -ForegroundColor Cyan;" ^
  "  Write-Host;" ^
  "  Write-Host 'Approximate IP intelligence and network-risk analysis.' -ForegroundColor Cyan;" ^
  "  Write-Host;" ^
  "  $target = Read-Host 'Enter an IP/hostname, leave blank for yours, or Q to quit';" ^
  "  if ($target -match '^(?i:q|quit|exit)$') { break };" ^
  "  $escapedTarget = if ([string]::IsNullOrWhiteSpace($target)) { '' } else { [Uri]::EscapeDataString($target.Trim()) };" ^
  "  $fields = 'status,message,continent,continentCode,country,countryCode,region,regionName,city,district,zip,lat,lon,timezone,currency,isp,org,as,asname,reverse,mobile,proxy,hosting,query';" ^
  "  $requestUri = 'http://ip-api.com/json/{0}?fields={1}' -f $escapedTarget, $fields;" ^
  "  try {" ^
  "    $webResponse = Invoke-WebRequest -UseBasicParsing -Uri $requestUri -Method Get -TimeoutSec 15 -ErrorAction Stop;" ^
  "    $result = $webResponse.Content | ConvertFrom-Json;" ^
  "    if ($result.status -ne 'success') {" ^
  "      $reason = if ($result.message) { $result.message } else { 'Lookup rejected by the service' };" ^
  "      throw $reason;" ^
  "    };" ^
  "    $mapsLink = 'https://www.google.com/maps/search/?api=1&query={0},{1}' -f $result.lat, $result.lon;" ^
  "    Write-Section 'LOCATION';" ^
  "    Write-Row 'IP address' $result.query;" ^
  "    Write-Row 'Continent' ('{0} ({1})' -f $result.continent, $result.continentCode);" ^
  "    Write-Row 'Country' ('{0} ({1})' -f $result.country, $result.countryCode);" ^
  "    Write-Row 'Region' ('{0} ({1})' -f $result.regionName, $result.region);" ^
  "    Write-Row 'City / District' ('{0} / {1}' -f $result.city, $result.district);" ^
  "    Write-Row 'Postal code' $result.zip;" ^
  "    Write-Row 'Coordinates' ('{0}, {1}' -f $result.lat, $result.lon);" ^
  "    Write-Row 'Timezone' $result.timezone;" ^
  "    Write-Row 'Currency' $result.currency;" ^
  "    Write-Row 'Google Maps' $mapsLink;" ^
  "    Write-Section 'NETWORK';" ^
  "    Write-Row 'ISP' $result.isp;" ^
  "    Write-Row 'Organization' $result.org;" ^
  "    Write-Row 'ASN / Owner' $result.'as';" ^
  "    Write-Row 'AS name' $result.asname;" ^
  "    Write-Row 'Reverse DNS' $result.reverse;" ^
  "    $riskFlags = @();" ^
  "    if ($result.proxy) { $riskFlags += 'Proxy/VPN/Tor' };" ^
  "    if ($result.hosting) { $riskFlags += 'Hosting/Data center' };" ^
  "    if ($result.mobile) { $riskFlags += 'Mobile network' };" ^
  "    Write-Section 'RISK INDICATORS';" ^
  "    if ($riskFlags.Count -eq 0) {" ^
  "      Write-Host 'No proxy, hosting, or mobile indicator reported.' -ForegroundColor Green;" ^
  "    } else {" ^
  "      Write-Host ('Reported: {0}' -f ($riskFlags -join ', ')) -ForegroundColor Yellow;" ^
  "    };" ^
  "    Write-Host 'Indicators are informational and do not prove malicious activity.' -ForegroundColor DarkCyan;" ^
  "    $remaining = $webResponse.Headers['X-Rl'];" ^
  "    $resetSeconds = $webResponse.Headers['X-Ttl'];" ^
  "    if ($null -ne $remaining) {" ^
  "      Write-Section 'SERVICE STATUS';" ^
  "      Write-Row 'Lookups remaining' $remaining;" ^
  "      Write-Row 'Allowance resets in' ('{0} second(s)' -f $resetSeconds);" ^
  "    };" ^
  "  } catch {" ^
  "    Write-Section 'LOOKUP ERROR';" ^
  "    Write-Host ('{0}' -f $_.Exception.Message) -ForegroundColor Red;" ^
  "    Write-Host 'Check the address, internet connection, or lookup allowance.' -ForegroundColor Yellow;" ^
  "  };" ^
  "  Write-Host;" ^
  "  [void](Read-Host 'Press ENTER for another lookup');" ^
  "}"

set "RESULT=%errorlevel%"
endlocal & exit /b %RESULT%

