# Shell Setup Guide

<!--toc:start-->
- [Shell Setup Guide](#shell-setup-guide)
  - [Option 1: Setup Script (Recommended)](#option-1-setup-script-recommended)
  - [Option 2: Manual Setup (Quick)](#option-2-manual-setup-quick)
  - [Usage](#usage)
<!--toc:end-->

## Option 1: Setup Script (Recommended)

Run the included script — it auto-detects your shell (zsh preferred, bash fallback) and sets everything up:

```bash
~/opencoded/setup_shell.sh
```

The script will:

1. Detect whether you have **zsh** or **bash**
2. Write the `opencoded` and `opencodedt` functions to `~/.local/bin/opencoded-functions.sh`
3. Add a single `source` line to your `~/.zshrc` or `~/.bashrc` (idempotent — safe to run multiple times)
4. Tell you which rc file it configured

Then reload your shell:

```bash
source ~/.zshrc   # or ~/.bashrc
```

## Option 2: Manual Setup (Quick)

Add the functions directly to your `~/.zshrc` or `~/.bashrc`:

```bash
opencoded() {
  docker run -d \
    --name opencoded \
    --rm \
    --user "$(id -u):$(id -g)" \
    -p "${OPENCODE_PORT:-4096}:4096" \
    -v "${OPENCODE_PATH:-$(pwd)}:/workspace" \
    -v "$HOME/.ssh/id_ed25519:/home/opencoded/.ssh/id_ed25519:ro" \
    -v "$HOME/.config/opencode:/home/opencoded/.config/opencode" \
    -v "$HOME/.local/share/opencode/auth.json:/home/opencoded/.local/share/opencode/auth.json" \
    -e "GH_TOKEN=${GH_TOKEN:-}" \
    -e "OPENCODE_SERVER_USERNAME=${OPENCODE_SERVER_USERNAME:-opencode}" \
    -e "OPENCODE_SERVER_PASSWORD=${OPENCODE_SERVER_PASSWORD:-}" \
    ghcr.io/brockar/opencoded:latest web --hostname 0.0.0.0 --port 4096
}

opencodedt() {
  docker run -it \
    --rm \
    --name opencoded-tui \
    --user "$(id -u):$(id -g)" \
    -v "${OPENCODE_PATH:-$(pwd)}:/workspace" \
    -v "$HOME/.ssh/id_ed25519:/home/opencoded/.ssh/id_ed25519:ro" \
    -v "$HOME/.config/opencode:/home/opencoded/.config/opencode" \
    -v "$HOME/.local/share/opencode/auth.json:/home/opencoded/.local/share/opencode/auth.json" \
    -e "GH_TOKEN=${GH_TOKEN:-}" \
    ghcr.io/brockar/opencoded:latest
}
```

Then reload: `source ~/.zshrc` or `source ~/.bashrc`.

## Usage

```bash
# Start web mode (detached)
opencoded

# Start TUI mode (interactive)
opencodedt

# Custom port
OPENCODE_PORT=5000 opencoded

# Custom project path
OPENCODE_PATH=/path/to/project opencoded

# Both
OPENCODE_PORT=5000 OPENCODE_PATH=/path/to/project opencoded

# Stop
docker stop opencoded
```
