Add-Type -AssemblyName System.Windows.Forms

Write-Host "Test dziala"

[System.Windows.Forms.MessageBox]::Show("Test zakonczony", "Info")
