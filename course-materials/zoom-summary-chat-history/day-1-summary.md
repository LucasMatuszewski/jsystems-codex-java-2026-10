# Podsumowanie - dzień 1, 28 października 2026

Źródła: automatyczne podsumowanie spotkania Zoom (AI Companion, szablon wykładowy), zanonimizowane, notatki trenera oraz [historia czatu](day-1-chat-history.md). Uczestników oznaczono inicjałami, trener zachowuje publiczne przypisanie: Łukasz Matuszewski. Godziny w czasie polskim.

## Przegląd

Pierwszy dzień trzydniowego szkolenia o pracy z agentami AI przy projektach Java, z OpenAI Codex jako głównym narzędziem. Łukasz Matuszewski przedstawił ewolucję narzędzi AI dla programistów, porównywanie modeli, bezpieczeństwo pracy z agentami i trendy w branży. Druga część dnia to konfiguracja środowiska: logowanie na maszyny wirtualne z Windows 11 przez RDP, instalacja i logowanie Codex CLI, konto GitHub z tokenem o ograniczonych uprawnieniach oraz klonowanie repozytorium szkoleniowego.

Kluczowe pojęcia:

- **Agenci AI w programowaniu** - systemy, które samodzielnie wykonują zadania programistyczne przez dłuższy czas.
- **Vibe Coding** - programista opisuje intencję, agent generuje kod ([oryginalny post Andreja Karpathy'ego](https://x.com/karpathy/status/1886192184808149383?lang=en)).
- **Skills** - pakiety instrukcji i narzędzi definiujące, jak agent pracuje w projekcie lub organizacji.
- **Okno kontekstu i optymalizacja tokenów** - ile model widzi naraz i ile kosztuje praca agenta.
- **Prompt injection i jailbreaking** - manipulowanie agentem przez złośliwe instrukcje w danych wejściowych.
- **Sandbox** - izolowane środowisko, które ogranicza dostęp agenta do systemu.
- **Code Mode / codemod** - agent pisze program, który przekształca kod lub dokumenty, zamiast edytować każdy plik osobno.
- **Dark factory** - wizja w pełni zautomatyzowanego wytwarzania oprogramowania, w którym agenci piszą, testują i wdrażają kod.

## Organizacja

- Przerwy trwały do 11:15 i do 13:35.
- Materiały dnia: [strona szkolenia](https://devpowers.com/szkolenia/jsystems/codex-java-2026-10/), [słownik AI](https://devpowers.com/szkolenia/jsystems/codex-java-2026-10/slownik-ai.html), [Prezentacja 1: Start kursu](https://devpowers.com/szkolenia/jsystems/codex-java-2026-10/Prezentacja_01_Start_kursu.html#1), [Prezentacja 2: Podstawy AI](https://devpowers.com/szkolenia/jsystems/codex-java-2026-10/Prezentacja_02_Podstawy_AI.html#1).
- [Repozytorium szkoleniowe](https://github.com/LucasMatuszewski/jsystems-codex-java-2026-10) z [materiałami kursowymi](https://github.com/LucasMatuszewski/jsystems-codex-java-2026-10/tree/main/course-materials) pozostaje dostępne po szkoleniu.

## Temat 1: Ewolucja narzędzi AI dla programistów

Łukasz Matuszewski pokazał drogę od pierwszych narzędzi do autouzupełniania ([Tabnine](https://docs.tabnine.com/main)), przez pierwsze zespoły agentów ([CrewAI](https://crewai.com/)) i RAG ([LangChain](https://www.langchain.com/)), po [Cursor](https://cursor.com/), pierwsze naprawdę działające narzędzie AI do programowania. Przez lata narzędzia AI bardziej przeszkadzały, niż pomagały; przełom nastąpił w ciągu ostatnich dwóch lat wraz z modelami wyraźnie wyższej jakości.

Jako przykład skali pracy z agentami pokazał projekt, w którym twórca OpenClaw w rekordowym dniu zrobił około 6700 commitów, oraz [wpis o przepisywaniu miliona linii kodu w Microsoft przez jednego inżyniera w miesiąc](https://www.linkedin.com/posts/galenh_principal-software-engineer-coreai-microsoft-activity-7407863239289729024-WTzf). Omówił też agentów działających stale na serwerze: [OpenClaw](https://openclaw.ai/) ([repozytorium](https://github.com/openclaw/openclaw), autor [Peter Steinberger](https://github.com/steipete)) i [Hermes Agent](https://hermes-agent.nousresearch.com/), oraz narzędzia typu [v0](https://v0.app/) (działa z subskrypcją OpenAI) i [Lovable](https://lovable.dev/dashboard).

W ankiecie na czacie najwięcej uczestników wskazało wtyczkę Codex w VS Code (5 reakcji); CLI, ChatGPT Desktop i wtyczka IntelliJ dostały po 3.

### Q&A

- **Czy generowanie kodu może dojść do 100%, nawet w systemach o wysokich wymaganiach, np. bankowych?** Zdaniem Łukasza tak, pod warunkiem dopracowanego procesu i przewidywalnych wyników. Nawet bardzo doświadczeni programiści coraz częściej rezygnują z ręcznego pisania kodu.
- **P.K.: Czy to nie jest niebezpieczne, że coraz mniej osób czyta i rozumie kod?** To jedno z największych ryzyk. Łukasz porównał to do asemblera: kiedyś przestaliśmy rozumieć ten poziom, teraz możemy przestać rozumieć kod źródłowy. Eksperci, zwłaszcza od bezpieczeństwa, nadal będą potrzebni, a rośnie rola technicznych orkiestratorów agentów.

## Temat 2: Porównanie modeli AI i rankingi

- **Rankingi:** [Arena](https://arena.ai/) (pojedynki modeli i ranking ELO, w tym [ranking agentowy](https://arena.ai/leaderboard/agent) i [filtr open source](https://arena.ai/leaderboard/agent?license=open-source)) oraz [Artificial Analysis](https://artificialanalysis.ai/), agregator benchmarków z ceną za zadanie.
- **Ćwiczenie:** ten sam prompt strony "Steve's PC Repair" (w historii czatu, 11:17) w kilku modelach, np. [Muse Spark 1.3 xhigh](https://01a181fb-8f09-7744-8363-bd09513e6899.arena.site/) i [DeepSeek v4.1 flash high](https://01a181fb-8f09-7bfe-8723-682cf99402c2.arena.site/). Uczestnicy udostępnili własne wyniki, m.in. z GLM-5.2 i Gemini-4-argon. Grupa oceniała m.in. responsywność na telefonie i kreatywność tekstu.
- **Opus 5.5** (Anthropic) to obecnie najlepszy orkiestrator agentów, a **GPT-6.1 Sol** (OpenAI) najlepszy model wykonawczy.
- **Haiku 5.5 i GPT-6 Luna** to dobre tanie modele wykonawcze do większości prostszych zadań: zbierania informacji, analizy kodu i generowania testów.
- **Sonnet** jest tylko trochę tańszy od Opusa, bo generuje dużo więcej tokenów, więc Łukasz obecnie go nie używa. **GPT-6 Astra** jest bardzo drogi, prawie jak Fable.
- **Modele open source**, np. Qwen3.8-27B, dają zaskakująco dobre wyniki i można je uruchomić lokalnie.
- Najdroższa w pracy agentów nie jest sama generacja kodu, lecz orkiestracja: zbieranie informacji, analiza repozytorium i kontrola jakości.

### Q&A

- **P.K.: Czy zamiast bezpośrednich kredytów API rozważyć subskrypcje typu Copilot lub Cursor?** Warto: subskrypcja daje około 10-15 razy więcej użycia, niż kosztowałoby to samo w cenach API ([analiza subskrypcji ChatGPT i kredytów Enterprise](https://github.com/LucasMatuszewski/jsystems-codex-java-2026-10/blob/main/course-materials/Research/chatgpt-subscription-vs-enterprise-credits-2026-10-12.md)). Przy wyborze warto uwzględnić limity kredytów. Copilot wyraźnie się poprawił i pozwala podłączyć własne modele przez własny endpoint.
- **P.K.: Jak w praktyce różnią się OpenAI i Anthropic?** Do części zadań, zwłaszcza w trybie agentowym, Łukasz woli Claude. Rankingi pokazują, że różnice zależą od zastosowania i nie zawsze są duże.

## Temat 3: Bezpieczeństwo pracy z agentami

Agent z pełnym dostępem do systemu użytkownika może odczytać tokeny, pliki konfiguracyjne i dane wrażliwe. Zalecane praktyki:

- izolowane środowiska (maszyna wirtualna, sandbox), osobne sieci dla wrażliwych projektów. Sandbox na Linuksie (np. Bubblewrap) jest prostszy i działa lepiej, a na Windows sprawia więcej kłopotów, także w Codex ([diagnostyka sandboxu Windows](https://github.com/LucasMatuszewski/jsystems-codex-java-2026-10/blob/main/course-materials/Research/codex-windows-sandbox-troubleshooting-2026-10-15.md));
- dedykowane tokeny z ograniczonymi uprawnieniami zamiast pełnego dostępu użytkownika;
- świadomość prompt injection i jailbreakingu ([Pliny](https://x.com/elder_plinius));
- ostrożność przy automatycznym zatwierdzaniu poleceń.

W Codex `/permissions` z opcją "Approve for me" kieruje polecenia do oceny bezpieczeństwa: ryzykowne akcje są eskalowane do użytkownika albo agent dostaje sugestię bezpieczniejszego podejścia. Codex lepiej niż Claude radzi sobie z obsługą komputera (computer use), co może się przydać np. do automatyzacji aplikacji desktopowych w stylu RPA (UiPath); nie jest to jednak temat tego szkolenia. Narzędzia z [listy "nie instalować"](https://getartcraft.com/apps) zostały pokazane tylko jako przykład.

### Q&A

- **K.B.: Jak zarządzać wieloma agentami działającymi równolegle?** Jeden agent orkiestrujący (najlepiej Opus) deleguje zadania do tańszych modeli wykonawczych. Łukasz pokazał narzędzia do zarządzania flotą agentów na kilku urządzeniach z jednego miejsca.
- **P.K.: Agent zmienił formatowanie całego dokumentu Word przy dodawaniu jednego akapitu - jak temu zapobiec?** To znany problem: agenci przepisują cały plik zamiast edytować fragment. Rozwiązaniem są skrypty generujące dokumenty z szablonów (Code Mode) i edycja przez diff zamiast pełnego przepisywania.
- **K.P.: Czy HTML zamiast Markdown daje agentowi lepszy kontekst, np. dla tabel i wykresów?** Zrzuty ekranu niosą więcej informacji wizualnej, ale HTML jest dużo większy. Łukasz zalecił Markdown z rozszerzeniami takimi jak diagramy Mermaid, które modele dobrze rozumieją. Temat wróci w kolejnych dniach.

## Temat 4: Konfiguracja środowiska

- **VM:** Windows 11 przez RDP; na Linuksie np. [Remmina](https://remmina.org/) lub [FreeRDP](https://www.freerdp.com/).
- **Codex CLI:** instalacja w PowerShell: `powershell -ExecutionPolicy ByPass -c "irm https://chatgpt.com/codex/install.ps1 | iex"`, logowanie kontem szkoleniowym ChatGPT Business i sprawdzenie `codex login status` (oczekiwany wynik: `Logged in using ChatGPT`). Logowanie na konta szkoleniowe wymaga teraz dodatkowego kodu weryfikacyjnego.
- **Status usług:** [OpenAI](https://status.openai.com/) i [Claude](https://status.claude.com/).
- **Linia statusu Codex:** wybór elementów, np. katalog, gałąź Git, tryb zatwierdzania i pozostały kontekst.

  ![Ustawienia elementów wyświetlanych na linii statusu Codex w terminalu](https://github.com/LucasMatuszewski/jsystems-codex-java-2026-10/raw/main/course-materials/zoom-summary-chat-history/day-1-01.png)

- **Pierwsze zadanie dla agenta:** prompt sprawdzający dysk, procesor, RAM i wydajność VM (w historii czatu, 14:32). Przy pracy z kontami szkoleniowymi warto pilnować zużycia kredytów w wątkach.
- **GitHub:** prywatne konto, `gh auth login`, a potem `gh auth status`. [Fine-grained token](https://github.com/settings/personal-access-tokens/new) z uprawnieniami: Actions read-only, Contents read and write, Metadata read-only, Pull requests read and write. Repozytorium klonujemy przez `git clone https://github.com/<USER>/jsystems-codex-java-2026-10.git`.
- **Skills:** `npx --yes skills@latest add EdukeyTeam/agent-toolbox --skill '*'` ([agent-toolbox](https://github.com/EdukeyTeam/agent-toolbox)).
- **Terminal i dyktowanie:** [WezTerm](https://github.com/LucasMatuszewski/jsystems-codex-java-2026-10/tree/main/course-materials/WezTerm) (na Windows [wersja nightly](https://wezterm.org/install/windows.html#installing-on-windows)), `/voice` w Codex (przytrzymanie spacji) oraz [Handy](https://handy.computer/), darmowe lokalne dyktowanie z [promptami do poprawiania transkrypcji](https://github.com/LucasMatuszewski/jsystems-codex-java-2026-10/blob/main/course-materials/Prompt%20examples/Handy.computer%20-%20transcription%20prompts.md).

### Problemy i Q&A

- Wystąpiły problemy z maszynami wirtualnymi: dwa rozłączenia wymagające pomocy administratora, bardzo wolne działanie, czarny ekran RDP, dłuższa konfiguracja kont i błąd "State mismatch" przy logowaniu. Dlatego pierwszy dzień objął więcej teorii, a ćwiczenie jFTP przechodzi na drugi dzień.
- Sandbox na VM blokował dostęp GitHub CLI do sieci. Łukasz sprawdzi konfigurację przed drugim dniem.
- **K.K.: `codex login status` nie działa na VM.** Aktualizacja przed szkoleniem prawdopodobnie zapisała plik binarny w innym miejscu. Pomaga ponowna instalacja poleceniem powyżej.

## Kogo śledzić

[Pełna lista w materiałach](https://github.com/LucasMatuszewski/jsystems-codex-java-2026-10/blob/main/course-materials/Course%20INDEX%20-%20AI%20in%20Programming.md#people-and-accounts-to-follow-in-ai). Na czacie: [Andrej Karpathy](https://x.com/karpathy), [Tibo z zespołu Codex](https://x.com/thsottiaux) (zapowiada resety limitów), [Theo](https://www.youtube.com/@t3dotgg), [Pliny](https://x.com/elder_plinius), [Mateusz Chrobok](https://www.youtube.com/@MateuszChrobok) oraz [wywiad o Polakach w OpenAI](https://www.youtube.com/watch?v=w20lk3OyLMI&t=2s).

## Plan na kolejne dni

Drugi dzień zaczynamy od ćwiczenia na aplikacji jFTP: AGENTS.md, skills, CLI i MCP pokazane na rzeczywistym kodzie. Jeśli czas pozwoli, ten sam przepływ pracy przećwiczymy na kolejnych aplikacjach (Eclipse Cargo Tracker, Apache Fineract). Aplikacje są tylko przykładowym kodem: celem jest opanowanie narzędzi, harnessu i przepływu pracy z agentem.

## Kolejne kroki

**Trener:**

- Rozwiązać problemy z sandboxem i dostępem GitHub CLI na VM oraz z połączeniami RDP przed drugim dniem.

**Uczestnicy:**

- Mieć zalogowany Codex (`codex login status`) i GitHub (`gh auth status`) na VM oraz sklonowane repozytorium szkoleniowe.
- Opcjonalnie: zainstalować skills z agent-toolbox, wypróbować Handy lub `/voice` i porównać modele na Arenie.
