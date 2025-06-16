Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Ustaw ścieżkę do folderu skryptu
$scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }

# Ścieżki
$jsonLocalPath = Join-Path -Path $scriptRoot -ChildPath "apps.json"
$downloadPath = "C:\ProgramData\AutoInstall"

# Pobierz apps.json, jeśli nie ma lokalnie
if (-not (Test-Path $jsonLocalPath)) {
    Write-Host "Brak lokalnego apps.json — pobieram z GitHub..."
    $jsonUrl = "https://raw.githubusercontent.com/Kostar-ITMEDO/auto-install-tools/main/apps.json"
    try {
        Invoke-WebRequest -Uri $jsonUrl -OutFile $jsonLocalPath -UseBasicParsing -ErrorAction Stop
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Blad pobierania apps.json:`n$_", "Blad")
        exit
    }
}

# Utwórz folder cache, jeśli nie istnieje
if (-not (Test-Path $downloadPath)) {
    New-Item -ItemType Directory -Path $downloadPath -Force | Out-Null
}

# Wczytaj listę aplikacji
$apps = Get-Content $jsonLocalPath | ConvertFrom-Json

# Utwórz GUI
$form = New-Object System.Windows.Forms.Form
$form.Text = "Auto Install Tools"
$form.Size = New-Object System.Drawing.Size(420, 500)
$form.StartPosition = "CenterScreen"

$listbox = New-Object System.Windows.Forms.CheckedListBox
$listbox.Size = New-Object System.Drawing.Size(380, 350)
$listbox.Location = New-Object System.Drawing.Point(15, 15)
$listbox.CheckOnClick = $true

foreach ($app in $apps) {
    $listbox.Items.Add($app.name)
}

$btnDownload = New-Object System.Windows.Forms.Button
$btnDownload.Text = "Pobierz / Aktualizuj"
$btnDownload.Size = New-Object System.Drawing.Size(170, 40)
$btnDownload.Location = New-Object System.Drawing.Point(15, 380)

$btnInstall = New-Object System.Windows.Forms.Button
$btnInstall.Text = "Zainstaluj"
$btnInstall.Size = New-Object System.Drawing.Size(170, 40)
$btnInstall.Location = New-Object System.Drawing.Point(225, 380)

$progress = New-Object System.Windows.Forms.ProgressBar
$progress.Size = New-Object System.Drawing.Size(380, 20)
$progress.Location = New-Object System.Drawing.Point(15, 430)
$progress.Minimum = 0
$progress.Maximum = 100
$progress.Value = 0

$form.Controls.Add($listbox)
$form.Controls.Add($btnDownload)
$form.Controls.Add($btnInstall)
$form.Controls.Add($progress)

# Funkcja pobierania instalatora
function Invoke-DownloadInstaller($app) {
    $filename = [System.IO.Path]::GetFileName($app.url)
    $localPath = Join-Path $downloadPath $filename

    try {
        Write-Host "Pobieranie $($app.name)..."
        Invoke-WebRequest -Uri $app.url -OutFile $localPath -UseBasicParsing -ErrorAction Stop
        return $localPath
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Blad pobierania $($app.name): `n$_", "Blad")
        return $null
    }
}

# Obsługa kliknięcia Pobierz / Aktualizuj
$btnDownload.Add_Click({
    $selectedApps = @()
    for ($i = 0; $i -lt $listbox.Items.Count; $i++) {
        if ($listbox.GetItemChecked($i)) {
            $selectedApps += $apps[$i]
        }
    }

    if ($selectedApps.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Nie wybrano zadnych aplikacji do pobrania.", "Uwaga")
        return
    }

    $progress.Value = 0
    $step = [Math]::Floor(100 / $selectedApps.Count)

    foreach ($app in $selectedApps) {
        $result = Invoke-DownloadInstaller $app
        if ($result) {
            $progress.Value += $step
        }
    }
    $progress.Value = 100
    [System.Windows.Forms.MessageBox]::Show("Instalacja zakonczona.", "Gotowe")
})

# Obsługa kliknięcia Zainstaluj
$btnInstall.Add_Click({
    $selectedApps = @()
    for ($i = 0; $i -lt $listbox.Items.Count; $i++) {
        if ($listbox.GetItemChecked($i)) {
            $selectedApps += $apps[$i]
        }
    }

    if ($selectedApps.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Nie wybrano zadnych aplikacji do instalacji.", "Uwaga")
        return
    }

    foreach ($app in $selectedApps) {
        $filename = [System.IO.Path]::GetFileName($app.url)
        $localPath = Join-Path $downloadPath $filename

        if (-not (Test-Path $localPath)) {
            [System.Windows.Forms.MessageBox]::Show("Plik instalatora nie istnieje:`n$localPath`nNajpierw pobierz plik.", "Blad")
            return
        }

        try {
            if ($localPath -like "*.msi") {
                Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$localPath`" $($app.args)" -Wait -NoNewWindow
            } else {
                Start-Process -FilePath $localPath -ArgumentList $app.args -Wait -NoNewWindow
            }
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Blad podczas instalacji $($app.name): `n$_", "Blad")
        }
    }
    [System.Windows.Forms.MessageBox]::Show("Instalacja zakonczona.", "Gotowe")
})

$form.Topmost = $true
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
