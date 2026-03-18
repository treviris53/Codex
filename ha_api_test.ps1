<#
Purpose:
  Minimal read-only test against Home Assistant REST API.

Where to place:
  D:\codex\tools\ha_api_test.ps1

Usage example:
  $env:HA_URL = "http://homeassistant.local:8123"
  $env:HA_TOKEN = "YOUR_LONG_LIVED_ACCESS_TOKEN"
  powershell -ExecutionPolicy Bypass -File .\tools\ha_api_test.ps1
#>

param(
    [string]$HaUrl = $env:HA_URL,
    [string]$Token = $env:HA_TOKEN
)

if ([string]::IsNullOrWhiteSpace($HaUrl)) {
    throw "HA URL fehlt. Setze HA_URL, z. B. http://homeassistant.local:8123"
}

if ([string]::IsNullOrWhiteSpace($Token)) {
    throw "HA Token fehlt. Setze HA_TOKEN mit einem Long-Lived Access Token."
}

$headers = @{
    Authorization = "Bearer $Token"
    "Content-Type" = "application/json"
}

try {
    $uri = "$HaUrl/api/"
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers
    Write-Host "Verbindung erfolgreich. API Meldung:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 5
}
catch {
    Write-Error "API-Test fehlgeschlagen: $($_.Exception.Message)"
    exit 1
}