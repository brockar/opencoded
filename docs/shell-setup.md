# Shell Setup Guide

<!--toc:start-->
- [Shell Setup Guide](#shell-setup-guide)
  - [Option 1: Setup Script](#option-1-setup-script)
  - [Option 2: Manual Setup](#option-2-manual-setup)
  - [Usage](#usage)
<!--toc:end-->

## Option 1: Setup Script

Run the included script to configure shell aliases for opencoded:

```bash
~/opencoded/setup_shell.sh
```

The script configures your shell for opencoded:

1. **Shell Detection**: Detects if you use Zsh or Bash, and updates the configuration file (`~/.zshrc` or `~/.bashrc`).
2. **Function Installation**: Creates `~/.local/bin/opencoded-functions.sh` with required Docker functions.
3. **Auto-Sourcing**: Adds a `source` command to load these functions in new terminal sessions.
4. **Setup Confirmation**: Prints the path of the configured file.

The script sets up Docker configuration, including:
- User namespace mapping (creates files with your host user ID)
- SSH key forwarding (for Git operations inside the container)
- Configuration persistence (saves your opencode settings)
- Authentication token sharing (so you do not need to log in again)

Reload your shell:

```bash
source ~/.zshrc   # or ~/.bashrc
```

## Option 2: Manual Setup

Add these functions directly to your `~/.zshrc` or `~/.bashrc` file:

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

Reload your shell:

```bash
source ~/.zshrc   # or ~/.bashrc
```

## Usage

```bash
# Start web mode
opencoded

# Start terminal mode
opencodedt

# Set a custom port
OPENCODE_PORT=5000 opencoded

# Set a custom project path
OPENCODE_PATH=/path/to/project opencoded

# Set both port and project path
OPENCODE_PORT=5000 OPENCODE_PATH=/path/to/project opencoded

# Stop the container
docker stop opencoded
```
