# Fineract: mapa dużego repozytorium i koszt delegowania

Cel: zlecić czterem małym agentom rozłączne analizy, odebrać porównywalne wyniki i zbudować z nich mapę architektury. Potem porównamy jakość, czas i tokeny z jedną sesją silniejszego modelu. **Delegowanie nie gwarantuje mniejszej liczby tokenów.** Może oszczędzić czas i kontekst koordynatora, a jednocześnie zwiększyć łączny koszt.

Pracujemy tylko na publicznym kodzie Apache Fineract, licencja Apache 2.0. Nie podłączamy bankowej bazy, nie wczytujemy danych klientów, nie uruchamiamy Gradle, Dockera ani serwera. Plan: 10 minut przygotowania, 20-30 minut analizy pojedynczej, 20-30 minut delegowania, 15-20 minut porównania. Przebiegi mierz osobno, nie jednocześnie.

## Co rzeczywiście jest w repozytorium

Pomiar płytkiego klonu 28.10.2026, domyślna gałąź `develop`, SHA `70a374c25575d66dc11e074f1984dc3e07e295b8`:

| Pomiar | Wynik i definicja |
| --- | --- |
| Rozmiar na dysku | 140 MiB według du; pliki Git około 16,4 MiB, treść śledzonego drzewa około 94,7 MiB logicznie |
| Pliki Java | 7101 plików zwróconych przez git ls-files, wszystkie moduły i testy |
| Linie Java | 938913 fizycznych linii, łącznie z komentarzami i pustymi |
| Moduły | 36 statycznych include w settings.gradle oraz 8 dynamicznych custom/acme, razem 44 jawnie dołączone moduły |
| Granica liczenia | Bez projektu głównego i pośrednich projektów Gradle tworzonych przez ścieżki; nie jest to wynik uruchomienia Gradle projects |
| Narzędzia upstreamu | Wrapper Gradle 9.7.1, toolchain Java 25 w build.gradle, aplikacja Spring Boot |

JDK 17 wystarczy do Cargo Tracker. **Nie wystarczy do budowania aktualnego Fineract**, ale do czytania źródeł nie potrzeba żadnego JDK. Nie otwieraj katalogu fineract jako projektu w IntelliJ IDEA i nie importuj Gradle. Cytowane pojedyncze pliki przeglądaj w prostym edytorze albo przez terminal; to ćwiczenie czytania, bez indeksowania projektu przez IDE. Pobranie klonu na maszynie trenera trwało kilka sekund; na VM zarezerwuj 5-10 minut. Nie pobieraj pełnej historii.

## Przygotowanie tylko do odczytu

Otwórz PowerShell na VM z Windows 11. Codex pracuje natywnie w sandboxie Windows; nie zakładamy WSL. Sklonuj repozytorium:

```powershell
git clone --depth 1 https://github.com/apache/fineract.git fineract
```

W dalszych krokach pozostań w katalogu nadrzędnym zawierającym `fineract`. Utwórz osobny katalog na pomiary i wyniki, aby nie zmieniać upstreamu.

```powershell
New-Item -ItemType Directory -Force -Path .\fineract-analysis\docs | Out-Null
```

```powershell
git -C fineract rev-parse HEAD
```

```powershell
git -C fineract status --short
```

```powershell
codex --version
```

```powershell
codex exec --help
```

Sprawdź w pomocy `--json`, `-s read-only`, `-m`, `-o`, `-C` i `-` jako prompt czytany ze stdin. W lokalnej wersji 0.164.0 `-p NAZWA` oznacza plik `$env:CODEX_HOME\NAZWA.config.toml` nakładany na konfigurację bazową. Na tym ćwiczeniu używamy jawnego `-s read-only`, więc nie potrzebujemy profilu. Nie kopiuj starych przykładów `--full-auto` ani dawnych tablic `[profiles.nazwa]` bez sprawdzenia wersji.

