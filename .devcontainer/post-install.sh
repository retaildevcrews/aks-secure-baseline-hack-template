#!/bin/sh

# create directories
mkdir -p $HOME/.ssh
mkdir -p $HOME/.kube
mkdir -p $HOME/bin
mkdir -p $HOME/.local/bin
mkdir -p $HOME/.k9s
mkdir -p $HOME/go/src
mkdir -p $HOME/.local
mkdir -p $HOME/.dotnet/tools

# add to .bashrc
echo "" >> $HOME/.bashrc
echo "export PATH=$PATH:$HOME/.local/bin:$HOME/.dotnet/tools" >> $HOME/.bashrc
echo "alias k='kubectl'" >> $HOME/.bashrc
echo "alias kga='kubectl get all'" >> $HOME/.bashrc
echo "alias kgaa='kubectl get all --all-namespaces'" >> $HOME/.bashrc
echo "alias kaf='kubectl apply -f'" >> $HOME/.bashrc
echo "alias kdelf='kubectl delete -f'" >> $HOME/.bashrc
echo "alias kl='kubectl logs'" >> $HOME/.bashrc
echo "alias kccc='kubectl config current-context'" >> $HOME/.bashrc
echo "alias kcgc='kubectl config get-contexts'" >> $HOME/.bashrc
echo "alias kj='kubectl exec -it jumpbox -- bash -l'" >> $HOME/.bashrc
echo "alias kje='kubectl exec -it jumpbox -- '" >> $HOME/.bashrc
echo "export FLUX_FORWARD_NAMESPACE=flux-cd" >> $HOME/.bashrc
echo "export GO111MODULE=on" >> $HOME/.bashrc
echo "alias ipconfig='ip -4 a show eth0 | grep inet | sed \"s/inet//g\" | sed \"s/ //g\" | cut -d / -f 1'" >> $HOME/.bashrc
echo 'export PIP=$(ipconfig | tail -n 1)' >> $HOME/.bashrc
echo 'complete -F __start_kubectl k' >> $HOME/.bashrc

# install WebV (using the beta for testing)
dotnet tool install -g --version 2.0.0-beta2 webvalidate

# configure git per team standards
git config --global core.whitespace blank-at-eol,blank-at-eof,space-before-tab
git config --global pull.rebase false
git config --global init.defaultbranch main
git config --global core.pager more
