# Cargo Tracker: od analizy do merge requestu

Pracujemy na aplikacji Jakarta EE, ale ćwiczymy prowadzenie agenta: zakres, dowody, testy, podział pracy i review. Każdy pracuje na własnej VM i we własnym projekcie GitLab.com. Dzień 2: kroki 1-5. Dzień 3: krok 6.

**Status poleceń:** N = nie uruchomiono w przygotowaniu, polecenie do wykonania na VM uczestnika. Wszystkie poniższe bloki bash mają status N, poza blokami wyraźnie oznaczonymi R. Prompty są zadaniami dla uczestnika, nie raportem wykonanej implementacji. Składnię `glab` sprawdzono w oficjalnej dokumentacji 28.10.2026, bez logowania do GitLaba.

## Przygotowanie VM i własnego projektu, 15-25 minut

Uruchom osobno kontrole. Potrzebujesz JDK 17 z `javac`, Git, Node.js, Codex CLI, `glab`, curl oraz IntelliJ IDEA dostępnego z pulpitu. Zatrzymaj się przy brakującym narzędziu i zgłoś trenerowi.

```bash
java -version
```

```bash
javac -version
```

```bash
git --version
```

```bash
node --version
```

```bash
codex --version
```

```bash
glab version
```

```bash
curl --version
```

```bash
command -v idea
```

Brak `idea` w PATH nie wyklucza instalacji graficznej. Otwórz IntelliJ z pulpitu i sprawdź SDK projektu. W terminalu Codex sprawdź logowanie; nie wklejaj tokenów do rozmowy.

```bash
codex login status
```

```bash
glab auth login --hostname gitlab.com --web --git-protocol https
```

Ustaw własny login. Projekt ma powstać w przestrzeni osobistej, bez grupy. Dla Cargo używamy zwykłego klonu: wysyłanie płytkiego klonu do nowego serwera może zostać odrzucone. Zachowujemy licencję i historię upstreamu.

```bash
export GITLAB_LOGIN='WPISZ_SWÓJ_LOGIN'
```

```bash
git clone --branch master https://github.com/eclipse-ee4j/cargotracker.git cargo-tracker
```

```bash
cd cargo-tracker
```

```bash
git remote rename origin upstream
```

```bash
git fetch upstream jakartaee8:jakartaee8
```

```bash
glab repo create "gitlab.com/${GITLAB_LOGIN}/cargo-tracker-codex" --private --defaultBranch master --skipGitInit
```

```bash
git remote add origin "https://gitlab.com/${GITLAB_LOGIN}/cargo-tracker-codex.git"
```

```bash
git push -u origin master jakartaee8
```

Sprawdź w GitLabie dwie gałęzie, własną przestrzeń oraz widoczność prywatną. Jeśli potrzebne będzie logowanie Git przy pushu, dokończ je w terminalu, nie w czacie.

## Punkt odniesienia i uruchomienie

Sprawdzono 28.10.2026: `master` = `4d26b8fd59a7f0bac6e42d5d19a8cd1b379353b5`, Temurin 17.0.21+9, Maven Wrapper 3.9.16, Jakarta EE 10, Payara 6.2025.5. Pełny build: **35 testów, 0 błędów, 0 pominięć, 80 s** z zimnym cache. Wersja `jakartaee8` = `e6b8648cda2754aee39cb536c807b051cab74b61`: **29 testów, 0 błędów, 58 s**, także JDK 17. Nowszy upstream może zmienić wyniki; przed ćwiczeniem zanotuj SHA.

```bash
git rev-parse HEAD
```

```bash
./mvnw -B clean package
```

Oczekuj WAR `target/cargo-tracker.war` i raportów `target/surefire-reports`. Domyślny build obejmuje test integracyjny uruchamiający Payara Micro na **9090**. Spotless w fazie `process-sources` może sformatować kod; sprawdź diff przed commitem.

```bash
./mvnw cargo:run
```

Domyślna strona: `http://localhost:8080/cargo-tracker/`, śledzenie: `http://localhost:8080/cargo-tracker/public/track.xhtml`. Zatrzymuj serwer Ctrl+C w jego terminalu. Nie uruchamiaj kilku serwerów naraz. Sam napis `BUILD SUCCESS` nie potwierdza wdrożenia: Cargo potrafi wypisać go po błędzie startu. Potwierdź odpowiedź HTTP i treść strony. Na maszynie trenera 8080 był zajęty: start kończył się CLI130 przy create-domain. Sprawdzony wariant N dla VM uczestnika, oparty na rzeczywiście wykonanej próbie na 18080:

```bash
./mvnw -B -Dcargo.servlet.port=18080 cargo:run
```

