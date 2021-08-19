#!/bin/bash
# Bootstrap machine

ENV_HOME="/home/vagrant/"
ENV_BASHRC="${ENV_HOME}.bashrc" 
# ENV_PROFILE="${ENV_HOME}.profile" 
# ENV_BIN="${ENV_HOME}bin/"
# ENV_KUBELOC="${ENV_HOME}.kube/"

step=1
step() {
    echo "Step $step $1"
    step=$((step+1))
}

## Update package manager zypper
update_zypper() {
    step "===== Updating zypper ====="
    sudo zypper ar --refresh https://download.opensuse.org/repositories/devel:/languages:/go/openSUSE_Leap_15.2/ devel # Add repo to install golang
    sudo zypper ar --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Leap_15.2 snappy
    sudo zypper mr -p 70 devel snappy
    sudo zypper --gpg-auto-import-keys refresh
}

install_golang() {
    sudo zypper install -y go1.15 
}

##Installing docker 
install_docker() {
    step "===== Installing Docker ====="
    sudo zypper install -y docker python3-docker-compose
    sudo systemctl enable docker
    sudo usermod -G docker -a vagrant 
    sudo systemctl restart docker
    newgrp docker
}

install_go() {
    step "===== Installing GO ====="
    sudo zypper in -y go1.15
}

install_git() {
    step "===== Installing Git ====="
    sudo zypper install -y git
}

install_pip_flask(){
    step "===== Installing Pip and Flask ====="
    sudo zypper install -y python3-pip
    sudo pip3 install --upgrade pip
    sudo pip install flask
}

install_K3s() {
    step "===== Installing K3s ====="
    curl -sfL https://get.k3s.io | sh -
    sudo chown vagrant:vagrant '/etc/rancher/k3s/k3s.yaml'
}


modify_bashrc() {
    step "===== Updating ~/.bashrc ====="

    # Modifying ~/.bashrc
    echo "set -o vi" >> "${ENV_BASHRC}"
    echo "source /usr/share/bash-completion/bash_completion && source <(kubectl completion bash)" >> "${ENV_BASHRC}"
    echo 'alias k=kubectl' >>  "${ENV_BASHRC}"
    echo 'complete -F __start_kubectl k' >> "${ENV_BASHRC}"
    echo "source /usr/share/bash-completion/bash_completion && source <(helm completion bash)" >> "${ENV_BASHRC}"
}


main() {
    update_zypper
    install_docker
    install_go
    install_git
    install_pip_flask
    install_K3s
    modify_bashrc

    echo ==========
    echo "All DONE"
    echo ==========
}

main