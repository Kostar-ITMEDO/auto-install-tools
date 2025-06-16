# Skrypt instalacyjny PowerShell
$apps = Get-Content -Raw -Path "$PSScriptRoot\apps.json" | ConvertFrom-Json
$DownloadDir = "$env:TEMP\AppInstall"

if (-not (Test-Path $DownloadDir)) {
    New-Item -Path $DownloadDir -ItemType Directory | Out-Null
}

foreach ($app in $apps) {
    $exeName = Split-Path $app.url -Leaf
    $destPath = Join-Path $DownloadDir $exeName

    Write-Host "Pobieranie $($app.name)..."
    Invoke-WebRequest -Uri $app.url -OutFile $destPath -UseBasicParsing

    Write-Host "Instalacja $($app.name)..."
    Start-Process -FilePath $destPath -ArgumentList $app.args -Wait

    Write-Host "$($app.name) zainstalowany.`n"
}

Write-Host "Wszystkie aplikacje zostały zainstalowane."
