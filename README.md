# OpenAI Codex w codziennej pracy programistycznej przy projektach Java (JSystems)

**Materiały szkoleniowe: [devpowers.com/szkolenia/jsystems/codex-java-2026-10](https://devpowers.com/szkolenia/jsystems/codex-java-2026-10/)**

- [Program i wszystkie materiały](https://devpowers.com/szkolenia/jsystems/codex-java-2026-10/agenda.html)
- [Slajdy](https://devpowers.com/szkolenia/jsystems/codex-java-2026-10/agenda.html#prezentacje)
- [Biblioteka promptów](https://devpowers.com/szkolenia/jsystems/codex-java-2026-10/prompty.html) · [Ćwiczenia](https://devpowers.com/szkolenia/jsystems/codex-java-2026-10/cwiczenia.html) · [Checklisty](https://devpowers.com/szkolenia/jsystems/codex-java-2026-10/checklisty.html) · [Słownik AI](https://devpowers.com/szkolenia/jsystems/codex-java-2026-10/slownik-ai.html)
- [Pytania i odpowiedzi](https://devpowers.com/szkolenia/jsystems/codex-java-2026-10/pytania.html)

Aktualny [program szkolenia](course-materials/course-agenda.md).

Repozytorium uczestnika szkolenia JSystems (28-30.10.2026, online, 09:00-16:00). W czasie szkolenia (3 dni) przechodzimy pełny cykl wytwarzania oprogramowania z agentami AI: od pomysłu i wymagań (PRD), przez decyzje architektoniczne (ADR), plan, implementację i testy, po code review, bezpieczeństwo i CI/CD.

Głównym narzędziem jest **OpenAI Codex**: CLI na przygotowanej VM z Windows 11, w PowerShell oraz porównanie pracy w aplikacji ChatGPT w trybie Codex, IntelliJ IDEA i VS Code. Java jest kontekstem ćwiczeń, a nie osobnym kursem frameworków. Na VM używamy natywnego sandboxu Windows; WSL nie jest wymagany. [Sprawdź dostęp i narzędzia](https://devpowers.com/szkolenia/jsystems/codex-java-2026-10/preflight.html). Trener zapewnia konto ChatGPT Business; firmowe Enterprise pozostaje do codziennej pracy. Własne projekty, zgłoszenia, merge requesty i CI/CD prowadzimy na GitLab szkoleniowym (`jsystems-gitlab.polandcentral.cloudapp.azure.com`, GitLab 19.5) przez `glab`; [konfiguracja w ćwiczeniu Cargo Tracker](course-materials/exercises/cargo-tracker.md).

## Trzy projekty, trzy dni

1. **28.10, jFTP:** [pełny prompt legacy](https://devpowers.com/szkolenia/jsystems/codex-java-2026-10/prompty.html#P18-jftp-legacy), inwentaryzacja, AGENTS.md, kontekst i skills A/B. Klon aplikacji trzymamy osobno od materiałów.
2. **29.10, Eclipse Cargo Tracker:** [analiza, status ładunku, PRD, ADR, TDD, UI i worktree](course-materials/exercises/cargo-tracker.md). Osobny klon aplikacji Jakarta EE, bez kopiowania jej kodu do tego repozytorium.
3. **30.10, jakość i duży projekt:** [zgłoszenia i merge requesty](course-materials/exercises/cargo-tracker-tickets.md), migracja javax na jakarta oraz [Apache Fineract: analiza wielu agentów](course-materials/exercises/fineract-multi-agent.md). Fineract analizujemy tylko do odczytu, bez uruchamiania usług finansowych.

[Otwórz dzień 1](https://devpowers.com/szkolenia/jsystems/codex-java-2026-10/dzien-1.html) · [dzień 2](https://devpowers.com/szkolenia/jsystems/codex-java-2026-10/dzien-2.html) · [dzień 3](https://devpowers.com/szkolenia/jsystems/codex-java-2026-10/dzien-3.html).

Nie budujemy chatbota ani nowej usługi Spring AI. Dokumenty funkcji powstają podczas ćwiczeń w klonie Cargo Tracker, po analizie jego rzeczywistego kodu. [Program z oferty i uzgodniona trasa](course-materials/course-agenda.md) pokazują tę zmianę.

## Biblioteka dodatkowa

`course-materials/` zawiera szeroką bibliotekę pełnych promptów, danych syntetycznych, checklist, przykładów konfiguracji i materiałów o innych agentach. To zasób do późniejszego czytania, nie lista narzędzi wymaganych na warsztacie. [Pełne prompty historyczne](course-materials/Prompt%20examples/) zachowano bez skracania; starsze twierdzenia o produktach, licencjach i komendach wymagają ponownego sprawdzenia. Podczas pracy z wybraną aplikacją agent nie powinien sam przeszukiwać `course-materials/`: zawarte tam PRD, ADR i instrukcje są przykładami, a nie wymaganiami tego projektu. Otwórz konkretny materiał dopiero wtedy, gdy go o to poprosisz.

W bibliotece znajdują się również **archiwalne materiały z wcześniejszego kursu o Claude Code**: [notatki](course-materials/Course%20INDEX%20-%20AI%20in%20Programming.md), [quiz](course-materials/quizzes/day-1-anonymous-ai-basics-quiz.md), [przykłady konfiguracji](course-materials/agent-configs/claude/) i [słownik PDF](course-materials/AI%20dla%20Programist%C3%B3w%20-%20S%C5%82ownik%20przed%20szkoleniem.pdf). Zachowano je jako źródła do ponownego wykorzystania, **nie jako aktualną konfigurację tego warsztatu**. Przykłady ustawień i skrypty należy dostosować i sprawdzić przed użyciem. `course-materials/exercise-data/hidden-patterns.md` jest archiwalnym kluczem trenerskim do danych syntetycznych.

Wybierz materiał do zadania:

- **Prompty i planowanie:** [PRD](course-materials/Prompt%20examples/PRD-electronics-returns-complains-app.md), [ADR](course-materials/Prompt%20examples/ADR-generation-typescript-vercel-ai-sdk.md), [plan implementacji](course-materials/Prompt%20examples/Plan-SubAgents-matrix-dependency-map.md), [propozycja skilla planowania](https://github.com/EdukeyTeam/agent-toolbox/pull/28) (otwarty PR).
- **Konfiguracje agentów:** [ustawienia, uprawnienia, profile i skróty Bash/PowerShell](course-materials/agent-configs/), [kurs na własnym laptopie: osobny profil Codex, VS Code i glab](course-materials/agent-configs/codex/laptop-kurs/README.md).
- **Hooki i zgody:** [ochrona plików i przykłady hooków](course-materials/hooks-example/), [Context7](course-materials/hooks-example/context7/), [permissions a hooki](course-materials/hooks-example/context7/permissions-vs-hooks.md).
- **CI/CD i code review:** [przegląd przykładów](course-materials/cicd-headless/), [agent review dla różnych CI](course-materials/cicd-headless/agent-review/), [PR-Agent i Qodo](course-materials/cicd-headless/PR-Agent-Qodo/), [Codex i Bitbucket](course-materials/cicd-headless/codex-bitbucket/).
- **Ćwiczenia i dalsza lektura:** [dane syntetyczne](course-materials/exercise-data/), [workflow agentów i oszczędzanie tokenów](course-materials/Research/agent-workflows-and-token-budget-2026-10-24.md), [COBOL i agenci AI: modele, praktyki, 10 zastosowań bez laboratorium](course-materials/Research/cobol-and-ai-agents-2026-10-28.md).

Przykłady są opcjonalne: skopiowanie repozytorium nie instaluje hooków ani profili. Przed uruchomieniem sprawdź instrukcję danego materiału, wersję narzędzia i politykę organizacji.

## Granice

Używaj wyłącznie danych syntetycznych. Przed przekazaniem kontekstu agentowi sprawdź politykę organizacji i zakres dostępu. Przejrzyj każdy diff, wynik testów i uprawnienia proponowanych narzędzi. Testów nie zmieniaj po to, by ukryć nieukończone zachowanie.

Możliwość użycia agenta chmurowego, MCP, CLI i pul AI Credits zależy od planu oraz ustawień organizacji. Agent w IDE i agent chmurowy to osobne środowiska. Funkcje edytora mogą się różnić od CLI i od innych IDE. [Stan narzędzi i źródła](docs/tool-facts.md) wymagają ponownego sprawdzenia przed zajęciami.

Trener: Łukasz Matuszewski · [LinkedIn](https://www.linkedin.com/in/lukaszmatuszewski/) · [X](https://x.com/mrLumatic)

Licencja: [MIT](LICENSE) © 2026 Łukasz Matuszewski.
