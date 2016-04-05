# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
vagrantfile_api_version = "2"

# load the vm_defs
require 'yaml'
vm_defs = YAML.load_file 'vagrant_defs.yml'

# need the absolute path to the actual vagrantfile in case of symlinks
script_dir = "#{__dir__}/scripts"

# create a script to allow access machines on local network via hostnames
hosts = vm_defs.map{ |vm| "#{vm[:ip]}  #{vm[:hostname]}" }.join("\n")
add_hosts_script = "echo -e '#{hosts}' >> /etc/hosts"

# make the vagrant machines
Vagrant.configure(vagrantfile_api_version) do |config|
  vm_defs.each do |vm_def|
    config.vm.define vm_def.fetch(:hostname).split('.').first, primary: (vm_def[:primary] || false) do |box|

      # specify the box to use and the hostname
      box.vm.box = vm_def[:box] || 'erumble/centos71-x64'
      box.vm.hostname = vm_def.fetch(:hostname)

      # set up a private network so we don't have to use port forwarding
      box.vm.network :private_network, ip: vm_def.fetch(:ip)

      # allocate memory if it is specified
      box.vm.provider 'virtualbox' do |v| 
        v.memory = vm_def[:memory] if vm_def[:memory]
        v.cpus = vm_def[:cpus] if vm_def[:cpus]
      end

      # explicitly set hostname, because reasons
      box.vm.provision :shell, inline: "hostnamectl set-hostname #{vm_def[:hostname]}" if box.vm.box == 'erumble/centos71-x64'

      # access machines on local network via hostnames
      box.vm.provision :shell, inline: add_hosts_script

      # setup the secure path and allow sudo access to forwarded ssh agent
      box.vm.provision 'shell', path: "#{script_dir}/sudoers.sh"

      # share some folders
      (vm_def[:shared_folders] || []).each do |folder_share|
        box.vm.synced_folder folder_share[:host_folder], folder_share[:guest_folder]
      end

      # allow guest os to use host os ssh keys
      box.ssh.forward_agent = true

      # run additional scripts
      (vm_def[:scripts] || []).each do |script|
        box.vm.provision 'shell', path: "#{script_dir}/#{script}"
      end

    end # config.vm.define
  end # vm_defs.each
end

