# Podsumowanie - dzień 2, 29 października 2026

Drugiego dnia szkolenia pracowaliśmy nad konfiguracją Codex, kontrolowaniem działań agentów i analizą nieznanego projektu Java. Głównym przykładem był [jFTP](https://github.com/sai-pullabhotla/jftp), desktopowy klient FTP wykorzystany do ćwiczenia analizy legacy code i przygotowania modernizacji.

## Środowisko, sandbox i uprawnienia

Wracaliśmy do problemów z działaniem agentów na maszynach Windows: dostępu do plików, autoryzacji narzędzi i ograniczeń sieciowych. Przy diagnozie trzeba rozdzielić trzy rzeczy: ograniczenia sandboxa, zasady zatwierdzania poleceń oraz uprawnienia konta lub tokenu, z którego korzysta narzędzie.

W Codex na Windows starszy sandbox `elevated` korzysta z dodatkowych kont i wymaga konfiguracji zatwierdzonej przez administratora. Nowszy MXC wykorzystuje izolację procesów na obsługiwanych wersjach Windows 11, bez tworzenia dodatkowych kont i bez takiej konfiguracji administracyjnej. Dostępność zależy od systemu i polityki organizacji. [Dokumentacja sandboxa Windows](https://learn.chatgpt.com/docs/windows/windows-sandbox).

Omawialiśmy też tokeny GitHub Fine-grained: wybór repozytoriów, potrzebnych operacji i oddzielenie dostępu agenta od szerszych uprawnień użytkownika. Ograniczony token kontroluje dostęp do GitHuba; dostęp procesu do lokalnych plików i narzędzi wynika z konfiguracji środowiska. Dlatego przy problemie z `gh` należy ustalić, czy blokowana jest sieć, odczyt danych uwierzytelniających czy sama operacja w repozytorium.

Wszyscy korzystali ze wspólnego publicznego adresu IP, co mogło być jedną z przyczyn ograniczeń dostępu do modeli Codex.

Dobór uprawnień i sposobu pracy musi być zgodny z polityką organizacji.

## Hooki: reguły wykonywane przy zdarzeniach

Hooki pozwalają uruchamiać kontrolę lub skrypt w określonym momencie pracy agenta. Omawialiśmy m.in. `PreToolUse`, `PostToolUse`, `SessionStart` i `Stop`: przed użyciem narzędzia, po jego wykonaniu, przy rozpoczęciu sesji i przy kończeniu odpowiedzi.

Przykłady zastosowań obejmowały ochronę plików z sekretami, kontrolowanie operacji na konfiguracji, przekazywanie potrzebnego kontekstu i reagowanie na problemy z uprawnieniami. Reguła zapisana w prompcie wymaga zastosowania jej przez model; hook uruchamia skonfigurowany mechanizm przy danym zdarzeniu. Zakres działania i rezultat trzeba sprawdzić w używanym narzędziu.

Hook wywoływany przed każdym użyciem narzędzia powinien być krótki i szybki. Dodatkowe procesy i wywołania modeli w takim miejscu mogą spowalniać całą sesję. [Przykłady hooków z kursu](https://github.com/LucasMatuszewski/jsystems-codex-java-2026-10/tree/main/course-materials/hooks-example).

## Skills i instrukcje projektu

Skill porządkuje powtarzalny sposób pracy. Jego punktem wejścia jest `SKILL.md`; obok mogą znajdować się skrypty, szablony i materiały pomocnicze. Opis skilla powinien jasno wskazywać sytuację, w której agent ma go użyć. Wybór automatyczny warto sprawdzać na konkretnym zadaniu, a potrzebny skill można też wskazać wprost.

Rozróżnialiśmy instalację w projekcie i instalację globalną. Do wyszukiwania, instalowania i aktualizacji służy CLI `skills` powiązane z [skills.sh](https://www.skills.sh/). Przykładowe workflowy udostępnia [EdukeyTeam Agent Toolbox](https://github.com/EdukeyTeam/agent-toolbox/tree/main). Katalog pokazuje także wyniki audytów bezpieczeństwa; przy wyborze zewnętrznego skilla trzeba przeczytać jego instrukcje i sprawdzić dołączone skrypty.

Praktyczna metoda tworzenia własnego skilla: najpierw przejść workflow na rzeczywistym zadaniu, dopracować kroki i oczekiwany rezultat, a potem zapisać sprawdzony sposób pracy. Na kursie przykładami były analiza legacy code, tworzenie design systemu oraz analiza sesji i zużycia tokenów.

`AGENTS.md` opisuje natomiast konkretny projekt i zasady pracy w nim. W ćwiczeniu z jFTP należało dopasować początek pliku do tej aplikacji, zachować uzgodniony workflow oraz usunąć odwołania do nieistniejących folderów i innych projektów.

## Rozpoznawanie repozytorium: kod, mapy i grafy

Pracę nad nieznanym projektem zaczynaliśmy od rozpoznania jego struktury i dostępnych narzędzi, korzystając z workflowu `legacy-codebase-workflows`. Przed większą modernizacją agent powinien ustalić, jak aplikacja jest zbudowana, jak ją uruchomić i co wymaga dalszego sprawdzenia.

Porównywaliśmy różne sposoby przygotowania kontekstu:

- [Repomix](https://github.com/yamadashy/repomix) pakuje zawartość repozytorium lub wybranych plików do jednego materiału dla modelu; kompresja może zachować strukturę i sygnatury kosztem szczegółów implementacji.
- [Repo Map Aidera](https://aider.chat/docs/repomap.html) przedstawia zwięzłą mapę istotnych klas, funkcji i ich sygnatur.
- [Graphify](https://github.com/Graphify-Labs/graphify) oraz [codebase-memory-mcp](https://github.com/DeusData/codebase-memory-mcp) pojawiły się przy analizie powiązań w kodzie i tworzeniu grafu projektu.

Do oglądania zmian Git omawialiśmy [Delta](https://github.com/dandavison/delta) i [lazygit](https://github.com/jesseduffield/lazygit). Mapa repozytorium pomaga wybrać, co przeczytać; istotne wnioski i zmiany nadal wymagają sprawdzenia w kodzie i diffie.

## Kontekst, sesje i tokeny

W dłuższej sesji trzeba pilnować, jakie informacje model ma w kontekście. Omawialiśmy kompakcję historii przez `/compact` oraz przekazanie najważniejszych ustaleń do nowej sesji. W takim przekazaniu przydają się cel, podjęte decyzje, stan pracy, wyniki sprawdzeń i pliki potrzebne do kontynuacji. Pojawiły się też `/btw` do pobocznego pytania i `/fork` do utworzenia odgałęzienia rozmowy.

Korzystaliśmy z [tokenizera OpenAI](https://platform.openai.com/tokenizer) i omawialiśmy analizę sesji przez `agent-usage-analytics`. Liczbę tokenów należy mierzyć dla konkretnego tekstu i modelu; język i sposób zapisu wpływają na wynik. W statystykach warto rozróżniać tokeny wejściowe, wyjściowe i odczytane z cache.

Porównywaliśmy również zwykłą rozmowę z pracą agentową: ocena zużycia powinna obejmować całą sesję, z wywołaniami narzędzi i delegowaniem, a nie tylko długość końcowej odpowiedzi.

Cache umożliwia ponowne wykorzystanie przetworzonego fragmentu wejścia i wpływa na koszt przetwarzania. Kompakcja skraca kontekst przekazywany modelowi. To różne mechanizmy, dlatego samo wysokie wykorzystanie cache nie mówi, ile miejsca pozostało w oknie kontekstowym. [Dokumentacja prompt caching](https://developers.openai.com/api/docs/guides/prompt-caching).

## Delegowanie i modernizacja jFTP

Omawialiśmy pracę z wieloma agentami oraz narzędzia do zarządzania sesjami, m.in. `tmux` i `herdr`. Przy delegowaniu trzeba przekazać wykonawcy cel, kontekst, ograniczenia i oczekiwany rezultat. W przykładzie prostsze zadania przewidziano dla modelu Luna, z dokładnymi instrukcjami i kontrolą wyników. Sol 6.1 został wskazany przez prowadzącego jako model przydatny do code review.

Zakres zadania modernizacji jFTP obejmował:

- rozpoznanie aplikacji i opis jej aktualnego działania;
- przygotowanie PRD z perspektywy użytkownika oraz ADR dotyczących strony technicznej;
- dokumentację UML w Mermaid;
- przygotowanie testów charakteryzujących i regresyjnych przed większymi zmianami;
- uruchomienie aplikacji, dokumentowanie pracy zrzutami ekranu i porównywanie wyglądu z materiałami w `assets`;
- dopasowanie instrukcji agenta do projektu i prowadzenie dokumentacji aplikacji po angielsku.

Pracę zorganizowano także jako cel w `/goal`. Modernizację, testy i dokumentację pozostawiono do kontynuacji przez agentów w nocy.

## Narzędzia pomocnicze i bezpieczeństwo

Wśród narzędzi pomocniczych pojawiły się Micro jako edytor terminalowy, zmienna `EDITOR`, Nerd Fonts oraz Better TOML do pracy z konfiguracją TOML w VS Code. Przy automatyzacji przeglądarki omawialiśmy Playwright; w materiałach jest także [rozszerzenie Playwright do Chrome](https://chromewebstore.google.com/detail/playwright-extension/mmlmfjhmonkocbjadbfplnigmagldckm). Do diagnostyki instalacji i konfiguracji Codex służy [`codex doctor`](https://learn.chatgpt.com/docs/cli/reference).

Przykłady zagrożeń dotyczyły dostępu do sekretów, zbyt szerokich uprawnień oraz działań wykonywanych przez agenta w przeglądarce. Odwołaliśmy się również do [incydentu w Hugging Face](https://openai.com/pl-PL/index/hugging-face-incident-and-the-road-ahead/) i materiału [Instadocs: AI Gone Wild](https://www.netflix.com/tudum/articles/instadocs-ai-gone-wild-release-date-news). Praktyczne zasady pracy obejmowały ograniczanie dostępu, przegląd zewnętrznych skills, kopie zapasowe i sprawdzanie wyników automatyzacji.
