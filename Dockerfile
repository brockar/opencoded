FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
  vim \
  ripgrep \
  ca-certificates \
  curl \
  gnupg \
  openssh-client \
  less \
  sudo \
  unzip \
  git \
  git-lfs \
  jq \
  fd-find \
  patch \
  procps \
  && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && apt-get update \
  && apt-get install -y --no-install-recommends gh \
  && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash opencoded \
  && mkdir -p /workspace \
  && chown opencoded:opencoded /workspace \
  && echo "opencoded ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER opencoded
WORKDIR /home/opencoded

ARG OPENCODE_VERSION=latest

RUN mkdir -p /home/opencoded/.ssh \
  && ssh-keyscan github.com >> /home/opencoded/.ssh/known_hosts \
  && mkdir -p /home/opencoded/.local/share/opencode /home/opencoded/.config/opencode

RUN if [ "${OPENCODE_VERSION}" = "latest" ]; then \
  curl -fsSL https://opencode.ai/install | bash; \
  else \
  curl -fsSL https://opencode.ai/install | bash -s -- --version "${OPENCODE_VERSION}"; \
  fi
ENV PATH="/home/opencoded/.opencode/bin:${PATH}"
ENTRYPOINT ["opencode"]
