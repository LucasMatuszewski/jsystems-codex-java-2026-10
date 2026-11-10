# Od merge requesta do testu regresji

Użyjesz lokalnego Codexa do zweryfikowania komentarzy PR-Agent i Codex CLI ze szkoleniowego merge requesta. Konfigurację na własnej instancji opisuje osobna [instrukcja PR-Agent i Codex CLI w firmowym GitLab CI](../cicd-headless/gitlab-review-jobs.md).

## Wejdź do GitLaba

https://gitlab-devpowers.polandcentral.cloudapp.azure.com

Użyj swojego konta szkoleniowego. Otwórz wspólny merge request.

https://gitlab-devpowers.polandcentral.cloudapp.azure.com/lucas/dogrywka-jftp/-/merge_requests/1

Do ćwiczenia używamy kodu jFTP i danych syntetycznych.

## Zweryfikuj komentarze z lokalnym Codexem

Założenie do MR: w zwykłym profilu FTP porty od 1 do 65535 mają zostać zachowane, a wartości spoza zakresu mają użyć dotychczasowego portu domyślnego. Zachowanie portu implicit SSL ma pozostać takie jak wcześniej.

1. [Uruchom `glab-szkolenie.ps1` w PowerShellu](#glab-na-koncie-szkoleniowym-w-powershellu). Sklonuj gałąź MR i uruchom lokalnego Codexa z dostępem do klonu jFTP. W przeglądarce możesz też otworzyć gotowe komentarze i logi obu jobów.
2. Poproś Codexa ze skillem `$respond-to-code-review` o pobranie dyskusji i diffu przez `glab`, zweryfikowanie jednej uwagi w kodzie i pokazanie dowodu w teście. Oba boty wskazały tę samą wartość graniczną, więc sprawdź, czy ich zgodność wynika z kodu.
3. Po sprawdzeniu propozycji pozwól Codexowi dodać test do `RemoteHostCharacterizationTest` i uruchomić go na wersji z MR, a potem po lokalnej poprawce. Poproś o krótką odpowiedź z wynikiem przed jej opublikowaniem. Na wspólnym MR możesz skomentować po weryfikacji. Własny commit i ponowne uruchomienie review zrobisz w osobnym MR.

[Komentarz PR-Agent](https://gitlab-devpowers.polandcentral.cloudapp.azure.com/lucas/dogrywka-jftp/-/merge_requests/1#note_19) · [Komentarz Codex CLI](https://gitlab-devpowers.polandcentral.cloudapp.azure.com/lucas/dogrywka-jftp/-/merge_requests/1#note_20) · [Log PR-Agent](https://gitlab-devpowers.polandcentral.cloudapp.azure.com/lucas/dogrywka-jftp/-/jobs/54) · [Log Codex CLI](https://gitlab-devpowers.polandcentral.cloudapp.azure.com/lucas/dogrywka-jftp/-/jobs/55)

Uruchom test z katalogu jFTP z JDK 21. W PowerShellu użyj:

```powershell
.\mvnw.cmd -B -ntp -Dtest=RemoteHostCharacterizationTest test
```

Na Linuksie użyj `./mvnw` z tymi samymi argumentami.

### Prompt do weryfikacji feedbacku

```text
Użyj $respond-to-code-review dla tego MR:
https://gitlab-devpowers.polandcentral.cloudapp.azure.com/lucas/dogrywka-jftp/-/merge_requests/1

Pobierz przez glab dyskusje, diff i status CI. Wskaż, gdzie PR-Agent
i Codex CLI zgadzają się w ocenie RemoteHost.setPort. Sprawdź kontrakt
z opisu MR i kod w moim klonie jFTP. Podaj wejście, wynik oczekiwany,
wynik rzeczywisty i minimalny test, który rozstrzyga uwagę.
Rozróżnij test uruchomiony od zaproponowanego. Przygotuj szkic odpowiedzi.
Zaczekaj na moją akceptację przed edycją kodu albo publikacją odpowiedzi.
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

Skrypt sprawdzi konto i otworzy tymczasową sesję PowerShell w tym samym oknie terminala. Zobaczysz nazwę swojego konta oraz polecenia do ćwiczenia. Ta sesja ma osobną konfigurację `glab` i projekt `lucas/dogrywka-jftp` ustawiony jako domyślny. Do ćwiczenia użyj skryptu. Po wyjściu z sesji PowerShell wrócisz do wcześniejszych ustawień i logowania.

### 3. Odczytaj wspólny MR

W nowo otwartej sesji wpisuj osobno:

```powershell
glab mr view 1 --comments
glab mr diff 1
glab api --hostname $env:GITLAB_HOST 'projects/lucas%2Fdogrywka-jftp/merge_requests/1/discussions' --paginate
```

Do tych poleceń wystarcza odczyt API GitLaba. Jeśli chcesz opublikować odpowiedź przez `glab`, potrzebujesz tokenu z zakresem `api` i prawa do komentowania w projekcie. Na wspólnym projekcie rola Reporter pozwala komentować. Własną gałąź z review uruchomisz w projekcie, w którym masz co najmniej rolę Developer i dostępnego runnera. [Uprawnienia GitLab](https://docs.gitlab.com/user/permissions/#project-merge-requests) · [Zakresy tokenów](https://docs.gitlab.com/user/profile/personal_access_tokens/#personal-access-token-scopes)

Jeśli chcesz odpowiedzieć w konkretnym wątku, podaj Codexowi ID dyskusji z wyniku `glab api`. Po zatwierdzeniu tekstu agent może użyć `glab mr note create` z opcją `--reply`. [API dyskusji w GitLabie](https://docs.gitlab.com/api/discussions/#add-a-note-to-an-existing-merge-request-thread)

### 4. Jeśli chcesz edytować jFTP lokalnie, sklonuj aplikację z GitLaba

W tej sesji przejdź poziom wyżej, żeby klon aplikacji znalazł się obok repozytorium materiałów:

```powershell
cd ..
git -c credential.helper= -c "credential.helper=!glab auth git-credential" clone --branch warsztat/port-ftp https://gitlab-devpowers.polandcentral.cloudapp.azure.com/lucas/dogrywka-jftp.git
cd dogrywka-jftp
```

Git pobierze token z tymczasowej sesji przez `glab`. Do klonowania token potrzebuje zakresu `read_repository` lub szerszego `api`. Tokeny rozdane przez trenera obejmują odczyt repozytorium. Obie opcje `-c` dotyczą tego jednego klonowania.

Uruchom Codexa w tym samym oknie PowerShella, aby mógł użyć tej tymczasowej sesji `glab`. Z klonu jFTP uruchom poniższą komendę. W prompcie wskaż Codexowi ścieżkę klonu jFTP i poproś, żeby uruchamiał test w tym katalogu.

```powershell
..\jsystems-codex-java-2026-10\codex-szkolenie.ps1 --add-dir "$($PWD.Path)"
```

Jeśli sprawdzasz własny MR, podaj jego pełny URL. Skrypt `glab-szkolenie.ps1` domyślnie wskazuje wspólny projekt.

### 5. Zakończ sesję

```powershell
exit
```

Wrócisz do wcześniejszego PowerShella. Skrypt przywróci jego zmienne środowiskowe i usunie tymczasowy katalog konfiguracji. Ważność samego tokenu kontrolujesz w GitLabie.

[Logowanie Codex CLI na konto szkoleniowe](../../README.md#codex-cli-na-koncie-szkoleniowym)
