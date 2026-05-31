# cmuxws

Create a new cmux window with one workspace per feature, route, or navigation item in a repo.

`cmuxws` is a small shell CLI for people who like to work with one agent/workspace per product area. Run it from a repository and it will infer workspace names, create a cmux window, and optionally start `codex-yolo`, `claude-yolo`, or another agent command in every workspace.

## Requirements

- macOS with [cmux](https://cmux.com/) installed and available in `PATH`
- Node.js available in `PATH`
- Bash

## Install

Clone the repo and link the script:

```bash
git clone https://github.com/YOUR_GITHUB_USER/cmuxws.git
cd cmuxws
chmod +x bin/cmuxws
ln -sf "$PWD/bin/cmuxws" "$HOME/.local/bin/cmuxws"
```

Make sure `~/.local/bin` is in your `PATH`.

## Usage

From inside any repo:

```bash
cmuxws
```

Or pass a repo path:

```bash
cmuxws /path/to/repo
```

Preview detected workspaces:

```bash
cmuxws --print
```

Preview the cmux commands without creating anything:

```bash
cmuxws --dry-run --no-agent
```

Choose the agent:

```bash
cmuxws --codex
cmuxws --claude
cmuxws --agent "my-agent-command"
cmuxws --no-agent
```

Append extra workspaces:

```bash
cmuxws --include "iOS,Chrome Extension"
```

Set a default custom agent:

```bash
CMUXWS_AGENT="claude-yolo" cmuxws
```

## Detection

`cmuxws` uses heuristics in this order:

1. `.cmux/features.txt`, one workspace name per line.
2. Expo Router tab titles in `app/(tabs)/_layout.tsx`.
3. Common navigation/menu files such as `app-navigation.tsx`, `navigation.tsx`, `menu.tsx`, and `sidebar.tsx` with `label: "..."` entries.
4. Common route files under `app/`, `src/app/`, `pages/`, and `src/pages/`.
5. Feature directories under `features/`, `modules/`, `domains/`, `src/features/`, `src/modules/`, and `src/domains/`.
6. Fallback workspaces: `Overview`, `Implementation`, `Tests`.

For precise control, add `.cmux/features.txt` to a repo:

```text
Dashboard
Companies
Contacts
Pipeline
Settings
```

## Options

```text
Usage:
  cmuxws [repo] [options]

Options:
  --agent <command>        Command to start in each workspace. Default: codex-yolo
  --codex                  Start codex-yolo in each workspace. This is the default.
  --claude                 Start claude-yolo in each workspace.
  --no-agent               Create workspaces without starting an agent.
  --include <a,b,c>        Extra workspace names to append.
  --print                  Print detected workspace names and exit.
  --dry-run                Print cmux actions without creating anything.
  -h, --help               Show this help.
```

## License

MIT
