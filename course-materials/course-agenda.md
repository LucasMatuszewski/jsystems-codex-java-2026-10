## Program szkolenia

Szkolenie trwa trzy dni. Pierwszy dzień to środowiska pracy z Codex, bezpieczeństwo i kontekst istniejącej aplikacji. Drugi dzień prowadzi nową funkcjonalność od wymagań do działającego kodu w Jakarta EE i Spring Boot. Trzeci dzień to jakość, zgłoszenia i merge requesty, migracja starszego kodu oraz przeniesienie procesu na projekty zespołu. Proporcje między tematami dopasujemy po ankiecie przed szkoleniem.

## Dzień 1 - Codex w codziennych narzędziach i kontekst istniejącej aplikacji

Cel dnia: każdy uczestnik ma skonfigurowane środowisko, bezpieczne ustawienia Codex i kontekst projektu, z którego agent korzysta w każdej sesji.

### Agenci AI w pracy programisty Java: start i pierwsze zadanie | ok. 60 min

- Agenci AI w programowaniu w 2026 roku: co realnie przyspieszają, a gdzie wymagają kontroli
- Ryzyka: halucynacje, context rot, nadmierne zaufanie, koszty i dane firmowe
- Logowanie, plany ChatGPT i weryfikacja środowiska: Codex CLI, JDK, Maven, Git
- Ćwiczenie: pierwsze zadanie w repozytorium Cargo Tracker - Codex ustala, jak zbudować i uruchomić aplikację oraz testy, i sam to sprawdza
- Cel: działająca aplikacja szkoleniowa i wspólny punkt startowy

### Codex w IntelliJ IDEA, CLI, ChatGPT i VS Code: które narzędzie do jakiego zadania | ok. 75 min

- IntelliJ IDEA jako główne środowisko: Codex w czacie AI w IDE oraz Codex CLI w terminalu IntelliJ, przegląd zmian, uruchamianie i debugowanie w IDE
- Codex CLI: tryb interaktywny, polecenia jednorazowe, najważniejsze komendy, wybór modelu i poziomu rozumowania
- Aplikacja ChatGPT w trybie Codex: projekty, równoległe wątki i przegląd zmian w interfejsie graficznym
- Visual Studio Code z rozszerzeniem Codex i okno Agents (preview): kilka sesji agentów obok siebie w izolowanych worktree
- Jedno repozytorium, wiele narzędzi: zmiany przechodzą przez Git, więc nie trzeba kopiować kodu między edytorami
- Ćwiczenie: to samo pytanie o architekturę Cargo Tracker zadane w IntelliJ i w wybranym drugim narzędziu, porównanie przebiegu i wyniku
- Cel: każdy uczestnik wie, które środowisko wybrać do jakiego zadania

### Bezpieczny zakres działań Codex przed pierwszą zmianą w kodzie | ok. 45 min

- Tryby sandbox i zatwierdzania: tylko odczyt, zapis w workspace, dostęp do sieci
- Profile konfiguracji: inne uprawnienia do analizy, inne do implementacji
- Sekrety, pliki konfiguracyjne i dane firmowe: czego agent nie powinien czytać ani wysyłać
- Git jako siatka bezpieczeństwa: małe commity, branch na zadanie, łatwe wycofanie zmian
- Ćwiczenie: profil tylko do odczytu do analizy repozytorium i profil do implementacji, sprawdzenie, co agent może, a czego nie może zrobić
- Cel: kontrola nad tym, co Codex wykonuje w repozytorium

### Skills i pierwszy efekt: design system istniejącej aplikacji | ok. 60 min

- Skills: reużywalne umiejętności i workflow dla agenta, instalacja gotowych skills i ich dopasowanie
- Dlaczego tam, gdzie istnieje dobre narzędzie wiersza poleceń, wybieramy CLI zamiast MCP: mniej tokenów, prostsza konfiguracja, łatwiejsza kontrola
- Playwright CLI jako narzędzie agenta: przeglądarka sterowana z terminala
- Ćwiczenie: skill tworzący design system uruchomiony na działającej aplikacji Cargo Tracker - tokeny, zasady i wytyczne dla nowych widoków Jakarta Faces
- Cel: pierwszy artefakt projektu i zrozumienie, jak skills rozszerzają Codex