Na 18080 potwierdzono stronę startową i public/track.xhtml (200), wyznaczanie tras (200), walidację parametrów i pustego raportu (400), SSE (200 z danymi) oraz brak endpointu statusu (404). Dla tego wariantu używaj w URL portu 18080. Przed ćwiczeniami rezerwacji przebuduj WAR z właściwym adresem wewnętrznego routingu, ponieważ jest filtrowany przy pakowaniu. Polecenie N, nie wykonano tego wariantu przebudowy:

```bash
./mvnw -B -Dwebapp.graphTraversalUrl=http://localhost:18080/cargo-tracker/rest/graph-traversal/shortest-path package
```

Po zakończeniu wariantu 18080 możesz użyć w drugim terminalu sprawdzonej procedury zatrzymania (N dla tej wersji polecenia):

```bash
./mvnw -B -Dcargo.servlet.port=18080 cargo:stop
```

Następnie zamknij oczekujący proces cargo:run przez Ctrl+C. Przekroczenie limitu czasu curl dla SSE jest spodziewane, jeśli strumień nadal pozostaje otwarty.

```bash
curl -i --max-time 10 http://localhost:8080/cargo-tracker/public/track.xhtml
```

```bash
curl -i --max-time 10 'http://localhost:8080/cargo-tracker/rest/graph-traversal/shortest-path?origin=SESTO&destination=AUMEL'
```

Mapa do pierwszego przeglądu: `src/main/java/org/eclipse/cargotracker/domain/model` to domena, `application/internal` to przypadki użycia, `infrastructure/persistence/jpa` to repozytoria, `interfaces` to adaptery REST/Faces/SSE. `org/eclipse/pathfinder` symuluje zewnętrzne wyznaczanie tras. `src/main/webapp/public/track.xhtml` korzysta z `interfaces/tracking/web/Track.java`. To pojedynczy moduł Maven WAR, z wieloma pakietami logicznymi.

Istnieją: GET `/rest/graph-traversal/shortest-path`, POST `/rest/handling/reports`, GET `/rest/cargo` jako SSE wszystkich ładunków. **Nie istnieje JSON GET statusu jednego ładunku po tracking ID.** SSE pozostawiamy bez zmian.

## 1. Analiza i instrukcje modułu, 25 minut

Cel: poznać drogę żądania i przygotować zwięzłe zasady pracy. Pierwsza sesja tylko czyta.

```bash
codex -s read-only
```

Prompt:

```text
Przeanalizuj tylko odczyt śledzenia ładunku w Cargo Tracker. Nie edytuj plików i nie uruchamiaj builda. Prześledź public/track.xhtml, Track, CargoTrackingViewAdapter, CargoRepository, JpaCargoRepository i Delivery. Wskaż istniejące zasoby REST oraz różnicę między SSE a JSON. Wypisz istniejące testy i trzy luki, każdą ze ścieżką pliku. Przygotuj w odpowiedzi projekt AGENTS.md dla pakietu interfaces/tracking: granice zmian, nazewnictwo, właściwe testy, zasada bez operacji zapisu w odczycie. Nie zgaduj poleceń. Rozdziel fakty i hipotezy.
```

Sprawdź trzy wskazane pliki samodzielnie. Oczekiwany wynik: mapa przepływu i krótki projekt instrukcji. Zapisz zaakceptowane instrukcje w `src/main/java/org/eclipse/cargotracker/interfaces/tracking/AGENTS.md`, ręcznie albo w nowej sesji z prawem zapisu. Nie proś sesji `read-only` o zapis.

## 2. PRD, plan i czerwony test, 35 minut

Cel: najpierw uzgodnić kontrakt. Przełącz się do nowej sesji z prawem zapisu i gałęzi funkcji.

```bash
git switch -c feature/cargo-status
```

```bash
codex -s workspace-write
```

Prompt:

```text
Przygotuj docs/PRD.md i docs/plan.md dla GET /rest/cargo/{trackingId}/status. Najpierw przeczytaj istniejące instrukcje i kod. Kontrakt: 200 application/json z trackingId, transportStatus, routingStatus, misdirected i lastKnownLocation (UN/LOCODE); 404 dla poprawnego, nieznanego ID; 400 dla ID spoza [A-Za-z0-9]{4,32}. Nie normalizuj wielkości liter. Brak ID w URL pozostaje zwykłym brakiem trasy. Zwracaj DTO, bez encji JPA, bez store(), zdarzeń i JMS. Nie zmieniaj /rest/cargo SSE. Opisz przypadki testowe i kolejność red-green-refactor. Zapisz dokumenty i zaczekaj na moje potwierdzenie przed implementacją. Następnie, po potwierdzeniu, przygotuj tylko testy kontraktu w nowym CargoStatusResourceTest; pokaż ich oczekiwaną porażkę i jej przyczynę. Jeśli trzeba dodać bibliotekę testową, uzasadnij to przed zmianą POM.
```

