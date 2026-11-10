# Od merge requesta do testu regresji

Sprawdzisz jedną zmianę w jFTP, porównasz uwagi PR-Agent i Codex CLI, a następnie potwierdzisz wybraną uwagę testem. Możesz pracować w przeglądarce. `glab` i Codex CLI są opcjonalne.

## Wejdź do GitLaba

https://gitlab-devpowers.polandcentral.cloudapp.azure.com

Użyj swojego konta szkoleniowego. Otwórz wspólny merge request.

https://gitlab-devpowers.polandcentral.cloudapp.azure.com/lucas/dogrywka-jftp/-/merge_requests/1

Do ćwiczenia używamy kodu jFTP i danych syntetycznych.

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

## glab na koncie szkoleniowym w PowerShellu

### 1. Pobierz materiały z GitHuba

Otwórz PowerShell. Potrzebujesz zainstalowanych Git i `glab`.

```powershell
git clone https://github.com/LucasMatuszewski/jsystems-codex-java-2026-10.git
cd jsystems-codex-java-2026-10
```

Jeśli masz już to repozytorium, wejdź do jego katalogu i wykonaj `git pull`. Zawiera ono instrukcje oraz launchery.

### 2. Uruchom gotowy plik

```powershell
.\glab-szkolenie.ps1
```

Plik jest już w repozytorium, obok `codex-szkolenie.ps1`. Wszystkie adresy i projekt są wpisane. W ukrytym polu wklej wyłącznie swój token szkoleniowego GitLaba otrzymany od trenera. Jeżeli tworzysz nowy token samodzielnie, do odczytu MR wystarczy zakres `read_api`.

Skrypt sprawdzi konto i otworzy tymczasową sesję PowerShell w tym samym oknie terminala. Zobaczysz nazwę swojego konta oraz polecenia do ćwiczenia. Ta sesja ma osobną konfigurację `glab` i projekt `lucas/dogrywka-jftp` ustawiony jako domyślny.

### 3. Odczytaj wspólny MR

W nowo otwartej sesji wpisuj osobno:

```powershell
glab mr view 1
glab mr diff 1
```

Do tych poleceń wystarcza API GitLaba. Klon aplikacji jFTP jest potrzebny dopiero do lokalnej edycji i uruchamiania jej testów.

### 4. Jeśli chcesz edytować jFTP lokalnie, sklonuj aplikację z GitLaba

W tej sesji przejdź poziom wyżej, żeby klon aplikacji znalazł się obok repozytorium materiałów:

```powershell
cd ..
git -c credential.helper= -c "credential.helper=!glab auth git-credential" clone --branch warsztat/port-ftp https://gitlab-devpowers.polandcentral.cloudapp.azure.com/lucas/dogrywka-jftp.git
cd dogrywka-jftp
```

Git pobierze token z tymczasowej sesji przez `glab`. Do klonowania token potrzebuje zakresu `read_repository` lub szerszego `api`. Tokeny rozdane przez trenera obejmują odczyt repozytorium. Obie opcje `-c` dotyczą tego jednego klonowania.

Nad wspólnym MR pracujemy z jednym kierowcą. Swoje propozycje zgłaszaj w dyskusji MR. Uprawnienie Reporter pozwala czytać kod i wyniki CI.

### 5. Zakończ sesję

```powershell
exit
```

Wrócisz do wcześniejszego PowerShella. Skrypt przywróci jego zmienne środowiskowe i usunie tymczasowy katalog konfiguracji. Ważność samego tokenu kontrolujesz w GitLabie.

Codex uruchamiaj w oddzielnym terminalu przez [launcher konta szkoleniowego](../../README.md#codex-cli-na-koncie-szkoleniowym).