### Analiza istniejącej aplikacji i AGENTS.md | ok. 120 min

- Szybka orientacja w repozytorium: warstwy i model domenowy, zależności Maven, punkty wejścia, konfiguracja i sposób uruchamiania testów
- Pokaz trenera: ta sama metoda na dużym repozytorium open source, w którym ręczne czytanie kodu nie wystarcza
- javax i jakarta: czym różnią się Java EE 8 i Jakarta EE 10 w kodzie, zależnościach i serwerach aplikacyjnych
- Analiza dokumentacji technicznej i standardów projektu: README, CONTRIBUTING, formatowanie i reguły jakości kodu
- AGENTS.md na poziomie repozytorium i zagnieżdżone pliki dla modułów: co wpisać, czego unikać, jak sprawdzić, że działa
- Przygotowanie kontekstu i oszczędzanie tokenów: wskazywanie plików, krótkie instrukcje, kompaktowanie długiej sesji, dobór modelu do zadania
- Ćwiczenie: AGENTS.md dla Cargo Tracker i test w nowej sesji, czy agent stosuje zasady bez przypominania
- Cel: agent rozumie projekt i konwencje zespołu

## Dzień 2 - Nowa funkcjonalność od wymagań do działającego kodu

Cel dnia: czat AI do śledzenia ładunków przechodzi przez PRD, ADR i plan do działającej implementacji w Jakarta EE i Spring Boot, pokrytej testami.

### PRD funkcjonalności: czat AI do śledzenia ładunków | ok. 45 min

- Funkcjonalność dnia: pracownik pyta w języku naturalnym, gdzie jest ładunek i kiedy dotrze, a czat odpowiada na podstawie danych z Cargo Tracker
- Od zgłoszenia do PRD: cel, zakres, kryteria akceptacji, przypadki brzegowe
- Agent zadaje pytania zamiast zgadywać: jak wymusić doprecyzowanie wymagań
- Ćwiczenie: PRD czatu ładunków
- Cel: jednoznaczne wymagania, na których opiera się dalsza praca

### ADR i plan implementacji zgodne z architekturą projektu | ok. 60 min

- ADR: nowe REST API w aplikacji Jakarta EE i osobna usługa Spring Boot z modelem językowym - decyzja, alternatywy i konsekwencje
- Strategia testów: testy jednostkowe, integracyjne i scenariusze do weryfikacji w przeglądarce
- Plan w fazach z punktami kontrolnymi: co agent robi sam, a gdzie czeka na decyzję człowieka
- Ćwiczenie: ADR i plan implementacji dla funkcjonalności z PRD
- Cel: plan, który można przekazać agentowi do realizacji etapami

### REST API w aplikacji Jakarta EE 10 w rytmie TDD | ok. 75 min

- TDD z agentem: Red, Green, Refactor; agent pisze test przed kodem produkcyjnym
- Endpoint REST do odczytu stanu ładunku zgodny z modelem domenowym i konwencjami z AGENTS.md
- Uruchamianie testów i debugowanie w IntelliJ IDEA równolegle z pracą agenta
- Granularne commity po każdej zielonej fazie
- Ćwiczenie: endpoint śledzenia ładunku z testami
- Cel: działające i przetestowane API w istniejącej aplikacji

### Usługa Spring Boot z modelem językowym i wywoływaniem narzędzi | ok. 105 min

- Nowa usługa Spring Boot z Spring AI: klient czatu, prompt systemowy i wywoływanie narzędzi, które korzystają z API Cargo Tracker
- Klucz API po stronie użytkownika albo lokalny model: konfiguracja, sekrety i koszty
- Testy funkcji AI: co testować deterministycznie, a co sprawdzać scenariuszami
- Praca równoległa: osobne sesje agentów w izolowanych worktree i scalanie zmian
- Ćwiczenie: usługa czatu ładunków z testami, uruchomiona obok aplikacji Cargo Tracker
- Cel: własna funkcja AI w Javie, nie tylko korzystanie z narzędzi AI

### Widok Jakarta Faces i integracja całej funkcjonalności | ok. 75 min

