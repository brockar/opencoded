FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
  vim \
  ca-certificates \
  curl \
  gnupg \
  openssh-client \
  && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && apt-get update \
  && apt-get install -y --no-install-recommends gh \
  && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash debian \
  && mkdir -p /workspace \
  && chown debian:debian /workspace

USER debian
WORKDIR /home/debian

ARG OPENCODE_VERSION=latest

RUN mkdir -p /home/debian/.ssh \
  && ssh-keyscan github.com >> /home/debian/.ssh/known_hosts \
  && mkdir -p /home/debian/.local/share/opencode /home/debian/.config/opencode

RUN if [ "${OPENCODE_VERSION}" = "latest" ]; then \
    curl -fsSL https://opencode.ai/install | bash; \
  else \
    curl -fsSL https://opencode.ai/install | bash -s -- --version "${OPENCODE_VERSION}"; \
  fi
ENV PATH="/home/debian/.opencode/bin:${PATH}"
ENTRYPOINT ["opencode"]