Sprawdź znaczenie statusów w `Delivery`; nie utożsamiaj `transportStatus` z tekstem wyświetlanym przez Faces. Oczekiwany wynik: dokumenty oraz czerwone testy z powodu brakującego zasobu, nie z powodu braku internetu czy zależności.

## 3. Równoległe agenty i worktrees, 60 minut

Cel: trzy rozłączne zakresy przy wspólnym kontrakcie. Najpierw zapisz zatwierdzone dokumenty i czerwone testy w jednym commicie, jawnie wskazując pliki. Worktrees tworzysz świadomie na potrzeby tego ćwiczenia. Każdy ma inną gałąź; agenci nie wykonują Git push ani commitów.

```bash
git worktree add ../cargo-tracker.worktrees/backend -b task/status-backend
```

```bash
git worktree add ../cargo-tracker.worktrees/tests -b task/status-tests
```

```bash
git worktree add ../cargo-tracker.worktrees/ui -b task/status-ui
```

Otwórz osobne terminale z Codexem dla tych katalogów. Backend i testy uruchamiaj kolejno przy testach integracyjnych, żeby nie walczyły o 9090. Prompt dla sesji koordynującej:

```text
Podziel realizację zaakceptowanego PRD na trzy równoległe sesje w przygotowanych worktrees. Napisz dla każdej kompletny brief z kontraktem, ścieżkami i kryteriami końca. Backend może zmieniać wyłącznie nowe CargoStatusResource.java i CargoStatusDto.java w interfaces/tracking/rest. Testy mogą zmieniać tylko CargoStatusResourceTest.java oraz CargoStatusDtoTest.java w odpowiadającym src/test/java; testy piszą przeciw zaakceptowanemu kontraktowi, nie odgadują implementacji. UI może zmienić wyłącznie nowy src/main/webapp/public/status-help.xhtml: krótka angielska instrukcja, link do istniejącej strony track.xhtml, bez nowych beanów i bez zależności od REST. Każdy agent czyta PRD i zwraca diff, wynik sprawdzenia oraz niewykonane kontrole. Nie zmieniaj POM równolegle, nie formatuj cudzych plików, nie wykonuj commitów. Zaczekaj na wszystkich. Przy konflikcie kontraktu wróć do PRD zamiast poprawiać go po cichu.
```

Dla każdego worktree skopiuj jego brief do odpowiedniej sesji. Po odebraniu zmian uczestnik przegląda diff i wykonuje jawny commit każdego zakresu. Na gałęzi `feature/cargo-status` scal kolejno `task/status-tests`, `task/status-backend`, `task/status-ui`, używając merge lub cherry-pick wybranych commitów. Nie wykonuj buildów trzech kopii jednocześnie na VM 8 GB.

Prompt po scaleniu:

```text
Sprawdź scalony wynik względem PRD. Uruchom testy zasobu i DTO, potem pełne ./mvnw -B clean package. Doprowadź testy do zielonego bez osłabiania asercji i bez pomijania testów. Pokaż, gdzie testy odróżniają 400 od 404, jak potwierdzają brak zapisu i jak uruchamiany jest test HTTP: samo wywołanie metody Java nie sprawdza routingu ani serializacji. Otwórz w przeglądarce public/status-help.xhtml i istniejące public/track.xhtml, sprawdź link i ładunek ABC123. Zgłoś każdą niewykonaną kontrolę.
```

Sprawdź 200/400/404 i zgodność JSON z PRD. Wynik: zielone testy, działający nowy widok Faces i śledzenie ABC123. Usuń trzy worktrees dopiero po zachowaniu ich commitów; wykonaj `git worktree remove` dla każdego katalogu, potem `git worktree prune`. Nie używaj `--force`.

## 4. Review z nowej sesji, 20 minut

Cel: niezależne spojrzenie bez historii autora. Uruchom osobną sesję tylko do odczytu.

```bash
codex -s read-only
```

```text
Zrób review różnicy feature/cargo-status względem master. Nie poprawiaj kodu. Sprawdź zgodność z docs/PRD.md, routing HTTP i SSE, walidację, ujawnianie encji, skutki uboczne odczytu, testy i nowy widok Faces. Dla każdej uwagi podaj istotność, plik i linię, scenariusz błędu oraz propozycję sprawdzenia. Brak dowodów oznacz jako hipotezę. Na końcu wymień wykonane i niewykonane kontrole.
```