- Nowy widok czatu w Jakarta Faces z PrimeFaces, zgodny z design systemem z pierwszego dnia
- Integracja widoku z usługą Spring Boot i obsługa błędów
- Ćwiczenie: kompletna funkcjonalność działająca od widoku, przez usługę AI, do danych w Cargo Tracker
- Cel: działająca funkcjonalność gotowa do weryfikacji jakości

## Dzień 3 - Jakość, zgłoszenia, migracja i merge requesty

Cel dnia: funkcjonalność przechodzi pętle jakości, każdy uczestnik naprawia własne zgłoszenie aż do merge requestu, a zespół ćwiczy migrację starszego kodu i przenosi proces na własne projekty.

### Pętle jakości: testy, weryfikacja w przeglądarce i niezależne code review | ok. 75 min

- Dlaczego skompilowany kod to za mało: pętla plan, test, implementacja, weryfikacja
- Uzupełnianie brakujących testów i sprawdzanie przypadków brzegowych
- Weryfikacja scenariusza użytkownika w przeglądarce przez agenta z Playwright CLI oraz krótki test manualny wykonany przez człowieka
- Code review z Codex w osobnej sesji lub przez sub-agenta recenzenta: bezpieczeństwo, zgodność z architekturą, czytelność
- Lista kontrolna weryfikacji kodu wygenerowanego lub zmodyfikowanego przez AI
- Ćwiczenie: dwie rundy weryfikacji czatu ładunków i poprawki uwag
- Cel: funkcjonalność sprawdzona testami, w przeglądarce i w code review

### Zgłoszenia, debugowanie i merge requesty w GitLabie | ok. 120 min

- GitLab CLI (glab) w sesji Codex: zgłoszenia, branche, merge requesty i komentarze z poziomu terminala
- Analiza błędu: stack trace, logi, odtworzenie błędu testem, który nie przechodzi, oraz debugger IntelliJ IDEA
- Opis merge requestu: zakres zmiany, testy, ryzyka i wskazówki dla recenzenta
- Odpowiadanie na uwagi z code review i reakcja na nieudany pipeline
- Ćwiczenie: każdy uczestnik bierze inne zgłoszenie z przygotowanej listy (błędy, brakujące testy, drobne usprawnienia) i prowadzi je od analizy do merge requestu, a potem recenzuje merge request innej osoby
- Cel: zmiana gotowa do scalenia zgodnie z procesem zespołu

### Refaktoryzacja i migracja z javax na jakarta pod osłoną testów | ok. 75 min

- Testy charakteryzujące przed zmianą kodu, którego nikt nie chce ruszać
- Refaktoryzacja małymi krokami: agent proponuje, testy potwierdzają
- Refaktoryzacje w IntelliJ IDEA i zmiany wykonywane przez Codex: kiedy które narzędzie
- Ćwiczenie: migracja wybranego modułu z wersji Jakarta EE 8 (javax) na Jakarta EE 10 i porównanie wyniku z oficjalną wersją projektu
- Cel: bezpieczna migracja starszego kodu z zachowaniem działania

### Wasz kod i standard pracy zespołu z Codex | ok. 90 min

- Ćwiczenie: przeniesienie procesu na repozytorium zespołu, jeśli pozwalają na to zasady bezpieczeństwa firmy - analiza, AGENTS.md i pierwsze zadanie; w przeciwnym razie kolejne zgłoszenie w Cargo Tracker
- Standard zespołowy: wspólne AGENTS.md, skills, profile uprawnień i proces weryfikacji
- Koszty i limity: nawyki, które ograniczają zużycie tokenów w codziennej pracy
- Retrospektywa i plan wdrożenia w zespole
- Cel: gotowy plan pracy z Codex w projektach zespołu


## Trasa warsztatowa uzgodniona po spotkaniu

28-30.10.2026, 09:00-16:00 Europe/Warsaw. Przerwy: 11:00-11:15, 13:00-13:30 i 14:30-14:45. Pracujemy na przygotowanych maszynach z Windows 11, w PowerShell, z kontami ChatGPT Business zapewnionymi przez trenera i własnymi projektami na GitLab szkoleniowym (self-managed 19.5). Plan awaryjny: [osobny profil Codex na własnym laptopie](agent-configs/codex/laptop-kurs/README.md).

