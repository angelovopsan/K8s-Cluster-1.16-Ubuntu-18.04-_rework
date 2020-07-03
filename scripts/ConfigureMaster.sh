#!/bin/bash
    echo "This is master"
    IP_ADDR=`ifconfig enp0s8 | grep netmask | awk '{print $2}'`
    # install k8s master
    HOST_NAME=$(hostname -s)
    kubeadm init --apiserver-advertise-address=$IP_ADDR --apiserver-cert-extra-sans=$IP_ADDR --node-name $HOST_NAME --pod-network-cidr=172.16.0.0/16
    #copying credentials to regular user - vagrant
    sudo --user=vagrant mkdir -p /home/vagrant/.kube
    cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
    chown $(id -u vagrant):$(id -g vagrant) /home/vagrant/.kube/config
    # install Calico pod network addon
    export KUBECONFIG=/etc/kubernetes/admin.conf
    curl -s https://docs.projectcalico.org/manifests/calico.yaml -O
    kubectl apply -f calico.yaml
    kubeadm token create --print-join-command >> /etc/kubeadm_join_cmd.sh
    chmod +x /etc/kubeadm_join_cmd.sh
    sed -i "/^[^#]*PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
    service sshd restart