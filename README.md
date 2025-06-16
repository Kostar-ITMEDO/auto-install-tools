# 🛠 auto-install-tools

Narzędzie dla serwisantów do szybkiej instalacji popularnych aplikacji po świeżej instalacji Windowsa.  
Umożliwia **graficzny wybór** aplikacji do zainstalowania z aktualnych źródeł internetowych.

---

## ✅ Jak uruchomić skrypt instalacyjny PowerShell z pendrive’a — krok po kroku

### 2. Otwórz PowerShell jako administrator

- Kliknij **Start**  
- Wpisz **PowerShell**  
- Kliknij prawym przyciskiem i wybierz **Uruchom jako administrator**

### 3. Przejdź do litery pendrive’a

- Sprawdź, pod jaką literą jest Twój pendrive (np. `E:`)  
- Wpisz w PowerShell:

```powershell
E:
(zamień E: na właściwą literę)

4. Wejdź do folderu, w którym jest skrypt
Przykład: jeśli masz folder AutoInstall na pendrive, wpisz:

powershell
Kopiuj
cd .\AutoInstall\
Sprawdź, czy w tym folderze masz install.ps1 i apps.json:

powershell
Kopiuj
dir
5. Uruchom skrypt z odpowiednią polityką wykonania
Aby ominąć ograniczenia polityki PowerShell, wpisz:

powershell
Kopiuj
powershell -ExecutionPolicy Bypass -File .\install.ps1
6. Korzystaj z GUI
Pojawi się okno z listą aplikacji

Zaznacz aplikacje, które chcesz pobrać (Download / Update)

Po pobraniu kliknij Install dla wybranych aplikacji

7. Po instalacji
Możesz zamknąć okno i odłączyć pendrive

Instalatory są zapisywane w C:\ProgramData\AutoInstall (ukryty)

---

## 📦 Co zawiera?

- Apache OpenOffice
- 7-Zip
- Adobe Acrobat Reader
- Java (JRE)
- Mozilla Firefox
- Google Chrome
- TeamViewer
- AnyDesk

---

## 💡 Wymagania

- Połączenie z Internetem (wersja online),
- PowerShell 5.1+ (standard w Windows 10/11),
- Uprawnienia administratora.

---

## 📝 Jak dodać własne aplikacje?

Edytuj plik `apps.json`, np.:

```json
{
  "name": "NowyProgram",
  "url": "https://adres-do-instalki.exe",
  "args": "/silent"
}