1. **Dzień 1:** start kursu, podstawy AI, narzędzia Codex, konta, modele, profile i bezpieczeństwo.
2. **Dzień 2:** to samo pytanie w VS Code, CLI i IntelliJ; sandbox i profile; analiza jFTP i AGENTS.md ze sprawdzianem świeżej sesji; skills (instalacja w projekcie, pilotaż A/B, pomiar tokenów), CLI zamiast MCP; kontekst, dobór modelu i pokaz trenera Fineract (Sol i Luna); Eclipse Cargo Tracker: przygotowanie, analiza, PRD, ADR, plan, TDD, Playwright CLI i worktree. [Ćwiczenie](exercises/cargo-tracker.md).
3. **Dzień 3:** niezależny review (P08), [zgłoszenia i merge request GitLab](exercises/cargo-tracker-tickets.md), [CI/CD z review Codex w MR](exercises/cargo-tracker.md#cicd-w-gitlab-szkoleniowym), migracja javax na jakarta na gałęzi jakartaee8, pokaz hooków, [COBOL i agenci AI](Research/cobol-and-ai-agents-2026-10-28.md), standard zespołu i retrospektywa. Warianty Fineract dla uczestników są opcjonalne.

Po uzgodnieniu z klientem ćwiczenie czatu i osobnej usługi Spring AI zastępuje funkcja odczytu w istniejącej aplikacji. Spring Boot pozostaje kontekstem analizy Fineract. Playwright sprawdza rzeczywisty przepływ w dniu 2; wyciąganie design systemu (P05) pozostaje opcjonalne. jFTP poprzedza większą aplikację webową. Nie pracujemy na kodzie firmowym.

## Rejestr zmian

| Data | ID | Zmiana | Wcześniej | Powód |
|---|---|---|---|---|
| 2026-10-28 | JAVA-01 | jFTP, Cargo Tracker i Fineract w tej kolejności; analiza, skills A/B i mniejsze modele | Cargo Tracker od startu i nowa usługa czatu Spring AI | Uzgodniony nacisk na istniejący kod, zarządzanie agentami i pomiar tokenów |
| 2026-10-28 | JAVA-02 | Przygotowane VM Linux, szkoleniowy Business i indywidualny GitLab.com | Przygotowanie lokalne i repozytorium grupowe z oferty | Aktualne ustalenia organizacyjne |
| 2026-10-28 | JAVA-03 | VM z Windows 11, PowerShell i natywny sandbox Codex; dostęp RDP z adresem host:port, awaryjnie pulpit w przeglądarce | Zakładane VM Linux | Potwierdzone środowisko JSystems; nie zakładamy WSL ani gotowej listy zainstalowanych narzędzi |
| 2026-10-28 | JAVA-04 | Górne listy dni wyznaczają chronologię, po 360 minut netto i trzy przerwy. jFTP: P18, P20/P21, zapis AGENTS.md i sprawdzian świeżej sesji z P24; IntelliJ/CLI na tym samym pytaniu; jeden pilotaż A/B P28. Review Cargo kończy dzień 2; Fineract i pomiar tokenów poprzedzają GitLab i migrację w dniu 3. Testy P31 sprawdzają HTTP/JSON bez importu DTO; minimalne CI podlega lintowaniu, dostęp runnera wymaga osobnej kontroli. | Przeładowane listy, powielone ćwiczenia, trzy pary A/B, Fineract po migracji, testy zależne od nieistniejącego DTO | Brief E i zweryfikowane ustalenia dwóch recenzji; realny czas dla dziewięciu VM |
| 2026-10-29 | JAVA-05 | jFTP, AGENTS.md, skills i CLI/MCP w dniu 2, Fineract jako pokaz trenera; dzień 3: review, GitLab MR, CI/CD z review Codex, migracja, hooki, COBOL, standard zespołu. Ćwiczenia na GitLab szkoleniowym (19.5 na Azure) zamiast GitLab.com; plan awaryjny na laptopach. | jFTP i skills w dniu 1, Fineract jako ćwiczenie w dniu 3, GitLab.com | Dzień 1 skrócony przez wolne VM; zespół pracuje na GitLabie i priorytetem jest CI/CD |
