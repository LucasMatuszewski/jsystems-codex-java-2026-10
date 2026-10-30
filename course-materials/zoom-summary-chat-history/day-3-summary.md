# Podsumowanie — dzień 3, 30 października 2026

Trzeciego dnia szkolenia JSystems OpenAI Codex Java kontynuowaliśmy pracę z Codexem i analizę aplikacji Java jFTP. Ćwiczenia łączyły konfigurację środowiska, organizację pracy agentów oraz dokumentowanie zastanego projektu. W dalszej części dnia zakres pracy przesunął się od samego rozpoznania aplikacji do planowania pionowego wycinka z asystentem AI, a następnie do integracji repozytorium z procesem CI/CD.

## Środowisko Codex i uprawnienia

Dzień rozpoczął się od uruchomienia maszyn wirtualnych i aktualizacji Codexa, gdy narzędzie o to poprosi. Pokazano ustawienia konfiguracji Codexa na poziomie projektu oraz użytkownika, w tym opcje dotyczące sandboxa Windows. Tryb `danger-full-access` był demonstracją laboratoryjną, której prowadzący wyraźnie zabronił stosować na laptopach firmowych. Nie należy traktować przykładowych ustawień o szerokich uprawnieniach jako zalecanej konfiguracji do codziennej pracy.

