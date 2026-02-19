FROM mcr.microsoft.com/devcontainers/javascript-node:4.0.8-24-bookworm

ARG TZ
ENV TZ="$TZ"

# Add official apt repos for gh CLI, 1Password CLI, and Google Cloud CLI
RUN mkdir -p -m 755 /etc/apt/keyrings && \
  wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null && \
  chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
  wget -qO- https://downloads.1password.com/linux/keys/1password.asc \
    | gpg --dearmor --output /etc/apt/keyrings/1password-archive-keyring.gpg && \
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" \
    | tee /etc/apt/sources.list.d/1password-cli.list > /dev/null && \
  curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | gpg --dearmor --output /etc/apt/keyrings/cloud.google.gpg && \
  echo "deb [signed-by=/etc/apt/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
    | tee /etc/apt/sources.list.d/google-cloud-sdk.list > /dev/null

# Install packages not already in devcontainers/javascript-node
# (base includes: build-essential, libssl-dev, zlib1g-dev, libbz2-dev,
#  libreadline-dev, libsqlite3-dev, libncursesw5-dev, libxml2-dev,
#  libffi-dev, liblzma-dev, git, zsh, jq, nano, unzip, gnupg2, etc.)
RUN apt-get update && apt-get install -y --no-install-recommends \
  fzf \
  vim \
  libxmlsec1-dev \
  postgresql-client \
  iptables \
  ipset \
  aggregate \
  gh \
  1password-cli \
  google-cloud-cli \
  google-cloud-cli-gke-gcloud-auth-plugin \
  google-cloud-cli-cloud-build-local \
  google-cloud-cli-cloud-run-proxy \
  kubectl \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# renovate: datasource=github-releases depName=dandavison/delta
ARG GIT_DELTA_VERSION=0.18.2
RUN ARCH=$(dpkg --print-architecture) && \
  wget "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  dpkg -i "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  rm "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb"

RUN mkdir -p /workspace /home/node/.claude && \
  chown -R node:node /workspace /home/node/.claude

WORKDIR /workspace

ENV DEVCONTAINER=true
ENV SHELL=/bin/zsh
ENV EDITOR=nano
ENV VISUAL=nano

USER node

# Configure shell: fzf integration + local bin PATH
RUN echo 'source /usr/share/doc/fzf/examples/key-bindings.zsh' >> ~/.zshrc && \
  echo 'source /usr/share/doc/fzf/examples/completion.zsh' >> ~/.zshrc && \
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc

RUN curl -fsSL https://claude.ai/install.sh | bash

RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# renovate: datasource=python-version depName=python
ARG PYTHON_VERSION=3.14.3
RUN /home/node/.local/bin/uv python install $PYTHON_VERSION

COPY init-firewall.sh /usr/local/bin/
USER root
RUN chmod +x /usr/local/bin/init-firewall.sh
USER node
