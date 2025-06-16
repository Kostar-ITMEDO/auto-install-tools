Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Ustawienie sciezki do folderu skryptu lub fallback do katalogu bieżącego
$scriptRoot = if ($PSScriptRoot) {
    $PSScriptRoot
} elseif ($MyInvocation.MyCommand.Path) {
    Split-Path -Parent $MyInvocation.MyCommand.Path
} else {
    (Get-Location).Path
}

# Sciezki
$jsonLocalPath = Join-Path -Path $scriptRoot -ChildPath "apps.json"
$downloadPath = "C:\ProgramData\AutoInstall"

# Pobierz apps.json, jeśli nie ma lokalnie
if (-not (Test-Path $jsonLocalPath)) {
    Write-Host "No local apps.json found. Downloading from GitHub..."
    $jsonUrl = "https://raw.githubusercontent.com/Kostar-ITMEDO/auto-install-tools/main/apps.json"
    try {
        Invoke-WebRequest -Uri $jsonUrl -OutFile $jsonLocalPath -UseBasicParsing -ErrorAction Stop
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Error downloading apps.json:`n$_", "Error")
        exit
    }
}

# Utworz folder cache, jesli nie istnieje
if (-not (Test-Path $downloadPath)) {
    New-Item -ItemType Directory -Path $downloadPath -Force | Out-Null
}

# Wczytaj liste aplikacji
$apps = Get-Content $jsonLocalPath | ConvertFrom-Json

# Tworzenie GUI
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
$btnDownload.Text = "Download / Update"
$btnDownload.Size = New-Object System.Drawing.Size(170, 40)
$btnDownload.Location = New-Object System.Drawing.Point(15, 380)

$btnInstall = New-Object System.Windows.Forms.Button
$btnInstall.Text = "Install"
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

function Invoke-DownloadInstaller($app) {
    $filename = [System.IO.Path]::GetFileName($app.url)
    $localPath = Join-Path $downloadPath $filename

    try {
        Write-Host "Downloading $($app.name)..."
        Invoke-WebRequest -Uri $app.url -OutFile $localPath -UseBasicParsing -ErrorAction Stop
        return $localPath
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Error downloading $($app.name): `n$_", "Error")
        return $null
    }
}

$btnDownload.Add_Click({
    $selectedApps = @()
    for ($i = 0; $i -lt $listbox.Items.Count; $i++) {
        if ($listbox.GetItemChecked($i)) {
            $selectedApps += $apps[$i]
        }
    }

    if ($selectedApps.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("No apps selected for download.", "Warning")
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
    [System.Windows.Forms.MessageBox]::Show("Download complete.", "Done")
})

$btnInstall.Add_Click({
    $selectedApps = @()
    for ($i = 0; $i -lt $listbox.Items.Count; $i++) {
        if ($listbox.GetItemChecked($i)) {
            $selectedApps += $apps[$i]
        }
    }

    if ($selectedApps.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("No apps selected for install.", "Warning")
        return
    }

    foreach ($app in $selectedApps) {
        $filename = [System.IO.Path]::GetFileName($app.url)
        $localPath = Join-Path $downloadPath $filename

        if (-not (Test-Path $localPath)) {
            [System.Windows.Forms.MessageBox]::Show("Installer file not found:`n$localPath`nPlease download first.", "Error")
            return
        }

        try {
            if ($localPath -like "*.msi") {
                Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$localPath`" $($app.args)" -Wait -NoNewWindow
            }
            else {
                Start-Process -FilePath $localPath -ArgumentList $app.args -Wait -NoNewWindow
            }
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("Error installing $($app.name): `n$_", "Error")
        }
    }

    [System.Windows.Forms.MessageBox]::Show("Installation complete.", "Done")
})

$form.Topmost = $true
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