Przećwiczono także sprawdzenie sandboxa Windows MXC: przykładowe polecenie testowe zwróciło `MXC_OK`, a kod zakończenia wyniósł `0`. Omówiono ustawienia Windows i funkcje związane z historią planowania oraz zapobieganiem uśpieniu. Wśród źródeł do dalszego sprawdzenia znalazły się [dokumentacja sandboxa Windows w Codexie](https://learn.chatgpt.com/docs/windows/windows-sandbox?surface=cli#configure-the-windows-sandbox) oraz [Windows Dev Drive](https://learn.microsoft.com/en-us/windows/dev-drive/). Konfigurację środowiska należy dostosować do polityk organizacji, a nie kopiować bez weryfikacji ustawienia z demonstracji.

Prowadzący pokazał również `eza` jako alternatywę dla `ls` i `tree`, a także wspomniał o Nerd Fonts. Są to narzędzia poprawiające wygodę pracy w terminalu i sposób wyświetlania informacji; nie stanowią wymogu dla projektu jFTP.

## Modele, rankingi i decyzje typowane

W porównywaniu modeli pojawiły się [Artificial Analysis](https://artificialanalysis.ai/) i [Benchmark Heaven](https://benchmarkheaven.com/jev-models). Wątek modeli decyzyjnych dotyczył [System One i Jev](https://typesafe.ai/blog/introducing-system-one-models-and-jev) oraz [TypeSafe](https://typesafe.ai/). Na czacie pojawił się też Basal jako silnik decyzji typowanych dla polskiego i angielskiego: wyboru, odpowiedzi tak/nie oraz oceny. Udostępniono [model Basal](https://huggingface.co/Remek/basal-omni-1.0-ultra) i [dokumentację decyzji w API OpenAI](https://developers.openai.com/api/docs/guides/decisions).

## Instrukcje projektu, dokumentacja i narzędzia agenta

W pracy nad jFTP punktem wyjścia miało być dostosowanie `AGENTS.md` do faktycznej struktury i potrzeb aplikacji. Zadanie obejmowało ogólny opis projektu, przedstawienie katalogów wysokiego poziomu, usunięcie niepasujących odniesień do materiałów kursowych, opis obsługiwanych języków oraz uzupełnienie wskazówek dotyczących ręcznej kontroli aplikacji desktopowej. Uzgodniony workflow z przykładowego pliku `AGENTS.md` miał zostać przeniesiony i dopasowany do jFTP; instrukcje niezwiązane z aplikacją należało poprawić, bez porzucania całego workflow.

Globalny `~/.codex/AGENTS.md` służył do zapisania preferencji i sposobu pracy prowadzącego. Instrukcje projektowe dopasowywaliśmy do konkretnej aplikacji; w ćwiczeniu z jFTP wskazano pracę po angielsku.

Ważnym elementem rozpoznania repozytorium było korzystanie z istniejących map i grafów przed przeglądaniem plików jeden po drugim. Agent miał porównywać takie materiały z kodem, weryfikować rozbieżności i aktualizować mapy, gdy zmiany w repozytorium mogły je zdezaktualizować. Dla narzędzi CLI wskazano kolejność: najpierw wbudowana pomoc narzędzia, później Context7, a wyszukiwanie internetowe dopiero wtedy, gdy wcześniejsze źródła nie wystarczą.

Context7 przedstawiono jako narzędzie MCP i źródło dokumentacji bibliotek. Podczas sesji pokazano jego konfigurację dla Codexa i środowiska deweloperskiego, a następnie polecono używać go w pierwszej kolejności przy pracy z dokumentacją. Udostępniono [Context7](https://context7.com/) oraz przykład dokumentacji [Spring AI](https://context7.com/spring-projects/spring-ai?tab=chat&chat=d04dadd9-d72d-4481-9d5e-2e87faa959a2). Wspomniano również o Repomix, repo mapach i grafach kodu jako pomocach w rozumieniu większego repozytorium.

## Delegowanie zadań i dłuższa praca agentów

Ćwiczono delegowanie ograniczonych zadań do subagentów ad hoc, sprawdzanie ich statusu oraz śledzenie szczegółów pracy przez widok transkryptu w Codexie. Pokazano także uruchamianie polecenia `codex exec` z briefem zadania. Przy delegowaniu ważne było podanie celu, kontekstu i oczekiwanego rezultatu; wynik pracy agenta nadal wymaga weryfikacji.

Zlecono przygotowanie monitora wznawiającego pracę Codexa po odnowieniu limitu. Przy takiej automatyzacji trzeba sprawdzić czas wznowienia, składnię polecenia w używanej wersji CLI oraz test skryptu.

Omawiano też tryb headless, testy i TDD jako elementy pracy agentowej: przygotowanie ograniczonego zadania, sprawdzalnego wyniku oraz testów pozwalających kontrolować zmiany.

## jFTP: rozpoznanie, dokumentacja i planowanie zmian

Wspólnym przykładem pozostawał jFTP — desktopowa aplikacja Java analizowana jako istniejący projekt. Udostępniono repozytorium [jFTP po zmianach](https://github.com/LucasMatuszewski/JSystems-JFTP-2026-10-30). Zadaniem było opisywać najpierw stan aplikacji taki, jaki wynika z kodu, i samodzielnie wyszukiwać odpowiedzi w repozytorium. Przed większymi zmianami zlecono przygotowanie PRD z perspektywy użytkownika oraz ADR opisujących stronę techniczną, a także dokładniejszą analizę architektury z diagramami Mermaid. Wspomniano o testach charakteryzujących i regresyjnych jako elemencie poprzedzającym większą modernizację.

Kolejny etap dotyczył planowanego asystenta AI. Zakres początkowego proof of concept obejmował pytania o zawartość katalogów. Transfer plików pojawił się jako możliwy zakres przyszłego rozwoju, nie jako funkcja tej wersji. Rozważano wykorzystanie dostarczanego przez użytkownika klucza do zewnętrznego dostawcy, na przykład OpenRoutera, oraz sprawdzano przydatność API OpenAI dla Javy i protokołu AG-UI. Dobór bibliotek i architektury był częścią analizy wykonalności proponowanego POC.

Dla dalszego planowania podano szczegółowe wskazówki: plan ma wskazywać właściwe fragmenty PRD, ADR i dokumentacji zamiast kopiować je do jednego pliku; zadania powinny mieć sprawdzalne rezultaty, zależności, właściciela, zakres plików i sposób weryfikacji. Zalecono przygotować test zachowania przed implementacją, uwzględnić integrację, ręczne sprawdzenie działania aplikacji, niezależny przegląd i granice commitów. Brief dla subagenta ma zawierać kontekst potrzebny do konkretnego zadania. Po zaakceptowaniu planu i powiązanych dokumentów wydano polecenie realizacji. Plan należało uruchamiać w nowej, czystej sesji, przez `/goal`, z odwołaniem do pliku planu i zachowaniem zgodności z PRD, ADR i instrukcjami projektu.

W rozmowie wspomniano także o specyfikacji prowadzonej przez wymagania i o metodach upraszczania promptów. Udostępnione źródła obejmowały [Spec Kit](https://github.com/github/spec-kit), [specs.md](https://specs.md/), przykłady wyszukiwania skills dla [spec](https://www.skills.sh/?q=spec), [PRD](https://www.skills.sh/?q=prd), [ADR](https://www.skills.sh/?q=adr) i [planowania](https://www.skills.sh/?q=plan), a także [Ponytail](https://github.com/dietrichgebert/ponytail) i [Caveman](https://github.com/JuliusBrussee/caveman/tree/main). Wspomniano je jako materiały do sprawdzenia, nie jako obowiązujące wymagania projektu.

## Git, CI/CD i integracje z IDE

W końcowej części dnia zlecono dodanie prostego procesu CI/CD dla aplikacji desktopowej, uruchamiającego kontrole poprawności, takie jak lintowanie i testy jednostkowe. Omówiono przykłady integracji GitLab i GitHub oraz narzędzie PR Agent. Pokazano materiały referencyjne do konfiguracji PR Agent z Qodo i przykładowych pipeline’ów: [PR Agent](https://github.com/The-PR-Agent/pr-agent), [przykład PR-Agent-Qodo](https://github.com/LucasMatuszewski/jsystems-codex-java-2026-10/tree/main/course-materials/cicd-headless/PR-Agent-Qodo) i [przykłady CI/CD headless](https://github.com/LucasMatuszewski/jsystems-codex-java-2026-10/tree/main/course-materials/cicd-headless). Zlecono także przygotowanie konfiguracji GitLaba jako dodatkowego zdalnego repozytorium bez usuwania istniejącego GitHuba. Zakres ćwiczenia obejmował przygotowanie konfiguracji i wskazanie wymaganych ustawień oraz kluczy.

Udostępniono przykłady profili i aliasów Codexa, w tym użycia OpenRoutera: [profile Codexa](https://github.com/LucasMatuszewski/jsystems-codex-java-2026-10/tree/main/course-materials/agent-configs/codex) oraz [aliasy PowerShell](https://github.com/LucasMatuszewski/jsystems-codex-java-2026-10/blob/main/course-materials/agent-configs/codex-aliases.ps1). Pokazano również MCP JetBrains jako sposób zapewnienia agentom AI dostępu do IntelliJ: [dokumentacja serwera MCP w IntelliJ IDEA](https://www.jetbrains.com/help/idea/mcp-server.html).

## Materiały i zadania po szkoleniu

Materiały szkoleniowe są dostępne w [serwisie DevPowers](https://devpowers.com/szkolenia/jsystems/codex-java-2026-10/index.html). Checklistę po szkoleniu wskazano jako zadanie dla uczestników: [checklisty](https://devpowers.com/szkolenia/jsystems/codex-java-2026-10/checklisty.html#harness). Wśród dodatkowych źródeł z dnia znalazły się [OpenAI API dla Javy](https://developers.openai.com/api/reference/java), [OpenRouter Responses API](https://openrouter.ai/docs/api_reference/responses/overview), [wprowadzenie do AG-UI](https://docs.ag-ui.com/introduction) i [SDK AG-UI dla Javy](https://github.com/ag-ui-protocol/ag-ui/blob/main/docs/sdk/java/overview.mdx).
