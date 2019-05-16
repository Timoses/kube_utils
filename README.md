# Kubectl utilities

Simple bash script that installs

* kubectl
* kubectl krew plugin manager

## Installation

```
curl https://raw.githubusercontent.com/Timoses/kube_utils/master/install.sh | bash
```

You can use the same command to update your installation.

## Features

'{xxx}' denotes the supported shells and conditions. Support for further shells may be implemented in the future.

* [kubectl auto completion](https://kubernetes.io/docs/reference/kubectl/cheatsheet/#kubectl-autocomplete) {bash,zsh}
* [kube-ps1](https://github.com/jonmosco/kube-ps1) {zsh w/ antibody}
* [kubectx](https://github.com/ahmetb/kubectx) {zsh w/ antibody}

### Aliases

The script additionally sets up aliases for quicker interaction with `kubectl`.

The alias `kube` will print a list of available aliases.
