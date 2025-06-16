# 🛠 auto-install-tools

Narzędzie dla serwisantów do szybkiej instalacji popularnych aplikacji po świeżej instalacji Windowsa.  
Umożliwia **graficzny wybór** aplikacji do zainstalowania z aktualnych źródeł internetowych.


iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Kostar-ITMEDO/auto-install-tools/main/install.ps1'))

---

## ✅ Jak używać?

1. **Skopiuj pliki na pendrive lub uruchom z folderu lokalnego**.
2. Uruchom `install.ps1` jako **Administrator** (prawy przycisk → „Uruchom jako Administrator”).
3. Wybierz z listy aplikacje do zainstalowania.
4. Skrypt automatycznie pobierze i zainstaluje wybrane programy.

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
