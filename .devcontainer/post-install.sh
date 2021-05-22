#!/bin/sh

pwd >> status
echo $USER >> status
echo $USERNAME >> status

exit 0

# create directories
mkdir -p .ssh
mkdir -p .kube
mkdir -p bin
mkdir -p .local/bin
mkdir -p .k9s
mkdir -p go/src
mkdir -p .local
mkdir -p .dotnet/tools

# add to .bashrc
echo "" >> .bashrc
echo "export PATH=$PATH:$HOME/.local/bin:$HOME/.dotnet/tools" >> .bashrc
echo "alias k='kubectl'" >> .bashrc
echo "alias kga='kubectl get all'" >> .bashrc
echo "alias kgaa='kubectl get all --all-namespaces'" >> .bashrc
echo "alias kaf='kubectl apply -f'" >> .bashrc
echo "alias kdelf='kubectl delete -f'" >> .bashrc
echo "alias kl='kubectl logs'" >> .bashrc
echo "alias kccc='kubectl config current-context'" >> .bashrc
echo "alias kcgc='kubectl config get-contexts'" >> .bashrc
echo "alias kj='kubectl exec -it jumpbox -- bash -l'" >> .bashrc
echo "alias kje='kubectl exec -it jumpbox -- '" >> .bashrc
echo "export FLUX_FORWARD_NAMESPACE=flux-cd" >> .bashrc
echo "export GO111MODULE=on" >> .bashrc
echo "alias ipconfig='ip -4 a show eth0 | grep inet | sed \"s/inet//g\" | sed \"s/ //g\" | cut -d / -f 1'" >> .bashrc
echo 'export PIP=$(ipconfig | tail -n 1)' >> .bashrc
echo 'complete -F __start_kubectl k' >> .bashrc

# install WebV (using the beta for testing)
dotnet tool install -g --version 2.0.0-beta2 webvalidate

# configure git per team standards
git config --global core.whitespace blank-at-eol,blank-at-eof,space-before-tab
git config --global pull.rebase false
git config --global init.defaultbranch main
git config --global core.pager more

exit 0

# install tools
sudo apt-get update
sudo apt-get -y install --no-install-recommends httpie jq bash-completion
sudo apt-get -y install --no-install-recommends dotnet-sdk-5.0
sudo apt-get -y install --no-install-recommends kubectl
sudo apt-get -y install --no-install-recommends gettext

# install k9s
curl -Lo ./k9s.tar.gz https://github.com/derailed/k9s/releases/download/v0.24.2/k9s_Linux_x86_64.tar.gz
mkdir k9s
tar xvzf k9s.tar.gz -C ./k9s
sudo mv ./k9s/k9s /usr/local/bin/k9s
rm -rf k9s.tar.gz k9s

# install jmespath (jp)
VERSION=$(curl -i https://github.com/jmespath/jp/releases/latest | grep "location: https://github.com/" | rev | cut -f 1 -d / | rev | sed 's/\r//')
sudo wget https://github.com/jmespath/jp/releases/download/$VERSION/jp-linux-amd64 -O /usr/local/bin/jp
sudo chmod +x /usr/local/bin/jp

# install helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
sudo ./get_helm.sh
sudo chmod +x /usr/local/bin/helm
rm get_helm.sh

# install fluxctl
sudo curl -L https://github.com/fluxcd/flux/releases/download/1.14.2/fluxctl_linux_amd64 -o /usr/local/bin/fluxctl && \
sudo chmod +x /usr/local/bin/fluxctl

# clean up
sudo apt-get autoremove -y
sudo apt-get clean -y
