# Osobne poświadczenia człowieka i agentów: GitHub CLI oraz GitLab CLI

Stan dokumentacji: **29.10.2026**. Kontekst: Windows 11, PowerShell 7, Codex z natywnym sandboxem, `gh` oraz planowane `glab`. Lokalnie potwierdzono `gh 2.103.2`; `glab` nie było dostępne w PATH podczas sprawdzania. Przykłady GitLab wymagają weryfikacji po instalacji CLI i ustaleniu wersji instancji.

Aktualny `AGENTS.md` repozytorium wskazuje kursową instancję **GitLab Self-Managed 19.5** pod adresem `jsystems-gitlab.polandcentral.cloudapp.azure.com`. To kontekst zapisany w repozytorium, nie wynik sprawdzenia działającego serwera. Przykład niżej używa tego hosta; porównanie metod obejmuje również GitLab.com.

To instrukcja projektowa i plan wdrożenia. Przy jej przygotowaniu nie tworzono, nie odczytywano ani nie przenoszono tokenów. Przykłady używają zastępczych nazw repozytoriów.

## 1. Cel i rekomendacja

Potrzebujemy **dwóch profili poświadczeń dla każdego dostawcy**:

| Dostawca | Profil człowieka | Profil agenta |
|---|---|---|
| GitHub / `gh` | Osobiste logowanie, dostępne wyłącznie w środowisku człowieka | Osobny, ograniczony token lub token instalacji GitHub App |
| GitLab / `glab` | Osobiste logowanie, dostępne wyłącznie w środowisku człowieka | Osobny token fine-grained, project access token albo konto automatyzacji |

Punkt wyjścia to cztery niezależne poświadczenia. Token GitHub nie uwierzytelnia w GitLab. Jeden profil agenta może później potrzebować kilku tokenów, np. dla różnych organizacji lub instancji.

**Rekomendacja dla tego stanowiska:** ograniczyć agenta do wskazanych projektów i zadań, a jego polecenia wykonywać przez trwałe konto systemowe przeznaczone dla automatyzacji albo przez wąski broker. Osobisty token pozostawić przy koncie człowieka. Na początek profil agenta powinien umożliwiać odczyt; zapis dodać po określeniu konkretnych operacji.

Są tu dwie osobne decyzje:

1. **Wybór poświadczenia:** jak sprawić, aby konkretne wywołanie `gh` lub `glab` użyło tokena agenta.
2. **Ochrona tokena człowieka:** jak uniemożliwić agentowi pominięcie tego wyboru i użycie osobistego logowania.

Zmienne środowiskowe i katalogi konfiguracji rozwiązują pierwszą sprawę. Ochrona drugiej wymaga odpowiednio odseparowanego wykonawcy. To wniosek architektoniczny: proces, któremu wolno uruchamiać dowolny kod jako człowiek, ma możliwości tego konta niezależnie od instrukcji w `AGENTS.md`.

## 2. Co rzeczywiście rozdzielamy

Nie „dzielimy” istniejącego PAT na dwa ciągi. Wystawiamy oddzielne poświadczenie z mniejszym zakresem. Ograniczony PAT utworzony przez człowieka nadal działa w ramach jego tożsamości; nazwa `agent-read` sama nie tworzy konta bota. Jeżeli potrzebna jest odrębna tożsamość w audycie, rozważamy GitHub App albo konto/bota obsługiwanego przez GitLab.

