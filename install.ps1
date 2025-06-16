Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Ścieżki
$jsonPath = Join-Path -Path $PSScriptRoot -ChildPath "apps.json"

if (-not (Test-Path $jsonPath)) {
    [System.Windows.Forms.MessageBox]::Show("Brak pliku apps.json", "Błąd")
    exit
}

$apps = Get-Content $jsonPath | ConvertFrom-Json

# Tworzenie GUI
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
        [System.Windows.Forms.MessageBox]::Show("Nie wybrano żadnych aplikacji.", "Uwaga")
        return
    }

    foreach ($app in $selectedApps) {
        try {
            $localPath = Join-Path -Path $PSScriptRoot -ChildPath $app.url
            if (-not (Test-Path $localPath)) {
                throw "Plik nie istnieje: $localPath"
            }

            Write-Host "Instalacja $($app.name)..."
            Start-Process -FilePath $localPath -ArgumentList $app.args -Wait -NoNewWindow
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Błąd podczas instalacji $($app.name): `n$_", "Błąd")
        }
    }

    explorer.exe (Join-Path $PSScriptRoot "AppInstaller")
    [System.Windows.Forms.MessageBox]::Show("Zakończono instalację wybranych programów.`nFolder instalatorów został otwarty.", "Gotowe")
    $form.Close()
})

$form.Controls.Add($listbox)
$form.Controls.Add($button)
$form.Topmost = $true
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
