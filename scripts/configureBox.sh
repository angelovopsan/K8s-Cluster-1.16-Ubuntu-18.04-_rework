#!/bin/bash

# Enable SSH authentication in order to be able to connect to VM with an SSH client
# sudo sed -i -- 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

# Restart SSH daemon in order for previous change to take effect
# sudo systemctl restart sshd

# Reboot machine in order to validate on next logon that Docker is being started on reboot
# sudo reboot

    # kubelet requires swap off
    swapoff -a
    # keep swap off after reboot
    sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

    # install docker v17.03
    # reason for not using docker provision is that it always installs latest version of the docker, but kubeadm requires 17.03 or older
    # apt-get -y update
    # apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    # curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    # add-apt-repository "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable"
    # apt-get update && apt-get install -y docker-ce=$(apt-cache madison docker-ce | grep 17.03 | head -1 | awk '{print $3}')
    # run docker commands as vagrant user (sudo not required)
    # usermod -aG docker vagrant
    # install kubeadm
    # apt-get install -y apt-transport-https curl
    # Add Google's apt repository gpg key

    # https://askubuntu.com/questions/258219/how-do-i-make-apt-get-install-less-noisy
    sudo apt-get -qq update -y
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    # Install specific version of K8S - https://stackoverflow.com/questions/49721708/how-to-install-specific-version-of-kubernetes
    # Ignore docker warning - https://github.com/kubernetes/kubernetes/issues/82326
    sudo bash -c 'cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
    deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF'
    sudo apt-get -qq update -y
    # Check for available version from https://reqbin.com/curl with curl -s https://packages.cloud.google.com/apt/dists/kubernetes-xenial/main/binary-amd64/Packages,
    # paste result in notepad and looks for kubeadm version that matches the desired k8s version and check the dependencies for kubelet and rest.
    #!! curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
    #!! echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list && \
    #!! sudo apt-get update -q && \
    #!! sudo apt-get install -qy kubelet=1.9.6-00 kubectl=1.9.6-00 kubeadm=1.9.6-00
    # https://dev.to/wingkwong/building-a-k8s-cluster-with-kubeadm-50jp
    # https://docs.docker.com/engine/install/ubuntu/
    # https://docs.docker.com/engine/release-notes/18.09/
    # https://ubuntu.pkgs.org/16.04/docker-ce-stable-amd64/
    sudo apt-get -qq install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

    # Add Docker’s official GPG key:
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    # Set up the stable repository:
    sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"

    sudo apt-get -qq update -y

    # Verify available Ubuntu Bionic versions for Docker from https://download.docker.com/linux/ubuntu/dists/bionic/stable/binary-amd64/
    # https://github.com/kubernetes-sigs/kubespray/issues/6160
    sudo apt-get -qq install -y docker-ce=5:18.09.9~3-0~ubuntu-bionic docker-ce-cli=5:18.09.9~3-0~ubuntu-bionic kubelet=1.16.12-00 kubectl=1.16.12-00 kubeadm=1.16.12-00 --allow-downgrades
                                 
    sudo apt-mark hold docker-ce=5:18.09.9~3-0~ubuntu-bionic docker-ce-cli=5:18.09.9~3-0~ubuntu-bionic kubelet=1.16.12-00 kubectl=1.16.12-00 kubeadm=1.16.12-00

    # Verify that Docker is up and running with:
    systemctl status docker

    # Setup Docker Daemon.
    cat > /etc/docker/daemon.json <<EOF
    {
    "exec-opts": ["native.cgroupdriver=systemd"],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m"
    },
    "storage-driver": "overlay2"
    }
EOF

    mkdir -p /etc/systemd/system/docker.service.d

    # Restart docker.
    systemctl daemon-reload
    systemctl restart docker
    
    ## Issue 1: Connection to pod or getting logs from it doesn't work as the commands hit the master URL
    ## https://github.com/kubernetes/kubernetes/issues/60835
    ## Resource:https://medium.com/@joatmon08/playing-with-kubeadm-in-vagrant-machines-part-2-bac431095706
    ## Actions to fix:
    ## Node 1
    ## sudo -i
    ## cd /etc/systemd/system/kubelet.service.d
    ## cp 10-kubeadm.conf 10-kubeadm.conf.`date +%Y-%m-%d`.`whoami`.bkp
    ## root@k8s-master-1.16-rework:/etc/systemd/system/kubelet.service.d# vim 10-kubeadm.conf
    ## #Add Environment="KUBELET_EXTRA_ARGS=--node-ip=192.168.205.10"
    ## root@k8s-master-1.16-rework:/etc/systemd/system/kubelet.service.d# systemctl daemon-reload
    ## root@k8s-master-1.16-rework:/etc/systemd/system/kubelet.service.d# systemctl restart kubelet
    ## root@k8s-master-1.16-rework:/etc/systemd/system/kubelet.service.d#
    ## Node 2
    ## ## #Add Environment="KUBELET_EXTRA_ARGS=--node-ip=192.168.205.11"
    ## Node 3
    ## ## #Add Environment="KUBELET_EXTRA_ARGS=--node-ip=192.168.205.12"
    ## Node 4
    ## ## #Add Environment="KUBELET_EXTRA_ARGS=--node-ip=192.168.205.13"
    ## That is handled automatically below

    # ip of this box
    # https://askubuntu.com/questions/792670/ifconfig-does-not-display-network-interfaces-on-ubuntu-16-04-on-virtualbox
    IP_ADDR=`ifconfig enp0s8 | grep netmask | awk '{print $2}'`
    # set node-ip
    # sudo sed -i "/^[^#]*KUBELET_EXTRA_ARGS=/c\KUBELET_EXTRA_ARGS=--node-ip=$IP_ADDR" /etc/default/kubelet
    ## https://stackoverflow.com/questions/11694980/using-sed-insert-a-line-above-or-below-the-pattern/11695098#11695098
    ## https://stackoverflow.com/questions/11694980/using-sed-insert-a-line-above-or-below-the-pattern
    sed -i "/EnvironmentFile=-\/etc\/default\/kubelet/i Environment=\"KUBELET_EXTRA_ARGS=--node-ip=$IP_ADDR\"" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
    systemctl daemon-reload
    systemctl restart kubelet
    echo "##########"
    sudo systemctl enable kubelet.service
    echo "##########"
    sudo systemctl enable docker.service
    echo "##########"
    sudo systemctl restart kubelet
    echo "##########"
    sudo systemctl status kubelet.service
    echo "##########"
    sudo systemctl status docker.service
    echo "##########"

    # Below lines will configure shell autocompletion for Kubernetes commands and ressources
    sudo apt-get install bash-completion
    echo "source <(kubectl completion bash)>" >> ~/.bashrc
    source ~/.bashrc