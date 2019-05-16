#!/bin/bash

set -e

case $SHELL in
    */bash)
        shell="bash"
        ;;
    */zsh)
        shell="zsh"
        ;;
    *)
        echo "Unable to determine used shell!"
        exit 1
esac

KUBE_SOURCE=~/.kube/kube.$shell

if [ ! -d ~/.kube ] ; then
    mkdir ~/.kube
fi


# Install kubectl
# https://kubernetes.io/docs/tasks/tools/install-kubectl/
kubectl_version=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
echo ">> Installing kubectl $kubectl_version"
curl -LO https://storage.googleapis.com/kubernetes-release/release/$kubectl_version/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# kubectl krew plugin manager
# https://github.com/kubernetes-sigs/krew#installation
krew_version=$(curl --silent "https://api.github.com/repos/kubernetes-sigs/krew/releases/latest" | sed -n "s/.*\"tag_name\": \"\(.*\)\",$/\1/p")
echo ">> Installing kubectl krew $krew_version"
if ! $(kubectl krew &> /dev/null) ; then
    (
      set -x; cd "$(mktemp -d)" &&
          curl -fsSLO "https://storage.googleapis.com/krew/$krew_version/krew.{tar.gz,yaml}" &&
          tar zxvf krew.tar.gz &&
          ./krew-"$(uname | tr '[:upper:]' '[:lower:]')_amd64" install \
          --manifest=krew.yaml --archive=krew.tar.gz
    ) > /dev/null
fi

echo ">> To finalize installation add the following to your .${shell}rc:"
echo ">>     source $KUBE_SOURCE"

cat <<SOURCE > $KUBE_SOURCE
if command -v kubectl 1> /dev/null ; then

    source <(kubectl completion $shell)

    alias k=kubectl
    alias ks='kubectl -n kube-system'
    alias ki='kubectl cluster-info'
    alias kctx='kubectx'
    alias kns='kubens'
    alias kon='kubeon -g'
    alias koff='kubeoff -g'
    alias klogin='kubectl oidc-login'

    # kubectl krew plugin manager
    export PATH="\${KREW_ROOT:-\$HOME/.krew}/bin:\$PATH"
fi

alias kube='cat << EOF
Kubernetes commands:
   k        kubectl
   ks       k -n kube-system
   ki       k cluster-info

   klogin   kubectl oidc-login

   kctx     kubectx             Change kubectl context
   kns      kubens              Change kubectl namespace

   kon      kubeon              Toggle Kube-PS1 on
   koff     kubeoff             Toggle Kube-PS1 off

Kubernetes plugins:
    k krew   kubectl plugin manager
EOF
'

SOURCE

if [ "$shell" == "zsh" ] && command -v antibody 1> /dev/null ; then
    cat <<SOURCE >> $KUBE_SOURCE
antibody bundle <<ANTI > /dev/null
jonmosco/kube-ps1
ahmetb/kubectx kind:path
ahmetb/kubectx kind:fpath path:completion
ANTI

# Kube-PS1
RPROMPT='\$(kube_ps1) '\$RPROMPT

# Kubectx
DIR=\$(antibody home)/https-COLON--SLASH--SLASH-github.com-SLASH-ahmetb-SLASH-kubectx/completion
if [ -f \$DIR/kubectx.zsh ] ; then ln -s \$DIR/kubectx.zsh \$DIR/_kubectx.zsh ; fi
if [ -f \$DIR/kubens.zsh ] ; then ln -s \$DIR/kubens.zsh \$DIR/_kubens.zsh ; fi
SOURCE

fi
