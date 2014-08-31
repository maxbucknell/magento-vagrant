# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "chef/centos-6.5"

  config.vm.network "private_network", ip: "10.3.118.121"

  # Use host SSH key for authentication to Github, etc.
  config.ssh.forward_agent = true

  config.vm.provision "shell",
    path: "shell_provision.sh"

  config.vm.provision "puppet" do |puppet|
    puppet.manifest_file = "base.pp"
  end

  config.vm.provision "puppet" do |puppet|
    puppet.manifest_file = "redbox.pp"
  end
end