GitHub ogranicza PAT zarówno uprawnieniami tokena, jak i dostępem jego właściciela. Analogicznie fine-grained PAT GitLab musi przejść kontrolę uprawnień tokena oraz użytkownika. Źródła: [GitHub PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens), [GitLab fine-grained PAT](https://docs.gitlab.com/auth/tokens/fine_grained_access_tokens/).

W rejestrze poświadczeń zapisujemy nazwę, przeznaczenie, właściciela/instalację, dozwolone zasoby i operacje, datę wygaśnięcia, lokalizację w magazynie oraz osobę odpowiedzialną za rotację. Wartości tokena nie zapisujemy w repozytorium ani w tej notatce. Przykładowe nazwy: `github-agent-course-read`, `gitlab-agent-course-read`, `github-human`, `gitlab-human`.

## 3. Dostępne metody separacji

| Metoda | Korzyść | Ograniczenie |
|---|---|---|
| Token przekazany tylko procesowi CLI | Jawny wybór poświadczenia; brak przełączania wspólnej sesji | Agent może odczytać przekazany mu token; sam mechanizm nie chroni innego tokena dostępnego na tym samym koncie |
| Oddzielne `GH_CONFIG_DIR` i `GLAB_CONFIG_DIR` | Osobne pliki ustawień i mniejsze ryzyko pomylenia profili | Katalog konfiguracji nie jest granicą bezpieczeństwa ani gwarancją oddzielnego keyringu |
| Osobne konto GitHub/GitLab | Inny zakres członkostwa i czytelniejszy audyt | Dostępność/licencje i administracja; oba logowania zapisane przy jednym koncie Windows nadal mogą być dostępne dla jego procesów |
| Osobny użytkownik systemu, VM lub runner | Możliwość odseparowania magazynu poświadczeń człowieka | Wymaga świadomej konfiguracji wykonawcy, uprawnień do plików, kluczy i eskalacji |
| Broker operacji | Agent otrzymuje np. `read_repository` lub `create_merge_request`, a nie dowolne wykonanie z sekretem | Broker musi sprawdzać host, projekt, operację i argumenty; jego magazyn musi być poza zasięgiem agenta |
| Krótkotrwałe tokeny aplikacji/CI | Mniejsze okno wykorzystania i łatwiejsze odwołanie sesji | Zależność od mechanizmu wystawiania i obsługiwanych endpointów |

To porównanie projektu rozwiązania. Zmienne i ścieżki obsługiwane przez CLI są opisane w [środowisku `gh`](https://cli.github.com/manual/gh_help_environment) oraz [konfiguracji `glab`](https://docs.gitlab.com/cli/configuration/). Z tych ustawień nie wynika izolacja kont systemowych.

### Dlaczego przełączanie kont nie wystarczy

`gh auth switch --hostname github.com --user NAZWA` wybiera **konto GitHub**, a nie nazwany token o określonym zakresie dla tego samego użytkownika. Zmienia współdzielony stan konfiguracji; równoległe sesje mogą sobie przeszkadzać. Nie traktujemy go jako zabezpieczenia osobistego logowania. [Dokumentacja `gh auth switch`](https://cli.github.com/manual/gh_auth_switch).

Nie zakładamy też, że `glab --hostname` rozróżni dwa profile tego samego hosta. Do deterministycznego wyboru tokena używamy osobnego środowiska procesu/wykonawcy. `GLAB_CONFIG_DIR` wybiera konfigurację; ustawienia repozytorium i systemu również trzeba uwzględnić. [Konfiguracja `glab`](https://docs.gitlab.com/cli/configuration/).

## 4. GitHub: dobór poświadczenia agenta

### Wariant A: osobny fine-grained PAT

W ustawieniach GitHub wybieramy **Developer settings → Personal access tokens → Fine-grained tokens**. Tworzymy token z nazwą zadania, krótkim uzgodnionym terminem ważności i właściwym **Resource owner**. Wybieramy **Only select repositories** oraz konkretne repozytoria. Uprawnienia dobieramy do endpointów; organizacja może wymagać zatwierdzenia tokena.

Token fine-grained obejmuje jednego właściciela zasobów. Dla repozytoriów własnych i innej organizacji mogą być potrzebne osobne tokeny. Ograniczenie wybranych repozytoriów nie usuwa odczytu publicznych repozytoriów, który GitHub dopuszcza również takim tokenom. [Tworzenie i ograniczenia PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens).

Poniżej punkt wyjścia do przeglądu uprawnień, a nie obietnica zgodności każdego podpolecenia `gh`:

| Zadanie | Uprawnienia do rozważenia |
|---|---|
| Odczyt kodu | `Contents: read`; metadane repozytorium |
| Odczyt PR i issues | `Pull requests: read`, `Issues: read`, jeśli zadanie ich wymaga |
| Odczyt uruchomień Actions | `Actions: read`, jeśli potrzebne |
| Wysłanie zmian i otwarcie PR | Zapis zawartości oraz `Pull requests: write`; tylko potrzebne repozytoria |

Wymagania REST dla tworzenia PR i scalania są osobne; komentarze do PR mogą używać endpointów issues. Sprawdzamy dokładną operację w [API pull requests](https://docs.github.com/en/rest/pulls/pulls) i [wymaganych uprawnieniach fine-grained PAT](https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens). Polityki gałęzi i proces zatwierdzania trzeba zaprojektować dodatkowo — token nie opisuje reguły „wolno uruchomić wyłącznie to polecenie CLI”.

`gh auth login --with-token` jest opisane przede wszystkim dla klasycznego PAT; dokumentacja zaleca `GH_TOKEN` dla fine-grained PAT. Nie rozszerzamy tokena do szerokiego `repo` tylko po to, żeby przejść ogólny kreator logowania. Konkretne polecenia REST/GraphQL mogą mieć różne wymagania. [Dokumentacja logowania `gh`](https://cli.github.com/manual/gh_auth_login).

### Wariant B: GitHub App

Dla stałej automatyzacji można zainstalować GitHub App na wybranych repozytoriach i wystawiać token instalacji. Przy wystawieniu można dodatkowo zawęzić repozytoria i uprawnienia; token wygasa po godzinie. Klucz prywatny aplikacji powinien pozostać w zaufanym mechanizmie wystawiającym, poza workspace agenta. Agent otrzymuje krótkotrwałe poświadczenie albo wynik operacji brokera. [Token instalacji GitHub App](https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/generating-an-installation-access-token-for-a-github-app).

CLI musi obsługiwać wybrany typ tokena dla konkretnego zadania. Token instalacji nie jest tokenem zalogowanego człowieka: endpointy użytkownika i niektóre funkcje CLI mogą być nieodpowiednim testem. Dla tej metody weryfikujemy dostęp do docelowego repozytorium i wymaganych operacji, zamiast wymagać poprawnego działania każdego polecenia `gh auth`.

## 5. GitLab: dobór poświadczenia agenta

### Wariant A: fine-grained PAT

Aktualna dokumentacja podaje beta od GitLab 18.10 i ogólną dostępność od **19.2**, również dla Free. Na starszym Self-Managed sprawdzamy wersję i dostępność funkcji. W **Edit profile → Access → Personal access tokens → Generate token → Fine-grained token** wybieramy zasoby, granice dostępu i konkretne operacje. [GitLab fine-grained PAT](https://docs.gitlab.com/auth/tokens/fine_grained_access_tokens/).

Odczyt projektu, odczyt MR i utworzenie MR mogą wymagać różnych uprawnień API. Dla Git over HTTPS dokumentacja wskazuje **Code → Download** dla clone/pull oraz **Code → Push** dla push. Weryfikujemy osobno REST, GraphQL i Git. [Uprawnienia Git](https://docs.gitlab.com/auth/tokens/fine_grained_access_tokens_other/), [uprawnienia REST](https://docs.gitlab.com/auth/tokens/fine_grained_access_tokens_rest/), [uprawnienia GraphQL](https://docs.gitlab.com/auth/tokens/fine_grained_access_tokens_graphql/).

### Wariant B: project access token albo group access token

Project access token pozwala dobrać rolę i zakres dla projektu; tworzy go Maintainer/Owner przez **Settings → Access tokens**. Na GitLab.com wymaga Premium/Ultimate; Self-Managed i Dedicated udostępniają go przy dowolnej licencji. Dokumentacja opisuje wyjątek widoczności: token utworzony przez użytkownika internal może widzieć inne projekty o widoczności **Internal**. Należy to uwzględnić w testach izolacji. [Project access tokens](https://docs.gitlab.com/user/project/settings/project_access_tokens/).

Group access token ma sens dla świadomie wybranej grupy i jej projektów; jest szerszy od pojedynczego projektu. Przed wyborem sprawdzamy dostępność na danej ofercie. [Group access tokens](https://docs.gitlab.com/user/group/settings/group_access_tokens/).

Dla tokenów ze starszym modelem scopes dobieramy zakres wraz z rolą:

| Zadanie | Scopes do rozważenia |
|---|---|
| Odczyt API projektu, MR, issues | `read_api` |
| Clone/fetch przez HTTPS | `read_repository` |
| Push przez HTTPS | `write_repository` |
| Tworzenie MR przez API | `api`, ograniczone rolą i zasięgiem tokena; alternatywnie właściwe uprawnienia fine-grained |

`write_repository` samo nie nadaje zapisu całego API. Legacy PAT z `read_api` na koncie człowieka nie jest ograniczony do jednego projektu. `api` osobistego PAT jest bardzo szerokie; nie kopiujemy bezrefleksyjnie zestawu `api` + `write_repository` z ogólnego tutoriala CLI do profilu tylko do odczytu. [Zakresy tokenów GitLab](https://docs.gitlab.com/security/tokens/access_token_scopes/).

### Warianty specjalizowane

GitLab `CI_JOB_TOKEN` jest poświadczeniem zadania CI z ograniczoną listą obsługiwanych endpointów. To wariant dla wykonawcy w CI, nie stały sekret lokalnej sesji. Nie przekazujemy go jako `GITLAB_TOKEN`: `glab` rozróżnia te sposoby uwierzytelniania. [Job tokens](https://docs.gitlab.com/ci/jobs/ci_job_token/), [uwierzytelnianie `glab`](https://docs.gitlab.com/cli/authentication/).

Deploy token może wystarczyć do wybranych operacji repozytorium/rejestrów, ale nie zastępuje tokena do ogólnego API MR/issues. Podobnie klucz SSH rozwiązuje uwierzytelnianie Git, a nie całego API `gh`/`glab`. [Deploy tokens GitLab](https://docs.gitlab.com/user/project/deploy_tokens/), [deploy keys GitHub](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/managing-deploy-keys).

## 6. Jak wybrać właściwy token przy uruchomieniu CLI

### Pierwszeństwo poświadczeń

- `gh` dla GitHub.com: `GH_TOKEN`, następnie `GITHUB_TOKEN`, przed zapisanym logowaniem. GitHub Enterprise Server ma osobne zmienne `GH_ENTERPRISE_TOKEN` / `GITHUB_ENTERPRISE_TOKEN`. `GH_CONFIG_DIR` wybiera katalog plików. [Środowisko `gh`](https://cli.github.com/manual/gh_help_environment).
- `glab`: `GITLAB_TOKEN`, `GITLAB_ACCESS_TOKEN`, `OAUTH_TOKEN` przed zapisanymi poświadczeniami. Zmienna tokena obowiązuje dla hostów uznanych przez CLI za zaufane; ustawiamy jawnie `GITLAB_HOST`. Dopiero dalej może działać autologowanie CI. [Pierwszeństwo tokenów `glab`](https://docs.gitlab.com/cli/authentication/#token-precedence).

Brak tokena agenta musi kończyć uruchomienie błędem. Usunięcie zmiennej i ponowne uruchomienie CLI może odsłonić zapisane logowanie człowieka. Błąd autoryzacji nie jest powodem do automatycznego przełączenia na profil prywatny.

### Przykład PowerShell 7: poświadczenie tylko w procesie potomnym

Poniższa funkcja demonstruje wybór poświadczenia bez globalnego `setx` i bez tokena w argumentach procesu. **Nie jest brokerem bezpieczeństwa:** dopuszcza dowolne argumenty i działa z uprawnieniami konta, które ją uruchamia. Do właściwej separacji wykonujemy ją na koncie agenta, które nie ma osobistych poświadczeń człowieka. Przed produkcyjnym użyciem zatwierdzamy ścieżkę do binarnego CLI i ograniczamy hosty, projekty oraz operacje.

```powershell
function Invoke-AgentScm {
    param(
        [Parameter(Mandatory)][ValidateSet('github', 'gitlab')][string]$Provider,
        [Parameter(Mandatory)][Security.SecureString]$AgentToken,
        [Parameter(Mandatory)][string[]]$CliArgs,
        [string]$GitLabHost = 'jsystems-gitlab.polandcentral.cloudapp.azure.com'
    )

    $tokenText = ConvertFrom-SecureString -SecureString $AgentToken -AsPlainText
    if ([string]::IsNullOrWhiteSpace($tokenText)) { throw 'Brak tokena agenta.' }
    $executable = if ($Provider -eq 'github') { 'gh' } else { 'glab' }
    $start = [Diagnostics.ProcessStartInfo]::new()
    $start.FileName = (Get-Command $executable -CommandType Application -ErrorAction Stop).Source
    $start.UseShellExecute = $false
    foreach ($argument in $CliArgs) { $start.ArgumentList.Add($argument) }

    # Usuń alternatywne poświadczenia SCM odziedziczone z procesu rodzica.
    foreach ($variable in @(
        'GH_TOKEN', 'GITHUB_TOKEN', 'GH_ENTERPRISE_TOKEN', 'GITHUB_ENTERPRISE_TOKEN',
        'GITLAB_TOKEN', 'GITLAB_ACCESS_TOKEN', 'OAUTH_TOKEN', 'CI_JOB_TOKEN',
        'GLAB_ENABLE_CI_AUTOLOGIN', 'GH_REPO', 'GITLAB_REPO',
        'GITLAB_API_HOST', 'GITLAB_SSH_HOST', 'GITLAB_URI', 'GL_HOST'
    )) { [void]$start.Environment.Remove($variable) }

    $profileRoot = Join-Path $env:LOCALAPPDATA 'agent-cli'
    if ($Provider -eq 'github') {
        $start.Environment['GH_TOKEN'] = $tokenText
        $start.Environment['GH_HOST'] = 'github.com'
        $start.Environment['GH_CONFIG_DIR'] = Join-Path $profileRoot 'gh'
    } else {
        $start.Environment['GITLAB_TOKEN'] = $tokenText
        $start.Environment['GITLAB_HOST'] = $GitLabHost
        $start.Environment['GLAB_API_PROTOCOL'] = 'https'
        $start.Environment['GLAB_CONFIG_DIR'] = Join-Path $profileRoot 'glab'
    }

    $process = $null
    try {
        $process = [Diagnostics.Process]::Start($start)
        $process.WaitForExit()
        if ($process.ExitCode -ne 0) { throw "CLI zakończyło się kodem $($process.ExitCode)." }
    } finally {
        $start.Environment.Clear()
        $tokenText = $null
        if ($null -ne $process) { $process.Dispose() }
    }
}

# Wykonuje człowiek przy konfiguracji środowiska agenta; podaje tylko ograniczony token.
$ghAgent = Read-Host 'Token GitHub agenta' -AsSecureString
Invoke-AgentScm -Provider github -AgentToken $ghAgent -CliArgs @('api', 'repos/OWNER/REPO')

$glAgent = Read-Host 'Token GitLab agenta' -AsSecureString
Invoke-AgentScm -Provider gitlab -AgentToken $glAgent -CliArgs @('api', 'projects/PROJECT_ID')
```

`ProcessStartInfo.Environment` ustawia środowisko uruchamianego procesu, a `ArgumentList` przekazuje oddzielne argumenty bez składania polecenia powłoki. [Environment](https://learn.microsoft.com/en-us/dotnet/api/system.diagnostics.processstartinfo.environment), [ArgumentList](https://learn.microsoft.com/en-us/dotnet/api/system.diagnostics.processstartinfo.argumentlist). Zapisanie `$null` nie daje gwarancji wymazania sekretu z pamięci; CLI musi dostać token w postaci użytecznej do uwierzytelnienia. Pozostałe środowisko jest dziedziczone — produkcyjny wykonawca powinien startować z zatwierdzoną listą zmiennych.

W automatyzacji interaktywny odczyt zastępujemy zaufanym pobraniem **wyłącznie tokena agenta** z magazynu. Nie dodajemy sekretów do `AGENTS.md`, `.env` w repozytorium, argumentu `--token`, historii terminala ani logów debug HTTP. Dla Enterprise/Self-Managed dostosowujemy jawny host i właściwe zmienne, bez automatycznego przenoszenia tokenów pomiędzy hostami.

## 7. Osobiste logowanie i magazyny poświadczeń

Na koncie człowieka pozostawiamy prywatny profil w systemowym magazynie. `gh auth login` używa magazynu poświadczeń, a przy problemie może zapisać token do pliku. Lokalizację sprawdzamy przez `gh auth status`, bez `--show-token`. [Przechowywanie poświadczeń `gh`](https://cli.github.com/manual/gh_auth_login).

Aktualne `glab auth login` domyślnie używa keyringu, jeśli jest dostępny; brak backendu, `--insecure-storage` lub tryb CI może prowadzić do pliku tekstowego. Po instalacji sprawdzamy zachowanie konkretnej wersji. Do kontrolowanego przekazania tokena służy m.in. `--stdin`; nie zakładamy, że zmiana katalogu konfiguracji odseparuje Credential Manager. [Logowanie `glab`](https://docs.gitlab.com/cli/auth/login/).

Osobisty profil uruchamiamy w osobnym terminalu/środowisku człowieka, bez odziedziczonych zmiennych tokena agenta. Broker i runner agenta nie dostają dostępu do osobistego keyringu, prywatnych kluczy SSH ani ich agentów. Osobny folder na tym samym koncie Windows to porządek konfiguracyjny, nie taka izolacja.

## 8. Git przez HTTPS/SSH wymaga osobnego sprawdzenia

`gh api` lub `glab api` i `git push` nie muszą wybierać tego samego poświadczenia. Git może użyć Git Credential Manager, innego credential helpera albo klucza z SSH agenta. To potencjalna droga pominięcia ograniczeń wybranych dla CLI.

W środowisku agenta sprawdzamy konfigurację helperów, protokół remote i dostęp do SSH agenta bez wypisywania sekretów. Jeżeli świadomie konfigurujemy CLI jako helper Git, robimy to w odseparowanym profilu wykonawcy. Nie zmieniamy globalnego helpera człowieka na potrzeby ćwiczenia. [Helper `gh`](https://cli.github.com/manual/gh_auth_setup-git), [helper `glab`](https://docs.gitlab.com/cli/auth/login/#options).

Nawet token z zapisem nie powinien zastępować ochrony gałęzi i wymaganego przeglądu zmian. Ustalamy, czy agent ma jedynie przygotować zmiany lokalnie, wysłać gałąź, utworzyć PR/MR, czy również wykonywać inne operacje. Każde rozszerzenie wymaga osobnego zakresu zadania.

## 9. Integracja z obecnym Codexem na Windows

W lokalnej sesji potwierdzono wcześniej: sandbox działał jako `CodexSandboxOffline`, a zatwierdzone polecenie poza nim działało jako człowiek i korzystało z jego logowania GitHub. Kontekst i ograniczenia starszych wersji opisuje [raport sandboxa Windows](codex-windows-sandbox-troubleshooting-2026-10-15.md); nie przenosimy obserwacji z 0.162.1 bez sprawdzenia na każdą nowszą wersję.

Przygotowane wcześniej reguły `gh-read.rules` zezwalają na wybrane odczyty poza sandboxem. **Nie wybierają tokena agenta.** Jeżeli wykonawcą nadal jest konto człowieka, odczyty mogą używać jego osobistego logowania. Przed wdrożeniem separacji trzeba przejrzeć te wyjątki i kierować operacje do wykonawcy/brokera agenta. Sam zakaz nazwy `gh` też nie zabezpiecza osobistego keyringu przed dowolnym kodem uruchomionym jako człowiek. [Reguły poleceń Codex](https://learn.chatgpt.com/docs/agent-configuration/rules).

W audycie uwzględniamy argumenty: reguła prefiksu zezwalająca na `gh auth status` obejmuje również `gh auth status --show-token`, które ujawnia poświadczenie. Określenie „odczyt” nie oznacza więc automatycznie „bez ujawniania sekretów”. Nie wykonujemy takiej próby na prywatnym tokenie; sprawdzamy dopasowanie reguły bez uruchamiania polecenia. [Opcje `gh auth status`](https://cli.github.com/manual/gh_auth_status).

`Approve for me` wybiera recenzenta eskalacji; nie tworzy drugiej tożsamości Windows ani ograniczonego tokena. Profile uprawnień określają granice plików i sieci dla lokalnych poleceń. Architektura wykonawcy musi dodatkowo zapobiegać eskalacji agenta do konta z prywatnymi poświadczeniami. Nie traktujemy kont tworzonych wewnętrznie przez sandbox jako trwałego, samodzielnie zarządzanego magazynu sekretów. [Uprawnienia](https://learn.chatgpt.com/docs/permissions), [automatyczny przegląd](https://learn.chatgpt.com/docs/sandboxing/auto-review).

Hook `PreToolUse` z matcherem `^Bash$` może wykrywać `gh`/`glab` i przypominać o **profilu agenta**. Dotychczasową poradę „wyjdź z sandboxa, aby użyć logowania człowieka” trzeba przy wdrożeniu zastąpić „użyj zatwierdzonego wykonawcy z ograniczonym tokenem”. Nasz hook zwraca kontekst; nie wybiera poświadczenia ani nie wymusza izolacji. Nową definicję trzeba zatwierdzić w `/hooks`. [Hooki Codex](https://learn.chatgpt.com/docs/hooks).

## 10. Plan wdrożenia i sprawdzenia

1. Spisać dozwolone hosty, repozytoria/projekty i operacje. Wybrać osobny profil do odczytu i ewentualny profil do publikowania zmian; nie nadawać zapisu tylko dlatego, że agent edytuje pliki lokalnie.
2. Potwierdzić wersję/ofertę działającego GitLab (repozytorium wskazuje Self-Managed 19.5) i zainstalować `glab`. Sprawdzić `gh --version`, `glab version` i dostępne opcje logowania, bez aktualizowania narzędzi w ciemno.
3. Wybrać granicę izolacji: trwałe konto/runner/VM agenta albo broker bez dostępu do prywatnych poświadczeń człowieka. Określić również dozwolone eskalacje.
4. Wystawić ograniczone poświadczenia według sekcji GitHub/GitLab. Ustalić daty wygaśnięcia i niezależną rotację. Osobisty profil pozostawić w środowisku człowieka.
5. Skonfigurować wybór poświadczenia tylko dla procesów agenta, osobne ustawienia CLI i kontrolę braku sekretu. Bez automatycznego fallbacku na osobiste logowanie.
6. Przejrzeć reguły host execution i treść hooka. Sprawdzić także Git Credential Manager, SSH i alternatywne wykonawce; ograniczenia muszą dotyczyć rzeczywistych dróg dostępu.
7. Wykonać poniższe próby na przeznaczonych do tego prywatnych repozytoriach testowych. Dla tokena GitHub App uwzględnić jego odmienną tożsamość.

| Próba | Oczekiwany wynik |
|---|---|
| Odczyt dozwolonego prywatnego repozytorium | Sukces wymaganych operacji |
| Odczyt znanego, niedozwolonego prywatnego projektu | Brak dostępu; pamiętać, że 404 może ukrywać istnienie zasobu |
| Niedozwolony zapis | Odmowa; potencjalnie zmieniające dane próby wyłącznie na uzgodnionym projekcie testowym |
| Brak, wygaśnięcie lub odwołanie tokena agenta | Zatrzymanie operacji, bez użycia prywatnego profilu |
| Git przez HTTPS i SSH | Brak pominięcia ograniczeń przez osobisty helper/klucz |
| Dwie równoległe sesje człowiek/agent | Brak zmiany aktywnego logowania drugiej sesji |
| Kontrola wykonawcy | Zgodna tożsamość systemowa i brak dostępu do prywatnych magazynów człowieka |

Sam kod odpowiedzi API nie dowodzi wyboru właściwego tokena. Łączymy wynik z konfiguracją wykonawcy i metadanymi wybranego poświadczenia, bez ujawniania jego wartości. W dzienniku prób zapisujemy datę, wersje CLI, metodę autoryzacji, niejawny identyfikator profilu, host, projekt i wynik. Odwołanie tokena agenta ma być niezależne od osobistego logowania człowieka.

## 11. Zakres weryfikacji tej notatki

Sprawdzono źródła producentów wskazane przy twierdzeniach, 30 linków HTTPS, lokalny link do raportu oraz lokalną wersję `gh`. Składnia jednego bloku PowerShell przeszła kontrolę parserem. Przez `codex execpolicy check` potwierdzono, że obecna reguła prefiksu dopuszcza `gh auth status --show-token`; sprawdzono wyłącznie dopasowanie polityki, bez uruchamiania tego polecenia i bez ujawniania sekretu.

Nie wykonano prób autoryzacji nowymi tokenami, kontroli izolacji nowego wykonawcy ani operacji na GitLab. To kryteria odbioru przyszłego wdrożenia, a nie wyniki uzyskane przy pisaniu dokumentu.
