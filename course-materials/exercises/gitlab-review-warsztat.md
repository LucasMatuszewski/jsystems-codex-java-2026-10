# Od merge requesta do testu regresji

Użyjesz lokalnego Codexa do zweryfikowania komentarzy PR-Agent i Codex CLI. Potem odtworzysz oba joby na własnym testowym merge requeście i sprawdzisz, czy agenci wychwycą celowo wprowadzoną regresję.

## Wejdź do GitLaba

https://gitlab-devpowers.polandcentral.cloudapp.azure.com

Użyj swojego konta szkoleniowego. Otwórz wspólny merge request.

https://gitlab-devpowers.polandcentral.cloudapp.azure.com/lucas/dogrywka-jftp/-/merge_requests/1

Do ćwiczenia używamy kodu jFTP i danych syntetycznych.

## Zweryfikuj komentarze z lokalnym Codexem

Założenie do MR: w zwykłym profilu FTP porty od 1 do 65535 mają zostać zachowane, a wartości spoza zakresu mają użyć dotychczasowego portu domyślnego. Zachowanie portu implicit SSL ma pozostać takie jak wcześniej.

1. [Zaloguj się w `glab`](#logowanie-w-glab) albo [uruchom tymczasową sesję PowerShell](#glab-na-koncie-szkoleniowym-w-powershellu). Sklonuj gałąź MR i uruchom lokalnego Codexa z dostępem do klonu jFTP. W przeglądarce możesz też otworzyć gotowe komentarze i logi obu jobów.
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

## Odtwórz oba joby we własnym projekcie GitLab

1. Przygotuj prywatny projekt testowy z [kodem jFTP](https://github.com/LucasMatuszewski/JSystems-JFTP-2026-10-30). Zapisz działającą konfigurację na gałęzi docelowej projektu. Użyj zaufanego runnera Docker z dostępem do GitLaba, rejestru obrazów i zatwierdzonego dostawcy modelu.
2. **PR-Agent.** Zachowaj job `pr-agent-review` z głównego pliku CI w jFTP. Jeżeli przenosisz go do innego projektu, dodaj etap `review` i zmień instrukcje domenowe w `PR_REVIEWER__EXTRA_INSTRUCTIONS`. W wersji z OpenRouter ustaw `REVIEW_API_KEY`. Do odczytu MR i publikacji komentarza ustaw `GITLAB__PERSONAL_ACCESS_TOKEN` z tokenem bota tego projektu. [Job w jFTP](https://github.com/LucasMatuszewski/JSystems-JFTP-2026-10-30/blob/master/.gitlab-ci.yml) · [Instrukcja PR-Agent](https://github.com/LucasMatuszewski/JSystems-JFTP-2026-10-30/blob/master/docs/gitlab-pr-agent.md)
3. **Codex CLI.** Skopiuj sekcję `codex-review` z [przykładowego pliku CI](../cicd-headless/gitlab-cargo-tracker/.gitlab-ci.yml), a katalog [agent-review](../cicd-headless/agent-review/) umieść jako `ci/agent-review/`. Zbuduj obraz z [Dockerfile](../cicd-headless/agent-review/Dockerfile), opublikuj go w rejestrze dostępnym dla runnera i wpisz jego pełny adres w `image:`. W jFTP dodaj w tym jobie `before_script: []` i `cache: []`, żeby pominąć ustawienia Mavena z `default:`. W wariancie z OpenRouter ustaw `OPENROUTER_API_KEY`. Skrypt publikujący komentarz czyta `GITLAB_TOKEN`.
4. W obu jobach możesz zastosować poniższą regułę pilotażu. Otwórz MR między dwiema gałęziami tego samego projektu, uruchom oba joby ręcznie dla tego samego commita i sprawdź komentarze oraz logi. Jeśli chcesz uruchamiać review po etapie testów, usuń `needs: []` z joba Codex. [Działający pipeline z oboma jobami na szkoleniowym GitLabie](https://gitlab-devpowers.polandcentral.cloudapp.azure.com/lucas/dogrywka-jftp/-/blob/b201e2656c76511555eab62e909648769aef89f2/.gitlab-ci.yml)

```yaml
rules:
  - if: '$CI_PIPELINE_SOURCE == "merge_request_event" && $CI_MERGE_REQUEST_SOURCE_PROJECT_ID == $CI_PROJECT_ID'
    when: manual
  - when: never
allow_failure: true
```

Przykład budowy obrazu z katalogu projektu jFTP po skopiowaniu `ci/agent-review/`. Podmień adres obrazu na adres swojego rejestru i użyj go w jobie Codex.

```bash
docker build -t registry.example.com/team/jftp/agent-ci:1 ci/agent-review
docker push registry.example.com/team/jftp/agent-ci:1
```

W projekcie szkoleniowym z przygotowanym pipeline’em klucz modelu zapewnia trener. We własnej instancji skonfiguruj klucz zatwierdzonego dostawcy oraz krótkotrwały token bota z zakresem `api` i dostępem do projektu. Ustaw je w **Settings → CI/CD → Variables** jako `Masked and hidden`, z wyłączonym rozwijaniem wartości. Sprawdź, czy zakres ochrony zmiennych pasuje do gałęzi, na których uruchamiasz review. Wzór uruchamiaj na zaufanych gałęziach i kodzie testowym. W firmowym CI wydziel publikację z tokenem GitLab do osobnego joba, który odbiera raport review jako artefakt. [Zmienne CI/CD](https://docs.gitlab.com/ci/variables/) · [Wynik przykładowego review Codex](../cicd-headless/agent-review/examples/codex-review-gitlab-mr-2026-10-30.md)

### Zmiana do własnego MR

Z gałęzi docelowej utwórz osobną gałąź i zmień w `RemoteHost.setPort` wyłącznie przypisanie wartości zwykłego portu FTP:

```java
this.port = port <= 1 || port > 65535 ? FTPConstants.DEFAULT_PORT : port;
```

W opisie MR podaj, że zakres `1–65535` jest domknięty, a nieprawidłowy port ma używać wartości domyślnej. Uruchom oba review. Po ich zakończeniu zleć lokalnemu Codexowi zweryfikowanie komentarzy przez `$respond-to-code-review`, tym razem z linkiem do Twojego MR. Sprawdź, czy agent potrafi odtworzyć przypadek dla portu `1`. Dopisz test, popraw granicę na `port <= 0`, ponów oba joby dla nowego commita i zatwierdź odpowiedź Codexa na komentarze. Porównaj też, czy ponowne uruchomienie aktualizuje komentarz, czy publikuje nowy.

## Logowanie w glab

Uruchom polecenie, wybierz logowanie tokenem i wklej swój Personal Access Token w polu logowania.

```sh
glab auth login --hostname gitlab-devpowers.polandcentral.cloudapp.azure.com
```

Sprawdź dostęp do komentarzy. Pełny URL projektu wskazuje szkoleniowy host także wtedy, gdy domyślny host w `glab` jest inny.

```sh
glab mr view 1 --repo https://gitlab-devpowers.polandcentral.cloudapp.azure.com/lucas/dogrywka-jftp --comments
```

Możesz też użyć `glab-szkolenie.ps1`, który po podaniu tokenu przygotowuje dostęp do projektu na czas sesji PowerShell.

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
