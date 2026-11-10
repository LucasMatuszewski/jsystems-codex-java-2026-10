# Od merge requesta do testu regresji

Sprawdzisz jedną zmianę w jFTP, porównasz uwagi PR-Agent i Codex CLI, a następnie potwierdzisz wybraną uwagę testem. Możesz pracować w przeglądarce. `glab` i Codex CLI są opcjonalne.

## Wejdź do GitLaba

https://gitlab-devpowers.polandcentral.cloudapp.azure.com

Użyj swojego konta szkoleniowego i otwórz merge request podany przez trenera. Do ćwiczenia używamy kodu jFTP i danych syntetycznych.

## Sprawdź zmianę

Założenie do MR: w zwykłym profilu FTP porty od 1 do 65535 mają zostać zachowane, a wartości spoza zakresu mają użyć dotychczasowego portu domyślnego. Zachowanie portu implicit SSL ma pozostać takie jak wcześniej.

1. Wejdź w **Changes** i znajdź warunek w `RemoteHost.setPort`. W **Pipelines** sprawdź status testów i raport JUnit.
2. Dla jednej wartości granicznej zapisz, co ma się stać i co wynika z kodu. Wskaż plik i linię. Dodaj swoją obserwację w dyskusji MR albo podaj ją podczas wspólnego review.
3. Po uruchomieniu jobów `pr-agent-review` i `codex-review` porównaj ich komentarze. Dla jednej uwagi zdecyduj, czy ją przyjmujesz, odrzucasz lub prosisz o dowód. Uzasadnij decyzję konkretnym scenariuszem.
4. Dopisz przypadek regresji do `RemoteHostCharacterizationTest`. Sprawdź, że pada na wersji z MR. Wprowadź najmniejszą poprawkę, uruchom test ponownie i obejrzyj pipeline dla nowego commita.

Jeśli masz klon jFTP i JDK 21, uruchom z katalogu jFTP w PowerShellu:

```powershell
.\mvnw.cmd -B -ntp -Dtest=RemoteHostCharacterizationTest test
```

Na Linuksie użyj `./mvnw` z tymi samymi argumentami. Możesz też sprawdzić wynik w **Pipelines** po aktualizacji MR.

### Prompt do własnego review w Codex

```text
Przejrzyj zmiany bieżącej gałęzi względem master w szkoleniowym jFTP.
W modelu zwykłego profilu FTP porty 1–65535 mają być zachowane.
Wartości spoza zakresu mają użyć dotychczasowego portu domyślnego.
Kontrakt portu implicit SSL pozostaje taki sam.

Sprawdź implementację i istniejące testy. Podaj najwyżej dwie
obserwacje. Dla każdej podaj plik i linię, konkretne wejście,
wynik oczekiwany, wynik wynikający z kodu i minimalny test regresji.
Jeśli nie potrafisz potwierdzić problemu w kodzie, zaznacz to.
Pracuj w trybie odczytu. Odróżnij testy uruchomione od proponowanych.
```

## Opcjonalnie odczytaj MR w glab

Na szkoleniowym GitLabie utwórz osobisty token z zakresem `read_api` i datą ważności do następnego dnia. W osobnym oknie PowerShella otwartym poza firmowym repozytorium uruchom:

```powershell
$env:GLAB_CONFIG_DIR = Join-Path $env:TEMP ("glab-szkolenie-" + [guid]::NewGuid())
$env:GITLAB_HOST = 'gitlab-devpowers.polandcentral.cloudapp.azure.com'
$env:GITLAB_API_HOST = $env:GITLAB_HOST
$env:GLAB_API_PROTOCOL = 'https'
Remove-Item Env:GITLAB_REPO, Env:GITLAB_SUBFOLDER -ErrorAction SilentlyContinue
$env:GITLAB_TOKEN = [Net.NetworkCredential]::new('', (Read-Host 'Token szkoleniowy' -AsSecureString)).Password
glab api user --hostname $env:GITLAB_HOST | ConvertFrom-Json | Select-Object -ExpandProperty username
$repoUrl = Read-Host 'Adres projektu GitLab'
$mrId = Read-Host 'Numer merge requesta bez wykrzyknika'
glab mr view $mrId --repo $repoUrl
```

Token wpisz w ukrytym polu PowerShella. Po ćwiczeniu zamknij okno i unieważnij token w GitLabie. Codex uruchamiaj w oddzielnym terminalu. [Osobne konto Codex CLI](../../README.md#codex-cli-na-koncie-szkoleniowym)
