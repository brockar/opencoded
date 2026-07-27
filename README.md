# OpenCode Dev Container

<!--toc:start-->
- [OpenCode Dev Container](#opencode-dev-container)
  - [Features](#features)
  - [Quick Start](#quick-start)
    - [Clone the repository](#clone-the-repository)
    - [Prerequisites](#prerequisites)
    - [Use Docker Compose](#use-docker-compose)
    - [Use the helper script](#use-the-helper-script)
  - [Docker Run Examples](#docker-run-examples)
    - [Web Server](#web-server)
    - [Terminal Mode](#terminal-mode)
  - [Configuration](#configuration)
    - [Helper Script Environment Variables](#helper-script-environment-variables)
    - [Volume Mounts](#volume-mounts)
    - [Environment Variables](#environment-variables)
  - [Shell Alias](#shell-alias)
  - [Customize the Container Image](#customize-the-container-image)
<!--toc:end-->

![OpenCode Banner](docs/assets/banner.webp)

This container runs [OpenCode](https://opencode.ai) inside Docker. You can run OpenCode in web mode or terminal mode. The container includes all dependencies and isolates your environment.

## Features

- **Web interface**: Open OpenCode in your browser.
- **TUI mode**: Run OpenCode directly in your terminal.
- **Multiple instances**: Run multiple containers at the same time on different ports. See the [multiple instances guide](docs/multiple_instances.md).
- **Persistent configuration**: Save your OpenCode settings and authentication across container restarts.
- **Git integration**: Mount SSH keys to use Git commands.
- **Project isolation**: Separate projects into distinct containers.

## Quick Start

### Clone the repository

```bash
git clone https://github.com/brockar/opencoded.git ~/opencoded
cd ~/opencoded
```

### Prerequisites

Before you run the container, make sure you have these items:

- An SSH key at `~/.ssh/id_ed25519` for Git commands inside the container.
- Configured OpenCode authentication. See the [configuration section](#configuration).

### Use Docker Compose

Run this command:

```bash
docker compose up -d
```

Open the web interface at **<http://localhost:4096>**.

### Use the helper script

Run the helper script:

```bash
~/opencoded/run.sh
```

To run the container for a specific project:

```bash
PROJECT_PATH=/path/to/project ~/opencoded/run.sh
```

## Docker Run Examples

### Web Server

Run the web server container:

```bash
docker run -d \
  --name opencoded \
  --rm \
  --user "$(id -u):$(id -g)" \
  -p 4096:4096 \
  -v $(pwd):/workspace \
  -v ~/.ssh/id_ed25519:/home/opencoded/.ssh/id_ed25519:ro \
  -v ~/.config/opencode:/home/opencoded/.config/opencode \
  -v ~/.local/share/opencode/auth.json:/home/opencoded/.local/share/opencode/auth.json \
  -e GH_TOKEN=${GH_TOKEN:-} \
  -e OPENCODE_SERVER_USERNAME=${OPENCODE_SERVER_USERNAME:-opencode} \
  -e OPENCODE_SERVER_PASSWORD=${OPENCODE_SERVER_PASSWORD:-} \
  ghcr.io/brockar/opencoded:latest web --hostname 0.0.0.0 --port 4096
```

Open the web interface at **<http://localhost:4096>**.

### TUI Mode

Run OpenCode in terminal mode:

```bash
docker run -it \
  --rm \
  --user "$(id -u):$(id -g)" \
  -v $(pwd):/workspace \
  -v ~/.ssh/id_ed25519:/home/opencoded/.ssh/id_ed25519:ro \
  -v ~/.config/opencode:/home/opencoded/.config/opencode \
  -v ~/.local/share/opencode/auth.json:/home/opencoded/.local/share/opencode/auth.json \
  -e GH_TOKEN=${GH_TOKEN:-} \
  ghcr.io/brockar/opencoded:latest
```

This command starts the terminal interface. Press `Ctrl+C` or type `/exit` to stop the container.

## Configuration

### Helper Script Environment Variables

| Variable | Description | Default |
| ---------- | ------------- | --------- |
| `PROJECT_PATH` | Path to project directory | `$(pwd)` |
| `OPENCODE_PORT` | Host port to expose | `4096` |
| `UID` | User ID for file permissions | `$(id -u)` |
| `GID` | Group ID for file permissions | `$(id -g)` |

### Volume Mounts

The container mounts these volumes:

- Project directory: `/workspace`
- `~/.ssh/id_ed25519`: SSH key for Git operations
- `~/.config/opencode`: OpenCode settings
- `~/.local/share/opencode/auth.json`: OpenCode authentication file

> [!TIP]
> **Save session history:** The container mounts `auth.json` by default. Mount the full directory to save conversation history:
>
> ```bash
> -v ~/.local/share/opencode:/home/opencoded/.local/share/opencode
> ```

> [!TIP]
> **Mount your parent code directory:** Mount your `~/code` directory as the workspace. This allows you to open any project in the web interface without restarting the container:
>
> ```bash
> -v ~/code:/workspace
> ```
>
> Open the specific project directory inside the interface.

### Environment Variables

| Variable | Description | Default |
| ---------- | ------------- | --------- |
| `GH_TOKEN` | GitHub token (optional) | - |
| `OPENCODE_SERVER_USERNAME` | Username for web interface authentication | `opencode` |
| `OPENCODE_SERVER_PASSWORD` | Password for web interface authentication | - |

## Shell Alias

Run the setup script to configure shell aliases automatically. The script detects Zsh or Bash:

```bash
~/opencoded/setup_shell.sh
```

Reload your shell after the script finishes. See the [shell setup guide](docs/shell-setup.md) for manual setup steps.

## Customize the Container Image

To add packages to the standard image, edit `Dockerfile`:

```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends \
  your-package-here \
  && rm -rf /var/lib/apt/lists/*
```

To add packages to the slim image, edit `Dockerfile.slim`:

```dockerfile
RUN apk add --no-cache your-package-here
```

Rebuild the image locally:

```bash
# Standard image
docker build -t ghcr.io/brockar/opencoded:latest .
# Slim image
docker build -f Dockerfile.slim -t ghcr.io/brockar/opencoded:slim .
```

> [!NOTE]
> Combine `apt-get install` with `rm -rf /var/lib/apt/lists/*` in the same `RUN` instruction to keep the image size small.
