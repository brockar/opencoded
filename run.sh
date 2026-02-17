#!/usr/bin/env bash
### VARIABLES
UID="${UID:-$(id -u)}"
GID="${GID:-$(id -g)}"
PORT="${OPENCODE_PORT:-4096}"
PROJECT_PATH="${PROJECT_PATH:-$(pwd)}"
CONTAINER_NAME="opencoded"
OC_AUTH_PATH="$HOME/.local/share/opencode/auth.json"

### COLORS
set -e
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}Setting up OpenCode Docker environment...${NC}"
mkdir -p ~/.config/opencode
mkdir -p ~/.local/share/opencode
mkdir -p ~/.ssh
echo -e "${GREEN}Directories created.${NC}"

if [ ! -f "$OC_AUTH_PATH" ]; then
  echo -e "${YELLOW}Creating empty auth.json...${NC}"
  echo '{}' >"$OC_AUTH_PATH"
  echo -e "${GREEN}auth.json created at $OC_AUTH_PATH${NC}"
else
  echo -e "${GREEN}auth.json already exists.${NC}"
fi

if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
  echo -e "${YELLOW}WARNING: ~/.ssh/id_ed25519 not found. Git operations may not work.${NC}"
  echo -e "Generate one with:"
  echo -e "${CYAN}ssh-keygen -t ed25519 -C 'your@email.com'${NC}"
fi

if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo ""
  echo -e "${YELLOW}Container '${CONTAINER_NAME}' already exists.${NC}"
  echo -e "Stopping and removing existing container..."
  docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true
  docker rm "$CONTAINER_NAME" >/dev/null 2>&1 || true
  echo -e "${GREEN}Existing container removed.${NC}"
fi

echo ""
echo -e "${BLUE}Project path: ${PROJECT_PATH}${NC}"
echo -e "${BLUE}Starting OpenCode container on port $PORT...${NC}"

docker run -d \
  --name "$CONTAINER_NAME" \
  --rm \
  --user "${UID}:${GID}" \
  -p "${PORT}:4096" \
  -v "${PROJECT_PATH}:/workspace" \
  -v "$HOME/.ssh/id_ed25519:/home/debian/.ssh/id_ed25519:ro" \
  -v "$HOME/.config/opencode:/home/debian/.config/opencode" \
  -v "$HOME/.local/share/opencode/auth.json:/home/debian/.local/share/opencode/auth.json" \
  -e "GH_TOKEN=${GH_TOKEN:-}" \
  -e "OPENCODE_SERVER_PASSWORD=${OPENCODE_SERVER_PASSWORD:-}" \
  ghcr.io/brockar/opencoded:latest web --hostname 0.0.0.0 --port 4096

echo ""
echo -e "${GREEN}OpenCode is starting!${NC}"
echo -e "Access the web interface at: ${CYAN}http://localhost:$PORT${NC}"
echo ""
echo -e "${BLUE}Useful commands:${NC}"
echo -e "  ${CYAN}docker logs -f $CONTAINER_NAME${NC}  - View logs"
echo -e "  ${CYAN}docker stop $CONTAINER_NAME${NC}    - Stop container"
