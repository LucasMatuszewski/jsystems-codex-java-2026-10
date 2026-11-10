# PR-Agent i Codex CLI na własnym GitLabie

Uruchomisz dwa joby review dla tego samego merge requesta. Oba korzystają z OpenRoutera i publikują wynik w dyskusji MR. [Wspólny plik YAML z oboma jobami](gitlab-review-jobs.yml) pochodzi z konfiguracji użytej na dogrywce. Wzór zaczyna od ręcznego uruchamiania jobów w prywatnym projekcie testowym.

## 1. Dodaj pliki do projektu

- Skopiuj [gitlab-review-jobs.yml](gitlab-review-jobs.yml) jako `ci/gitlab-review-jobs.yml`.
- Skopiuj katalog [agent-review](agent-review/) jako `ci/agent-review/`. Zawiera Dockerfile, prompt do review oraz skrypty do uruchamiania Codexa i publikacji komentarza.
- W głównym `.gitlab-ci.yml` dopisz poniższy wpis do listy `include` oraz dodaj etap `review` do istniejącej listy `stages`. Jeśli korzystasz z domyślnej listy etapów, wpisz `stages: [build, test, deploy, review]`. Jeśli masz już joby o tych samych nazwach, zastąp je albo zmień nazwy w kopii szablonu.

```yaml
include:
  - local: /ci/gitlab-review-jobs.yml
```

W głównym pliku upewnij się, że `workflow: rules` dopuszcza pipeline typu merge request. Jeśli masz już własne reguły, zachowaj je i dodaj regułę MR przed regułą, która by go odrzuciła. Poniższy wariant możesz wykorzystać w projekcie testowym, który nie ma jeszcze `workflow`.

```yaml
workflow:
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
    - if: '$CI_COMMIT_BRANCH && $CI_OPEN_MERGE_REQUESTS && $CI_PIPELINE_SOURCE == "push"'
      when: never
    - if: '$CI_COMMIT_BRANCH || $CI_COMMIT_TAG'
```

[Pipelines dla merge requestów w GitLabie](https://docs.gitlab.com/ci/pipelines/merge_request_pipelines/)

## 2. Zbuduj obraz Codex CLI

Z katalogu głównego projektu uruchom poniższe polecenia po zalogowaniu się do swojego rejestru. Podmień przykładowy adres obrazu.

```bash
docker build -t registry.example.com/team/project/agent-ci:1 ci/agent-review
docker push registry.example.com/team/project/agent-ci:1
```

Runner Docker musi móc pobrać ten obraz i obraz PR-Agent wskazany w YAML. Joby potrzebują też dostępu HTTPS do GitLaba i OpenRoutera. Jeżeli Twój runner używa tagów, dodaj odpowiednie `tags` do obu jobów.

## 3. Ustaw zmienne projektu

W **Settings → CI/CD → Variables** dodaj poniższe wpisy. Dla czterech poświadczeń wybierz `Masked and hidden` i wyłącz rozwijanie wartości. Upewnij się, że zmienne są dostępne w pipeline MR, na którym robisz pilotaż.

| Nazwa | Wartość w pokazanym wariancie |
|---|---|
| `REVIEW_API_KEY` | Klucz API OpenRouter używany przez PR-Agent |
| `OPENROUTER_API_KEY` | Klucz API OpenRouter używany przez Codex CLI |
| `GITLAB__PERSONAL_ACCESS_TOKEN` | Token bota GitLab do odczytu MR i publikacji komentarza przez PR-Agent |
| `GITLAB_TOKEN` | Token bota GitLab do publikacji komentarza Codex CLI |
| `CODEX_REVIEW_IMAGE` | Pełny adres obrazu z poprzedniego kroku, np. `registry.example.com/team/project/agent-ci:1`. To zwykła zmienna CI. |

Jeśli oba joby mają korzystać z tego samego klucza OpenRouter, wpisz go pod obiema nazwami. Token bota utwórz w **Settings → Access tokens** jako token dostępu projektu z zakresem `api`, rolą Developer i datą ważności. W projekcie testowym możesz użyć tego samego tokenu projektu dla obu jobów. Jeżeli Wasza instancja wymaga konta serwisowego, użyj jego tokenu z odpowiednimi uprawnieniami w projekcie. [Zmienne CI/CD](https://docs.gitlab.com/ci/variables/) · [Tokeny dostępu projektu](https://docs.gitlab.com/user/project/settings/project_access_tokens/)

Szablon zawiera ustawienie `CODEX_SANDBOX: danger-full-access` z runnera szkoleniowego. Użyj go wyłącznie w odizolowanym pilotażu na zaufanym kodzie. Na runnerze, który obsługuje sandbox Codexa, ustaw `read-only`. Przed wdrożeniem w projekcie firmowym wydziel publikację komentarza do osobnego joba, który odbiera raport jako artefakt i jako jedyny dostaje `GITLAB_TOKEN`.

## 4. Uruchom oba review

1. Zapisz konfigurację na gałęzi docelowej projektu. Otwórz mały MR z drugiej gałęzi w tym samym projekcie.
2. W pipeline typu merge request uruchom ręcznie `pr-agent-review` i `codex-review` dla tego samego commita.
3. Sprawdź log każdego joba i jego komentarz w dyskusji MR. Wzór nie blokuje pipeline’u, więc sam zielony status pipeline’u nie potwierdza publikacji.

Do pilotażu możesz użyć [publicznego jFTP](https://github.com/LucasMatuszewski/JSystems-JFTP-2026-10-30). W testowym MR ustaw kontrakt portu FTP na domknięty zakres 1–65535, a w `RemoteHost.setPort` celowo odrzuć port 1.

```java
this.port = port <= 1 || port > 65535 ? FTPConstants.DEFAULT_PORT : port;
```

Po pierwszym review dopisz test portu 1 i zmień `port <= 1` na `port <= 0`. Powtórz oba review na nowym commicie i sprawdź, czy komentarze odzwierciedlają poprawkę.
