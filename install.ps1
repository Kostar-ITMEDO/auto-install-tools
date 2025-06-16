Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Pobierz apps.json z GitHuba
$appsUrl = "https://raw.githubusercontent.com/Kostar-ITMEDO/auto-install-tools/main/apps.json"
Write-Host "Załadowano aplikacji: $($apps.Count)"
foreach ($a in $apps) {
    Write-Host " - $($a.name)"
}

try {
    $appsJson = Invoke-WebRequest -Uri $appsUrl -UseBasicParsing | Select-Object -ExpandProperty Content
    $apps = $appsJson | ConvertFrom-Json
} catch {
    [System.Windows.Forms.MessageBox]::Show("Nie udało się pobrać listy aplikacji (`apps.json`). Sprawdź połączenie internetowe lub dostępność repozytorium.")
    exit
}

# Ścieżka do folderu pobranych instalatorów
$downloadPath = Join-Path "$env:USERPROFILE\Downloads" "AppInstall"
if (-not (Test-Path $downloadPath)) {
    New-Item -ItemType Directory -Path $downloadPath -Force | Out-Null
}

# GUI – formularz do wyboru aplikacji
$form = New-Object System.Windows.Forms.Form
$form.Text = "Wybierz programy do instalacji"
$form.Size = New-Object System.Drawing.Size(400,450)
$form.StartPosition = "CenterScreen"

$checkedList = New-Object System.Windows.Forms.CheckedListBox
$checkedList.Size = New-Object System.Drawing.Size(360,300)
$checkedList.Location = New-Object System.Drawing.Point(10,10)
$checkedList.CheckOnClick = $true

foreach ($app in $apps) {
    $checkedList.Items.Add($app.name)
}
$form.Controls.Add($checkedList)

$button = New-Object System.Windows.Forms.Button
$button.Text = "Zainstaluj"
$button.Location = New-Object System.Drawing.Point(150, 330)
$form.Controls.Add($button)

# Obsługa kliknięcia "Zainstaluj"
$button.Add_Click({
    $selectedApps = @()
    foreach ($index in $checkedList.CheckedIndices) {
        $selectedApps += $apps[$index]
    }

    if ($selectedApps.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Nie wybrano żadnych programów.")
    } else {
        $form.Close()

        foreach ($app in $selectedApps) {
            try {
                $exeName = Split-Path $app.url -Leaf
                $installerPath = Join-Path $downloadPath $exeName

                Write-Host "Pobieranie $($app.name)..."
                Invoke-WebRequest -Uri $app.url -OutFile $installerPath -UseBasicParsing

                Write-Host "Instalacja $($app.name)..."
                Start-Process -FilePath $installerPath -ArgumentList $app.args -Wait

                Write-Host "$($app.name) zainstalowany.`n"
            } catch {
                Write-Host "Błąd podczas instalacji $($app.name): $_"
            }
        }

        [System.Windows.Forms.MessageBox]::Show("Zakonczono instalacje wybranych programow.`nFolder instalatorow zostanie otwarty.")
        Start-Process explorer $downloadPath
    }
})

$form.Topmost = $true
$form.Add_Shown({ $form.Activate() })
$form.ShowDialog()

