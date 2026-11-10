#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
course_home="${XDG_DATA_HOME:-$HOME/.local/share}/JSystems/Codex-Java-2026-10"
umask 077
mkdir -p -- "$course_home"

exec env -u CODEX_ACCESS_TOKEN -u CODEX_API_KEY -u OPENAI_API_KEY -u OPENAI_FEDERATION_RULE_ID \
    CODEX_HOME="$course_home" CODEX_SQLITE_HOME="$course_home" \
    codex --no-daemon --cd "$repo_dir" "$@"
