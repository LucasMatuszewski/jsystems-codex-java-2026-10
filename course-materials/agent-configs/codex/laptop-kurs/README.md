# Kurs na własnym laptopie: osobny profil Codex

Plan B, gdy VM szkoleniowa działa zbyt wolno. Skrypt [Start-CodexKurs.ps1](Start-CodexKurs.ps1) otwiera osobne okno PowerShell "Codex KURS", w którym Codex, VS Code, glab i Git zapisują wszystko w `%USERPROFILE%\CodexKurs`. Twoje firmowe ustawienia zostają bez zmian: `%USERPROFILE%\.codex`, zwykły VS Code, logowanie glab i globalny `.gitconfig`. Skrypt nie zmienia `$PROFILE` ani zmiennych środowiskowych użytkownika i systemu.

Najpierw sprawdź politykę firmy. Jeśli IT może przygotować osobne konto Windows do szkolenia, to jest bezpieczniejsza opcja.

## Co jest rozdzielone, a co nie

| Rozdzielone (folder `CodexKurs`) | Nie jest rozdzielone |
|---|---|
| logowanie Codex (`auth.json` w pliku), historia, konfiguracja, baza SQLite | konto Windows: agent może czytać pliki poza folderem kursu, sandbox ogranicza głównie zapis |
| ustawienia i rozszerzenia VS Code tej instancji | aplikacja ChatGPT Desktop i IntelliJ: nie przelogowuj ich na konto szkoleniowe |
| logowanie glab do GitLab szkoleniowego | przeglądarka: do logowania użyj osobnego profilu lub okna prywatnego |
| zapisy do globalnej konfiguracji Git (Twój `.gitconfig` jest tylko czytany) | menedżer poświadczeń Windows i klucze SSH |

W oknie KURS otwieraj wyłącznie repozytoria szkoleniowe z `%USERPROFILE%\CodexKurs\repos`. Nie otwieraj tam repozytoriów firmowych.

## Uruchomienie

Wymagane: Git, Codex CLI, glab, VS Code (`code` w PATH). Pobierz skrypt:

```powershell
Invoke-WebRequest -UseBasicParsing -OutFile "$HOME\Downloads\Start-CodexKurs.ps1" -Uri https://raw.githubusercontent.com/LucasMatuszewski/jsystems-codex-java-2026-10/main/course-materials/agent-configs/codex/laptop-kurs/Start-CodexKurs.ps1
```

Sprawdź stan bez otwierania okien:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME\Downloads\Start-CodexKurs.ps1" -Check
```

Otwórz okno KURS i osobną instancję VS Code z rozszerzeniem Codex (instaluje się tylko w folderze kursu):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME\Downloads\Start-CodexKurs.ps1" -VSCode
```

W oknie KURS zaloguj Codex na konto szkoleniowe i sprawdź status. W przeglądarce upewnij się, że wybrane jest konto szkoleniowe, nie firmowe:

```powershell
codex login
```

```powershell
codex login status
```

Logowanie glab i repozytoria: jak w [ćwiczeniu Cargo Tracker](../../../exercises/cargo-tracker.md), w oknie KURS. Następnego dnia uruchom ten sam skrypt: foldery i logowanie zostają.

## Sprawdzenie przed pierwszym promptem

1. W oknie KURS `$env:CODEX_HOME` wskazuje `...\CodexKurs\codex-home`.
2. W VS Code: Codex, ustawienia, "Open config.toml" otwiera plik z folderu kursu; brak starych rozmów.
3. W terminalu VS Code `$env:CODEX_HOME` pokazuje tę samą ścieżkę.
4. `/status` w Codex pokazuje konto szkoleniowe.

## Po kursie

Zamknij okna KURS i instancję VS Code kursu, potem usuń folder:

```powershell
Remove-Item -Recurse -Force "$HOME\CodexKurs"
```

Sprawdzono 29.10.2026 na Windows 11 (PowerShell 5.1): osobny `CODEX_HOME` startuje bez logowania, rozszerzenie `openai.chatgpt` 26.1021.22027 instaluje się w osobnym katalogu. Okno i VS Code uruchamiane z interfejsem graficznym trzeba jeszcze przećwiczyć na docelowym laptopie. Skrypt jest zapisany jako UTF-8 z BOM, bo Windows PowerShell 5.1 bez BOM błędnie czyta polskie znaki.