Uczestnik ocenia uwagi, zleca poprawki w sesji autora i ponawia właściwe testy. Oczekiwany wynik: każda uwaga ma rozstrzygnięcie i dowód, a nie automatyczne przyjęcie opinii agenta.

## 5. Merge request, 15 minut

Cel: dać drugiej osobie kontekst i dowody. Po weryfikacji i jawnych commitach:

```bash
git push -u origin feature/cargo-status
```

```text
Przygotuj docs/mr-description.md: problem, kontrakt endpointu, przykład odpowiedzi, zakres UI, lista testów z rzeczywistymi wynikami i ryzyka. Nie twórz fikcyjnych wyników CI. Uwzględnij rozstrzygnięcia review. Nie wysyłaj niczego samodzielnie.
```

```bash
glab mr create --repo "gitlab.com/${GITLAB_LOGIN}/cargo-tracker-codex" --source-branch feature/cargo-status --target-branch master --title 'Dodaj odczyt statusu ładunku' --description-file docs/mr-description.md --draft --yes
```

Sprawdź URL i diff MR, gałąź docelową `master` oraz własny projekt. Wynik: draft MR, bez automatycznego merge. Brak pipeline w nowym projekcie jest możliwy; lokalne wyniki testów nadal muszą być opisane uczciwie.

## 6. Migracja wydzielonego zakresu javax do jakarta, 60-90 minut

Cel: mała migracja z testami i porównaniem. `jakartaee8` używa nazw pakietów `javax`, choć zależność nazywa się `jakarta.jakartaee-api:8.0.0`. Ta gałąź nie ma `mvnw`. Przygotuj czyste drzewo, przejdź na jej nową gałąź i zachowaj wrapper z `master`:

```bash
git switch -c exercise/migrate-location jakartaee8
```

```bash
git restore --source=master -- mvnw .mvn
```

```bash
./mvnw -B clean package
```

Prompt:

```text
Przeczytaj POM i testy gałęzi jakartaee8 oraz porównaj domain/model/location z master. Przygotuj PRD i plan wydzielenia edukacyjnego modułu migration-location, obejmującego UnLocode i Location oraz testy ich kontraktu. Zaczekaj na potwierdzenie. Potem utwórz niezależny moduł Maven w migration-location/pom.xml, bez dodawania go do głównego WAR. Najpierw zachowaj zachowanie na javax i testy na JDK 17, potem zmień wyłącznie migrowane API na jakarta.persistence i jakarta.validation z API Jakarta EE 10. Zastosuj właściwą wersję JUnit do nowego modułu i zachowaj zależność commons-lang3 potrzebną klasom gałęzi EE8 z Validate. Nie rób globalnej zamiany javax: javax.sql, javax.naming i javax.crypto należą do Java SE. Nie zmieniaj serwera ani PrimeFaces w starym WAR. Porównaj wynik z master, wyjaśnij różnice i podaj ograniczenia: to migracja wydzielonego modułu, nie całej aplikacji. Uruchom testy przed i po migracji, a także testy starego WAR; zapisz wyniki i diff.
```

Polecenie N, moduł powstanie dopiero podczas ćwiczenia:

```bash
./mvnw -B -f migration-location/pom.xml test
```

Sprawdź zachowane reguły domeny, importy oraz brak przypadkowych zmian w WAR. Wynik: mały moduł kompilujący się z `jakarta`, testy zielone przed i po zmianie, stary WAR nadal sprawdzalny. Częściowe przepisanie jednego pakietu wewnątrz starego WAR bez wydzielenia nie jest poprawną migracją całej aplikacji.

## Co może opóźnić pracę

Na VM 8 GB zaplanuj jeden Maven/Payara naraz; IntelliJ i przeglądarka też zużywają RAM. Rezerwuj 10-15 minut na pierwsze pobieranie, 2-5 minut na kolejne pełne testy. Sama Payara Micro ma około 102 MB, dystrybucja serwera około 173 MB; cache i rozpakowany serwer zajmują więcej. Potrzebne są GitHub, Maven Central, GitLab.com i dostęp Codexa. Zajęte 8080/9090/4848 albo brak JDK to problemy środowiska, nie czerwony test TDD.

Źródła składni: [tworzenie projektu](https://docs.gitlab.com/cli/repo/create/), [logowanie](https://docs.gitlab.com/cli/auth/login/), [merge request](https://docs.gitlab.com/cli/mr/create/). Buildy wykonano w izolowanym katalogu z lokalnym cache; raport trenera zawiera dokładne polecenia i logi.
