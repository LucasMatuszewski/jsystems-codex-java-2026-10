---
name: glab-course
description: Use when working with GitLab from the terminal through glab - issues, merge requests, comments, pipelines, job logs and CI variables - on the course GitLab or another self-managed instance.
---

# GitLab through glab, without interactive prompts

glab is the GitLab CLI. Prefer it over a GitLab MCP server or raw REST calls: it already handles authentication, pagination and the project resolved from the Git remote. Use `glab api` only for something no subcommand covers.

## Before the first command

1. Confirm the host and identity: `glab auth status --hostname <host>`. On the course instance the host is in `$env:GL` (PowerShell). If not logged in, stop and ask the user; never ask for a token in chat, never print or log one.
2. Run from inside the project's Git checkout so glab resolves the project from `origin`. Otherwise pass `--repo <host>/<namespace>/<project>`.
3. Make every call non-interactive for this session: `$env:GLAB_NO_PROMPT = '1'` and `$env:GLAB_PAGER = 'cat'` (PowerShell; on bash use `export`). Pass `--yes` where a command asks for confirmation and `--description-file` instead of opening an editor.

## Reading

- Use `--output json` (`-F json`) when you need to parse the result: `glab mr view <iid> -F json`, `glab issue view <iid> -F json`, `glab ci list -F json`, `glab ci get -F json`.
- Comments on an MR: `glab mr view <iid> --comments`.
- Pipeline of the current branch: `glab ci status`; a failed job's log: `glab ci trace <job-id>` (or `--pipeline-id <id>`). Quote the failing lines from the log; do not guess the cause.
- Validate CI configuration before pushing it: `glab ci lint`. Lint checks syntax, not whether tests pass.

## Writing

Every write is visible to other people. State the exact command and wait for the user's approval before running it, unless the user already asked for that specific action.

- Issue: `glab issue create --title "..." --description-file <file> --label <l> --yes`.
- MR: `glab mr create --source-branch <b> --target-branch <t> --title "..." --description-file <file> --draft --yes`. Default to `--draft`; never merge, approve or close on your own.
- Comment: `glab mr note create <iid> --message "..."`.
- CI variable from a secret: pipe it, never put it on the command line: `$t | glab variable set NAME --masked`.

## Report

Return the real URLs, IIDs, pipeline and job IDs from glab output, and say which commands ran and which you only proposed. A created MR or a green lint is not a passed pipeline: report the pipeline status separately.

Sources: [glab documentation](https://docs.gitlab.com/cli/), checked against glab 1.125.0 on 29.10.2026.
