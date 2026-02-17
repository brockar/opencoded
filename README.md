# OpenCode Dev Container

A Dockerized way to run [OpenCode](https://opencode.ai) — the AI-powered coding assistant — in both **web-based** and **TUI** modes. This container packages OpenCode with all dependencies, providing isolated, reproducible environments for AI-assisted development.

## Features

- **Web Interface**: Access OpenCode through your browser at <http://localhost:4096>
- **TUI Mode**: Run OpenCode directly in your terminal for a native CLI experience
- **Multiple Instances**: Run several OpenCode containers simultaneously on different ports for different projects
- **Persistent Configuration**: Your OpenCode settings and authentication persist across container restarts
- **Git Integration**: SSH keys mounted for seamless git operations
- **Project Isolation**: Each container works on a specific project directory

## Quick Start

### First Time Setup

Ensure you have an SSH key for GitHub:

   ```bash
   cd ~/.ssh/
   ssh-keygen -t ed25519 -C 'your@email.com'
   ```

### Using Docker Compose (recommended)

```bash
docker compose up -d
```

The web interface will be available at: **<http://localhost:4096>**

### Using the helper script

```bash
./run.sh
```

Run on a specific project:

```bash
PROJECT_PATH=/path/to/project ./run.sh
```

### Custom port

```bash
OPENCODE_PORT=3000 docker compose up -d
```

Then access at: **<http://localhost:3000>**

## Docker Run Examples

### Web Server

Run the web server on port 4096:

```bash
docker run -d \
  --name opencoded \
  --rm \
  --user "$(id -u):$(id -g)" \
  -p 4096:4096 \
  -v $(pwd):/workspace \
  -v ~/.ssh/id_ed25519:/home/debian/.ssh/id_ed25519:ro \
  -v ~/.config/opencode:/home/debian/.config/opencode \
  -v ~/.local/share/opencode/auth.json:/home/debian/.local/share/opencode/auth.json \
  -e GH_TOKEN=${GH_TOKEN:-} \
  ghcr.io/brockar/opencoded:latest web --hostname 0.0.0.0 --port 4096
```

Then access at: **<http://localhost:4096>**

### TUI Mode

Run OpenCode in interactive terminal mode:

```bash
docker run -it \
  --rm \
  --user "$(id -u):$(id -g)" \
  -v $(pwd):/workspace \
  -v ~/.ssh/id_ed25519:/home/debian/.ssh/id_ed25519:ro \
  -v ~/.config/opencode:/home/debian/.config/opencode \
  -v ~/.local/share/opencode/auth.json:/home/debian/.local/share/opencode/auth.json \
  -e GH_TOKEN=${GH_TOKEN:-} \
  ghcr.io/brockar/opencoded:latest
```

This starts the TUI interface directly in your terminal. Exit with `Ctrl+C` or type `/exit`.

## Running Multiple Instances

You can run multiple OpenCode containers simultaneously on different ports for different projects:

```bash
# Instance 1: Project A on port 4096
docker run -d \
  --name opencoded-project-a \
  --rm \
  --user "$(id -u):$(id -g)" \
  -p 4096:4096 \
  -v /path/to/project-a:/workspace \
  -v ~/.ssh/id_ed25519:/home/debian/.ssh/id_ed25519:ro \
  -v ~/.config/opencode:/home/debian/.config/opencode \
  -v ~/.local/share/opencode/auth.json:/home/debian/.local/share/opencode/auth.json \
  -e GH_TOKEN=${GH_TOKEN:-} \
  ghcr.io/brockar/opencoded:latest web --hostname 0.0.0.0 --port 4096

# Instance 2: Project B on port 4097
docker run -d \
  --name opencoded-project-b \
  --rm \
  --user "$(id -u):$(id -g)" \
  -p 4097:4096 \
  -v /path/to/project-b:/workspace \
  -v ~/.ssh/id_ed25519:/home/debian/.ssh/id_ed25519:ro \
  -v ~/.config/opencode:/home/debian/.config/opencode \
  -v ~/.local/share/opencode/auth.json:/home/debian/.local/share/opencode/auth.json \
  -e GH_TOKEN=${GH_TOKEN:-} \
  ghcr.io/brockar/opencoded:latest web --hostname 0.0.0.0 --port 4096
```

Access them separately:

- Project A: <http://localhost:4096>
- Project B: <http://localhost:4097>

## Configuration

### Helper Script Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PROJECT_PATH` | Path to project directory | `$(pwd)` |
| `OPENCODE_PORT` | Host port to expose | `4096` |
| `UID` | User ID for file permissions | `$(id -u)` |
| `GID` | Group ID for file permissions | `$(id -g)` |

### Volume Mounts

The container mounts:

- `Project directory` → project (your project files)
- `~/.ssh/id_ed25519` → SSH key for git operations
- `~/.config/opencode` → OpenCode configuration
- `~/.local/share/opencode/auth.json` → OpenCode authentication

### Environment Variables

- `GH_TOKEN` - GitHub token (optional)

## Shell Alias (Recommended)

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
alias opencoded='docker run -d --rm --name opencoded --user "$(id -u):$(id -g)" -p "${OPENCODE_PORT:-4096}:4096" -v "${OPENCODE_PATH:-$(pwd)}:/workspace" -v "$HOME/.ssh/id_ed25519:/home/debian/.ssh/id_ed25519:ro" -v "$HOME/.config/opencode:/home/debian/.config/opencode" -v "$HOME/.local/share/opencode/auth.json:/home/debian/.local/share/opencode/auth.json" -e "GH_TOKEN=${GH_TOKEN:-}" ghcr.io/brockar/opencoded:latest web --hostname 0.0.0.0 --port 4096'

alias opencodedt='docker run -it --rm --name opencoded-tui --user "$(id -u):$(id -g)" -v "${OPENCODE_PATH:-$(pwd)}:/workspace" -v "$HOME/.ssh/id_ed25519:/home/debian/.ssh/id_ed25519:ro" -v "$HOME/.config/opencode:/home/debian/.config/opencode" -v "$HOME/.local/share/opencode/auth.json:/home/debian/.local/share/opencode/auth.json" -e "GH_TOKEN=${GH_TOKEN:-}" ghcr.io/brockar/opencoded:latest'
```

Then reload: `source ~/.bashrc`

### Usage with Environment Variables

```bash
opencoded

# Custom port
OPENCODE_PORT=5000 opencoded

# Custom project path
OPENCODE_PATH=/path/to/project opencoded

# Both
OPENCODE_PORT=5000 OPENCODE_PATH=/path/to/project opencoded

# TUI mode
opencodedt

# Stop
docker stop opencoded
```
