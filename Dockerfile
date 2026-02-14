FROM mcr.microsoft.com/devcontainers/javascript-node:4.0.8-24-bookworm

ARG TZ
ENV TZ="$TZ"

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
  && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# renovate: datasource=github-releases depName=cli/cli
ARG GH_CLI_VERSION=2.86.0
RUN ARCH=$(dpkg --print-architecture) && \
  wget "https://github.com/cli/cli/releases/download/v${GH_CLI_VERSION}/gh_${GH_CLI_VERSION}_linux_${ARCH}.deb" && \
  dpkg -i "gh_${GH_CLI_VERSION}_linux_${ARCH}.deb" && \
  rm "gh_${GH_CLI_VERSION}_linux_${ARCH}.deb"

# renovate: datasource=github-releases depName=dandavison/delta
ARG GIT_DELTA_VERSION=0.18.2
RUN ARCH=$(dpkg --print-architecture) && \
  wget "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  dpkg -i "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  rm "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb"

# renovate: datasource=custom.one-password-cli depName=1password-cli
ARG OP_CLI_VERSION=2.32.1
RUN ARCH=$(dpkg --print-architecture) && \
  wget "https://cache.agilebits.com/dist/1P/op2/pkg/v${OP_CLI_VERSION}/op_linux_${ARCH}_v${OP_CLI_VERSION}.zip" && \
  unzip "op_linux_${ARCH}_v${OP_CLI_VERSION}.zip" -d /usr/local/bin && \
  rm "op_linux_${ARCH}_v${OP_CLI_VERSION}.zip"

RUN mkdir -p /workspace /home/node/.claude && \
  chown -R node:node /workspace /home/node/.claude

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
