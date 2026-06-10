# Running Multiple Instances

You can run multiple OpenCode containers simultaneously on different ports for different projects or accounts.

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
  -e OPENCODE_SERVER_PASSWORD=${OPENCODE_SERVER_PASSWORD:-} \
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
  -e OPENCODE_SERVER_PASSWORD=${OPENCODE_SERVER_PASSWORD:-} \
  ghcr.io/brockar/opencoded:latest web --hostname 0.0.0.0 --port 4096
```

Access them separately:

- Project A: <http://localhost:4096>
- Project B: <http://localhost:4097>
