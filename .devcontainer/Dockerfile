FROM mcr.microsoft.com/vscode/devcontainers/universal:1

# install packages
RUN export DEBIAN_FRONTEND=noninteractive && \
    sudo apt-get update && \
    sudo apt-get -y install --no-install-recommends apt-utils dialog apt-transport-https ca-certificates && \
    sudo apt-get -y install --no-install-recommends curl git wget nano bash-completion software-properties-common make jq httpie

# install k9s, github cli, jp and fluxctl
RUN sudo curl -Lo ./k9s.tar.gz https://github.com/derailed/k9s/releases/download/v0.24.2/k9s_Linux_x86_64.tar.gz && \
    sudo mkdir k9s && \
    sudo tar xvzf k9s.tar.gz -C ./k9s && \
    sudo mv ./k9s/k9s /usr/local/bin/k9s && \
    sudo rm -rf k9s.tar.gz k9s && \
    VERSION=$(curl -i https://github.com/jmespath/jp/releases/latest | grep "location: https://github.com/" | rev | cut -f 1 -d / | rev | sed 's/\r//') && \
    sudo wget https://github.com/jmespath/jp/releases/download/$VERSION/jp-linux-amd64 -O /usr/local/bin/jp && \
    sudo chmod +x /usr/local/bin/jp && \
    sudo wget https://github.com/cli/cli/releases/download/v1.10.3/gh_1.10.3_linux_amd64.deb && \
    sudo dpkg -i gh_1.10.3_linux_amd64.deb && \
    sudo rm gh_1.10.3_linux_amd64.deb && \
    kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null && \
    sudo curl -L https://github.com/fluxcd/flux/releases/download/1.14.2/fluxctl_linux_amd64 -o /usr/local/bin/fluxctl && \
    sudo chmod +x /usr/local/bin/fluxctl && \
    sudo apt install -f
