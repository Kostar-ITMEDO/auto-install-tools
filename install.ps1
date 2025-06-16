Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Własna zmienna ścieżki
$scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }

# Sciezki
$jsonPath = Join-Path -Path $scriptRoot -ChildPath "apps.json"
$downloadPath = Join-Path $env:USERPROFILE "Downloads\AutoInstallers"


# Pobierz apps.json z GitHuba, jeśli go nie ma lokalnie
if (-not (Test-Path $jsonPath)) {
    Write-Host "Brak lokalnego apps.json – pobieranie z GitHuba..."
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Kostar-ITMEDO/auto-install-tools/main/apps.json" -OutFile $jsonPath -UseBasicParsing
}

if (-not (Test-Path $downloadPath)) {
    New-Item -ItemType Directory -Path $downloadPath | Out-Null
}

$apps = Get-Content $jsonPath | ConvertFrom-Json

# GUI
$form = New-Object System.Windows.Forms.Form
$form.Text = "Auto Install Tools"
$form.Size = New-Object System.Drawing.Size(400, 450)
$form.StartPosition = "CenterScreen"

$listbox = New-Object System.Windows.Forms.CheckedListBox
$listbox.Size = New-Object System.Drawing.Size(360, 300)
$listbox.Location = New-Object System.Drawing.Point(10, 10)
$listbox.CheckOnClick = $true

foreach ($app in $apps) {
    $listbox.Items.Add($app.name)
}

$button = New-Object System.Windows.Forms.Button
$button.Text = "Zainstaluj"
$button.Location = New-Object System.Drawing.Point(150, 330)
$button.Size = New-Object System.Drawing.Size(100, 30)

$button.Add_Click({
    $selectedApps = @()
    foreach ($i in 0..($listbox.Items.Count - 1)) {
        if ($listbox.GetItemChecked($i)) {
            $selectedApps += $apps[$i]
        }
    }

    if ($selectedApps.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Nie wybrano zadnych aplikacji.", "Uwaga")
        return
    }

    foreach ($app in $selectedApps) {
        try {
            if ($app.url -like "http*") {
                $filename = [System.IO.Path]::GetFileName($app.url)
                $localPath = Join-Path $downloadPath $filename

                Write-Host "Pobieranie $($app.name) do $localPath..."
                Invoke-WebRequest -Uri $app.url -OutFile $localPath -UseBasicParsing
            } else {
                $localPath = Join-Path $PSScriptRoot $app.url
                if (-not (Test-Path $localPath)) {
                    throw "Plik nie istnieje: $localPath"
                }
            }

            Write-Host "Instalacja $($app.name)..."

            if ($localPath -like "*.msi") {
                Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$localPath`" $($app.args)" -Wait -NoNewWindow
            } else {
                Start-Process -FilePath $localPath -ArgumentList $app.args -Wait -NoNewWindow
            }
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Blad podczas instalacji $($app.name): `n$_", "Blad")
        }
    }

    explorer.exe $downloadPath
    [System.Windows.Forms.MessageBox]::Show("Installation of selected programs finished.`nInstaller folder has been opened.", "Done")
    $form.Close()
})

$form.Controls.Add($listbox)
$form.Controls.Add($button)
$form.Topmost = $true
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
