$downloadPath = "$env:USERPROFILE\Downloads\AppInstall"
if (-not (Test-Path $downloadPath)) {
    New-Item -ItemType Directory -Path $downloadPath -Force | Out-Null
}

$apps = @(
    @{
        name = "OpenOffice"
        url = "https://downloads.sourceforge.net/project/openofficeorg.mirror/4.1.15/binaries/pl/Apache_OpenOffice_4.1.15_Win_x86_install_pl.exe"
    },
    @{
        name = "Adobe Reader"
        url = "https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/2400620363/AcroRdrDCx642400620363_pl_PL.exe"
    },
    @{
        name = "Java (JRE)"
        url = "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.11+9/OpenJDK17U-jre_x64_windows_hotspot_17.0.11_9.msi"
    }
)

foreach ($app in $apps) {
    try {
        $fileName = Split-Path $app.url -Leaf
        $target = Join-Path $downloadPath $fileName

        Write-Host "Pobieranie $($app.name) do $target..."
        Invoke-WebRequest -Uri $app.url -OutFile $target -UseBasicParsing

        if (Test-Path $target) {
            $size = (Get-Item $target).Length / 1MB
            Write-Host "✅ Pobrano: $($app.name) ($([math]::Round($size,2)) MB)"
        } else {
            Write-Host "❌ NIE pobrano: $($app.name)"
        }
    } catch {
        Write-Host "❌ Błąd przy pobieraniu $($app.name): $_"
    }
}