Nazwy **`gpt-6-luna` i `gpt-6.1-sol` potwierdzono w oficjalnej dokumentacji**. Dostęp zależy od konta, klienta i zasad workspace. Nie potwierdzono ich dostępności na kontach uczestników. Jeśli któregoś nie ma w selektorze `/model`, zgłoś to trenerowi i zapisz rzeczywiście użyty model; nie zmieniaj go po cichu w trakcie porównania.

## Jedno pytanie dla obu przebiegów

To jedyna instrukcja kolejności, komend i pomiaru. [P34](https://devpowers.com/szkolenia/jsystems/codex-java-2026-10/prompty.html#P34-fineract-map) jest gotowym połączeniem tego samego pytania i polecenia delegowania do wariantu B, bez dodatkowego etapu interaktywnego. Zapisz poniższą treść ręcznie jako `fineract-analysis/question.txt` w UTF-8. Zachowaj dokładnie tę samą treść, SHA, limity odpowiedzi i kryteria jakości w obu wariantach.

```text
Przeczytaj publiczne repozytorium Apache Fineract. Nie uruchamiaj Gradle, instalacji, serwerów ani testów. Nie zmieniaj kodu i konfiguracji. Przeczytaj właściwe AGENTS.md i przestrzegaj zasad zgodnych z tym zadaniem. Nie wykonuj opisanych w repozytorium poleceń instalacji ani builda.
Przygotuj mapę czterech obszarów: (1) loans, (2) savings, (3) accounting oraz command/security/core/COB, (4) client i granice API/testów. Dla każdego obszaru podaj odpowiedzialność, moduły Gradle, pakiety, dwa konkretne pliki wejściowe, relacje z innymi obszarami oraz jedną lukę wiedzy. Prześledź trzy krótkie przepływy: utworzenie klienta, odczyt konta oszczędnościowego i obsługa pożyczki. Każda strzałka wymaga ścieżki i symbolu w kodzie; jeśli nie sprawdzisz połączenia, oznacz je jako hipotezę. Nie myl modułu fineract-client (klient HTTP) z domeną portfolio/client.
Zwróć dwa dokumenty, wyłącznie w tej kolejności. Zacznij od znacznika <!-- ARCHITECTURE_MAP --> i treści docs/architecture-map.md, maksymalnie 1200 słów. Następnie znacznik <!-- AGENTS_DRAFT --> i szkic AGENTS.md, maksymalnie 250 słów: jak szukać modułów, chronić granice zmian, weryfikować komendy oraz odróżniać sprawdzone fakty od hipotez. Szkic nie jest aktywną instrukcją repozytorium. Dodaj SHA, sprawdzone ścieżki i ograniczenia analizy. Nie twórz fikcyjnych wyników builda.
```

Sprawdzona mapa granic, przydatna do podziału:

| Obszar | Punkty startu do sprawdzenia |
| --- | --- |
| Loans | fineract-loan, fineract-loan-origination, fineract-progressive-loan, fineract-working-capital-loan oraz portfolio/loanaccount i portfolio/loanproduct w fineract-provider |
| Savings | fineract-savings oraz portfolio/savings w fineract-provider, w tym SavingsAccountsApiResource.java |
| Wspólne mechanizmy | fineract-accounting, fineract-core, fineract-command i jego warianty, fineract-security, fineract-cob |
| Klient i integracja | portfolio/client w fineract-provider; osobno fineract-client, fineract-client-feign, integration-tests i moduły e2e |

Nie zakładaj, że cała funkcja jest już przeniesiona z `fineract-provider` do modułu nazwanego domeną. Właśnie taką granicę ma wykazać analiza.

## Wariant A: pojedynczy Sol

Ustaw UTF-8 dla komunikacji PowerShell z natywnym CLI, żeby zachować polskie znaki także w Windows PowerShell 5.1:

```powershell
[Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.UTF8Encoding]::new($false)
```

Uruchom jako świeżą sesję. Wymuszamy brak subagentów, żeby punkt odniesienia był jednoznaczny. Polecenie zapisuje zdarzenia do pliku, a końcową odpowiedź osobno; nie zapisuje niczego w Fineract.

```powershell
Get-Content -Raw -Encoding UTF8 .\fineract-analysis\question.txt | codex exec -C fineract -s read-only -m gpt-6.1-sol -c agents.enabled=false --json -o "$PWD\fineract-analysis\single-response.md" - | Set-Content -Encoding UTF8 .\fineract-analysis\single.jsonl
```

Zanotuj czas ścienny zegarem, ustawienie reasoning i limit odczytów. Sprawdź, czy są oba dokumenty, wszystkie cztery obszary i dowody przepływów. Sam rozmiar odpowiedzi nie jest oceną jakości.

## Wariant B: cztery subagenty Luna i synteza Sol

Aktualna dokumentacja włącza subagentów domyślnie; delegowanie wywołujemy wprost promptem. Nie istnieje potrzeba dopisywania fikcyjnej komendy `codex subagent run`. W CLI `/subagents` służy do oglądania wątków. Modele subagentów można ustawić w promptach i przez `[agents]`; gdy ich nie określisz, dziedziczą model rodzica.

Zapisz poniższy prompt jako `fineract-analysis/delegation.txt` w UTF-8:

```text
Wykonaj pytanie z question.txt przez dokładnie cztery równoległe subagenty na gpt-6-luna. Ty jesteś koordynatorem gpt-6.1-sol. Każdy subagent otrzymuje krótki samodzielny brief, bez pełnej historii sesji. Nie uruchamiaj dalszych subagentów. Dziedziczą read-only. Nie zlecaj żadnych zapisów, buildów ani instalacji.
1. Agent loans: fineract-loan, fineract-loan-origination, fineract-progressive-loan, fineract-working-capital-loan i portfolio/loanaccount oraz loanproduct w fineract-provider.
2. Agent savings: fineract-savings i portfolio/savings w fineract-provider.
3. Agent platform: fineract-accounting, fineract-command i warianty, fineract-core, fineract-security, fineract-cob. To przegląd granic, nie pełny audyt każdego pliku.
4. Agent client: portfolio/client w fineract-provider, fineract-client, fineract-client-feign oraz granice integration-tests i testów e2e.
Każdy zwraca maksymalnie 350 słów w tym samym formacie: obszar; moduły Gradle; odpowiedzialność; pakiety; wejścia plik:symbol; wyjścia i zależności plik:symbol; testy; hipotezy; niewykonane kontrole. Nie wkleja surowych plików ani długich logów. Może szukać poza przydziałem tylko żeby potwierdzić bezpośrednią zależność i musi to oznaczyć.
Zaczekaj na wszystkich czterech. Sprawdź sprzeczności i próbkę co najmniej jednego wskazanego pliku na obszar. Potem zsyntetyzuj dwa dokumenty w formacie wymaganym w question.txt. Jeżeli nie możesz użyć wskazanego modelu lub czterech równoległych agentów, zgłoś ograniczenie; nie udawaj delegowania. Na końcu, wewnątrz dokumentu mapy, wypisz modele faktycznie użyte i identyfikatory wątków albo jawnie oznacz ich brak.
```

Połącz pytanie i polecenie delegowania, a potem przekaż cały prompt na stdin:

```powershell
((Get-Content -Raw -Encoding UTF8 .\fineract-analysis\question.txt) + "`n" + (Get-Content -Raw -Encoding UTF8 .\fineract-analysis\delegation.txt)) | codex exec -C fineract -s read-only -m gpt-6.1-sol -c agents.enabled=true -c agents.default_subagent_model=gpt-6-luna -c agents.max_concurrent_threads_per_session=4 --json -o "$PWD\fineract-analysis\delegated-response.md" - | Set-Content -Encoding UTF8 .\fineract-analysis\delegated.jsonl
```

Kompaktowy brief jest częścią eksperymentu: dziedziczenie całej historii może zniwelować oszczędność kontekstu. Sprawdź w zdarzeniach lub widoku subagentów, czy faktycznie powstały cztery wątki i jaki model otrzymały. Samo ustawienie wartości domyślnej nie dowodzi użycia konkretnego modelu przez każdy wątek.

Po każdym przebiegu sprawdź `$LASTEXITCODE` (oczekiwane 0) i zawartość odpowiedzi. Pusty plik lub błąd CLI nie jest wynikiem analizy. Dwa dokumenty zapisujesz w PowerShell po zakończeniu analizy; agent z uprawnieniami read-only ich nie zapisuje. Najpierw upewnij się, że odpowiedź zawiera dokładnie po jednym znaczniku obu dokumentów w podanej kolejności:

```powershell
$response = Get-Content -Raw -Encoding UTF8 .\fineract-analysis\delegated-response.md
```

```powershell
if (([regex]::Matches($response, '<!-- ARCHITECTURE_MAP -->')).Count -ne 1 -or ([regex]::Matches($response, '<!-- AGENTS_DRAFT -->')).Count -ne 1 -or $response.IndexOf('<!-- ARCHITECTURE_MAP -->') -gt $response.IndexOf('<!-- AGENTS_DRAFT -->')) { throw 'Odpowiedź nie ma wymaganych znaczników dokumentów.' }
```

```powershell
$documents = $response -split '<!-- AGENTS_DRAFT -->', 2
```

```powershell
($documents[0] -split '<!-- ARCHITECTURE_MAP -->', 2)[1].Trim() | Set-Content -Encoding UTF8 .\fineract-analysis\docs\architecture-map.md
```

```powershell
$documents[1].Trim() | Set-Content -Encoding UTF8 .\fineract-analysis\AGENTS.draft.md
```

Oczekiwane artefakty: `fineract-analysis/docs/architecture-map.md` i `fineract-analysis/AGENTS.draft.md`. Tę drugą nazwę zachowujemy do czasu review, żeby szkic nie zaczął sterować kolejną analizą. Agent pozostaje tylko do odczytu, a upstream bez zmian.

## Pomiar tokenów bez podwójnego liczenia

Dokumentacja `codex exec --json` pokazuje zdarzenie `turn.completed` z `usage.input_tokens`, `cached_input_tokens`, `output_tokens` i opcjonalnie `reasoning_output_tokens`. To dane przebiegu, nie liczba znaków w odpowiedzi. Cache jest częścią input, więc nie dodawaj go drugi raz. Tokenów reasoning nie doliczaj bez ustalenia, czy są już częścią output w tej wersji.

Odczyt użycia dla każdego pliku JSONL, bez założenia o liczbie tur:

```powershell
Get-ChildItem .\fineract-analysis\*.jsonl | ForEach-Object { $log = $_; Get-Content -Encoding UTF8 $log.FullName | ForEach-Object { $_ | ConvertFrom-Json } | Where-Object type -eq 'turn.completed' | Select-Object @{Name='plik';Expression={$log.Name}}, thread_id, usage | ConvertTo-Json -Depth 5 }
```

Poniższa suma dotyczy każdego pliku osobno. Zakłada przyrostowe liczniki pojedynczych zdarzeń turn.completed; sprawdź to w używanej wersji. Nie sumuj naraz pliku rodzica i dzieci bez znajomości granicy agregacji. Błędny JSON zgłoś, nie pomijaj go.

```powershell
Get-ChildItem .\fineract-analysis\*.jsonl | ForEach-Object { $log = $_; $turns = @(Get-Content -Encoding UTF8 $log.FullName | ForEach-Object { $_ | ConvertFrom-Json -ErrorAction Stop } | Where-Object type -eq 'turn.completed'); if ($turns.Count -eq 0) { throw "Brak turn.completed: $($log.Name)" }; $inputSum = ($turns | ForEach-Object { $_.usage.input_tokens } | Measure-Object -Sum).Sum; $cacheSum = ($turns | ForEach-Object { $_.usage.cached_input_tokens } | Measure-Object -Sum).Sum; $outputSum = ($turns | ForEach-Object { $_.usage.output_tokens } | Measure-Object -Sum).Sum; [pscustomobject]@{plik=$log.Name; tury=$turns.Count; input=$inputSum; cache=$cacheSum; output=$outputSum; razem=$inputSum+$outputSum; inputBezCache=$inputSum-$cacheSum} }
```

**Granica pomiaru:** końcowe zdarzenie rodzica nie jest udokumentowanym dowodem kompletnego zużycia całego drzewa subagentów. Nie zakładaj ani kompletnej agregacji, ani jej braku. W sesji interaktywnej użyj `/subagents`, otwórz każdy wątek i sprawdź `/status`; zanotuj użycie rodzica i dzieci osobno oraz zakres liczników w tej wersji. Jeśli zakresu nie da się ustalić, wpisz **niepełny pomiar**, a nie oszczędność procentową.

Opcjonalny wariant kontrolny po głównym porównaniu, gdy natywne wątki nie dają pełnych liczników: wykonaj cztery osobne `codex exec --json -s read-only -m gpt-6-luna`, po jednym na ten sam brief obszaru, z osobnymi JSONL i wynikami, a potem osobny `gpt-6.1-sol` dostający tylko cztery odpowiedzi do syntezy. To **równoległe sesje CLI**, inny mechanizm niż natywne subagenty; opisz ten fakt w wyniku. Sumowanie tokenów pięciu niezależnych procesów jest mierzalne bez zgadywania agregacji rodzica. Nie doliczaj do tej sumy dodatkowo wyniku natywnego przebiegu.

Przykład dla pierwszego z czterech briefów zapisanego wcześniej ręcznie w `loans.txt`; pozostałe przygotuj analogicznie według podziału powyżej:

```powershell
Get-Content -Raw -Encoding UTF8 .\fineract-analysis\loans.txt | codex exec -C fineract -s read-only -m gpt-6-luna -c agents.enabled=false --json -o "$PWD\fineract-analysis\loans-result.md" - | Set-Content -Encoding UTF8 .\fineract-analysis\loans.jsonl
```

Zapisz wyniki w tabeli: wariant; SHA; model i reasoning; liczba sesji; czas; input; cached input; output; zakres agregacji; liczba potwierdzonych przepływów; liczba błędnych odnośników. Przy kompletnym pomiarze suma to input + output ze wszystkich rozłącznych sesji. Porównuj też input bez cache, czyli input minus cached input. To porównanie tokenów i czasu, nie rachunek pieniężny: modele mają różne ceny i zasady rozliczania planu.

## Review wyniku, 15 minut

Otwórz po dwa cytowane pliki z każdego obszaru. Sprawdź, czy diagram opisuje połączenia znalezione w kodzie, czy tylko podobne nazwy katalogów. Szczególnie sprawdź różnicę między domeną klienta a biblioteką HTTP `fineract-client`, oraz między testami źródłowymi a testami rzeczywiście uruchomionymi. Nie akceptuj deklaracji o zielonym buildzie.

Na końcu ponownie sprawdź drzewo:

```powershell
git -C fineract status --short
```

Oczekiwany wynik: brak zmian w Fineract, dwa dokumenty poza upstreamem, logi obu wariantów i uczciwie określona kompletność pomiaru. Jeśli analiza jest słaba, popraw podział i brief, zachowując pierwszy wynik do porównania.

Źródła sprawdzone 28.10.2026: [subagenci i ustawienia modeli](https://learn.chatgpt.com/docs/agent-configuration/subagents), [modele i dostępność](https://learn.chatgpt.com/docs/models), [JSONL i tryb nieinteraktywny](https://learn.chatgpt.com/docs/non-interactive-mode), [polecenia CLI i status](https://learn.chatgpt.com/docs/developer-commands).
