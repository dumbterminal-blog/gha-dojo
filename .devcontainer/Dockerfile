FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Force add the pre-existing vscode user to the docker group for socket access
RUN apt-get update && apt-get install -y sudo \
  && groupadd -f docker \
  && usermod -aG docker vscode

RUN apt-get install -y wget tar \
  && ARCH=$(dpkg --print-architecture) \
  && case "$ARCH" in \
       amd64) ACT_ARCH="x86_64" ;; \
       arm64) ACT_ARCH="arm64" ;; \
       *) echo "Unsupported arch: $ARCH" && exit 1 ;; \
     esac \
  && wget -qO /tmp/act.tar.gz \
       "https://github.com/nektos/act/releases/latest/download/act_Linux_${ACT_ARCH}.tar.gz" \
  && tar -xzf /tmp/act.tar.gz -C /usr/local/bin act \
  && chmod +x /usr/local/bin/act \
  && rm /tmp/act.tar.gz \
  && act --version

# Create a wrapper so 'act' always runs with sudo permissions inside the container
RUN mv /usr/local/bin/act /usr/local/bin/act-binary \
  && echo '#!/bin/bash\nsudo /usr/local/bin/act-binary "$@"' > /usr/local/bin/act \
  && chmod +x /usr/local/bin/act

# Receive the token at build time and bind it as a permanent environment variable
ARG GITHUB_TOKEN
ENV GITHUB_TOKEN=${GITHUB_TOKEN}

RUN (type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
	&& out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
	&& cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& sudo mkdir -p -m 755 /etc/apt/sources.list.d \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y

RUN apt-get install -y ca-certificates curl \
  && install -m 0755 -d /etc/apt/keyrings \
  && curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc \
  && chmod a+r /etc/apt/keyrings/docker.asc \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null \
  && apt-get update \
  && apt-get install -y docker-ce-cli
