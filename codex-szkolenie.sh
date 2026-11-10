#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${CODEX_ACCESS_TOKEN:-}" || -n "${CODEX_API_KEY:-}" || -n "${OPENAI_API_KEY:-}" || -n "${OPENAI_FEDERATION_RULE_ID:-}" ]]; then
    printf '%s\n' 'Użyj terminala bez CODEX_ACCESS_TOKEN, CODEX_API_KEY, OPENAI_API_KEY i OPENAI_FEDERATION_RULE_ID.' >&2
    exit 1
fi

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
course_home="${XDG_DATA_HOME:-$HOME/.local/share}/JSystems/Codex-Java-2026-10"
umask 077
mkdir -p -- "$course_home"

CODEX_HOME="$course_home" CODEX_SQLITE_HOME="$course_home" \
    exec codex --no-daemon --cd "$repo_dir" "$@"
