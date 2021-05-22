FROM mcr.microsoft.com/vscode/devcontainers/universal:1

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get -y install --no-install-recommends apt-utils dialog

RUN apt-get -y install --no-install-recommends bash-completion apt-transport-https ca-certificates curl git wget nano software-properties-common make

# install k9s, jp (jmespath), fluxctl
RUN wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash && \
    curl -Lo ./k9s.tar.gz https://github.com/derailed/k9s/releases/download/v0.24.2/k9s_Linux_x86_64.tar.gz && \
    mkdir k9s && \
    tar xvzf k9s.tar.gz -C ./k9s && \
    mv ./k9s/k9s /usr/local/bin/k9s && \
    rm -rf k9s.tar.gz k9s && \
    VERSION=$(curl -i https://github.com/jmespath/jp/releases/latest | grep "location: https://github.com/" | rev | cut -f 1 -d / | rev | sed 's/\r//') && \
    wget https://github.com/jmespath/jp/releases/download/$VERSION/jp-linux-amd64 -O /usr/local/bin/jp && \
    chmod +x /usr/local/bin/jp && \
    kubectl completion bash > /etc/bash_completion.d/kubectl && \
    curl -L https://github.com/fluxcd/flux/releases/download/1.14.2/fluxctl_linux_amd64 -o /usr/local/bin/fluxctl && \
    chmod +x /usr/local/bin/fluxctl

RUN apt-get -y install --no-install-recommends httpie jq

RUN apt-get autoremove -y && \
    apt-get clean -y
