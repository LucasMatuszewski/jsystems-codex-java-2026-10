# Konta, profile i wykonawcy Codex

Stan: Codex CLI 0.164.0, 28.10.2026. [Konfiguracja](https://developers.openai.com/codex/config-reference/) · [Subagenci](https://developers.openai.com/codex/multi-agent/) · [Logowanie](https://developers.openai.com/codex/auth/).

Katalog `CODEX_HOME` rozdziela konfigurację, historię i lokalne dane autoryzacji. Profil wybiera ustawienia; sam nie przełącza konta. Na VM z Windows 11 używamy PowerShell. Utwórz katalogi i funkcje dla kont; każda funkcja przywraca poprzednie CODEX_HOME po zakończeniu polecenia:

```powershell
New-Item -ItemType Directory -Force -Path "$HOME\.codex-business", "$HOME\.codex-enterprise" | Out-Null
```

```powershell
function codex-business { $previousCodexHome = $env:CODEX_HOME; try { $env:CODEX_HOME = "$HOME\.codex-business"; codex @args } finally { $env:CODEX_HOME = $previousCodexHome } }
```

```powershell
function codex-enterprise { $previousCodexHome = $env:CODEX_HOME; try { $env:CODEX_HOME = "$HOME\.codex-enterprise"; codex @args } finally { $env:CODEX_HOME = $previousCodexHome } }
```

Na kursie logujesz tylko Business: `codex-business login`, potem `codex-business login status`. Przeglądarka musi wskazywać konto szkoleniowe. Nie kopiuj `auth.json` i nie wyświetlaj jego zawartości. Enterprise konfigurujesz później zgodnie z polityką firmy. Funkcje działają w bieżącym terminalu; zdefiniuj je ponownie w nowym. Korzystamy z natywnego sandboxu Windows, bez wymagania WSL. [Instrukcja Windows, 28.10.2026](https://developers.openai.com/codex/windows).

Pliki `course-analysis.config.toml` i `course-implementation.config.toml` skopiuj do `$HOME\.codex-business\`. Uruchom `codex-business --profile course-analysis` albo `codex-business --profile course-implementation`. Profil z `sandbox_mode` jest przykładem konfiguracji klasycznej. Aktywny projekt może wybierać nazwany profil uprawnień o wyższym priorytecie. W takim projekcie użyj `codex-business -c 'default_permissions="course-review"'` do analizy, a `course-workspace` do implementacji; nie mieszaj obu mechanizmów bez sprawdzenia wyniku. Sprawdź `/permissions`, `/status` i `codex doctor --all`.

Nie dodawaj `[profiles.nazwa]`: aktualne profile są osobnymi plikami `$env:CODEX_HOME\nazwa.config.toml`. Nie ustawiaj modelu w projekcie, jeżeli ma go wybierać profil użytkownika. Proxy sieciowe włączaj na poziomie użytkownika; reguły domen bez działającego proxy nie ograniczają ruchu poleceń.

Przykład `luna-reader.toml` jest nieaktywny. Do celowego użycia skopiuj go do `.codex/agents/luna-reader.toml` w analizowanym projekcie, ustaw `[agents] max_concurrent_threads_per_session = 4` w jego konfiguracji i jawnie poproś o delegację. Kontrola tylko do odczytu wymaga sandboxu rodzica: instrukcja w pliku roli sama go nie wymusza. Model i effort roli są niezależnymi wyborami; dostępność sprawdź przez `/model`.

Sol koordynuje i weryfikuje; Luna zbiera ograniczone dowody, Astra pomaga przy najtrudniejszych niejasnościach. Porównuj łączne tokeny wszystkich wykonawców, czas i jakość. Więcej agentów nie gwarantuje oszczędności.
