# -*- mode: ruby -*-
# vi: set ft=ruby :

servers = [
    {
        :name => "k8s-master-1.16-rework",
        :type => "master",
        :box => "ubuntu/bionic64",
        :box_version => "20190411.0.0",
        :eth1 => "192.168.223.10",
        :mem => "2048",
        :cpu => "2"
    },
    {
        :name => "k8s-node1-1.16-rework",
        :type => "node",
        :box => "ubuntu/bionic64",
        :box_version => "20190411.0.0",
        :eth1 => "192.168.223.11",
        :mem => "1700",
        :cpu => "2"
    },
    {
        :name => "k8s-node2-1.16-rework",
        :type => "node",
        :box => "ubuntu/bionic64",
        :box_version => "20190411.0.0",
        :eth1 => "192.168.223.12",
        :mem => "1700",
        :cpu => "2"
    },
    {
      :name => "k8s-node3-1.16-rework",
      :type => "node",
      :box => "ubuntu/bionic64",
      :box_version => "20190411.0.0",
      :eth1 => "192.168.223.13",
      :mem => "1700",
      :cpu => "2"
  }
]

Vagrant.configure("2") do |config|

  servers.each do |opts|
    config.vm.define opts[:name] do |config|

      config.vm.box = opts[:box]
      config.vm.box_version = opts[:box_version]
      config.vm.hostname = opts[:name]
      config.vm.network :private_network, ip: opts[:eth1]

      config.vm.provider "virtualbox" do |v|

        v.name = opts[:name]
        v.customize ["modifyvm", :id, "--groups", "/KubernetesCluster-1.16-rework"]
        v.customize ["modifyvm", :id, "--memory", opts[:mem]]
        v.customize ["modifyvm", :id, "--cpus", opts[:cpu]]
      end
  
      config.vm.provision "shell", path: "./scripts/configureBox.sh"
      if opts[:type] == "master"
        config.vm.provision "shell", path: "./scripts/configureMaster.sh"
        config.vm.provision "helm_install", type: "shell", path: "./scripts/installHelm.sh"
        config.vm.provision "istio_install", type: "shell", run: "never", path: "./scripts/installIstio.sh"
        config.vm.provision "bookinfo_install", type: "shell", run: "never", path: "./scripts/installBookinfo.sh"
      else
        config.vm.provision "shell", path: "./scripts/configureNode.sh"
      end
    end
  end
end

# Run instructions:
# vagrant up
# vagrant up --provision-with "istio_install"
# vagrant up --provision-with "bookinfo_install"