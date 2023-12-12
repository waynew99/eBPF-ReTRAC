# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
	config.vm.define "client" do |a|
		a.vm.box = "generic/ubuntu2004"
		a.vm.hostname = 'client'
		a.vm.network "forwarded_port", guest: 22, host: 22221, id: 'ssh'
		a.ssh.insert_key = true
		a.vm.network "private_network", :ip => "10.0.1.1"
		a.vm.network "private_network", :ip => "10.10.10.10"
		a.vm.provider :libvirt do |v|
			v.driver = "kvm"
			v.memory = 2048
			v.cpus = 2
  	end
    a.vm.provision :shell, path: "./machines/client/setup_net.sh"
    a.vm.synced_folder  "./machines/client/", "/vagrant", disabled: false
  end

	config.vm.define "gateway" do |a|
		a.vm.box = "generic/ubuntu2004"
		a.vm.hostname = 'gateway'
		a.vm.network "forwarded_port", guest: 22, host: 22222, id: 'ssh'
		a.ssh.insert_key = true
		a.vm.network "private_network", :ip => "10.0.1.2"
		a.vm.network "private_network", :ip => "10.0.2.2"
		a.vm.network "private_network", :ip => "10.0.3.2"
		a.vm.provider :libvirt do |v|
			v.driver = "kvm"
			v.memory = 2048
			v.cpus = 2
		end
		a.vm.provision :shell, path: "./machines/gateway/setup_net.sh"
		a.vm.synced_folder  "./machines/gateway/", "/vagrant", disabled: false
	end

	config.vm.define "free" do |a|
		a.vm.box = "generic/ubuntu2004"
		a.vm.hostname = 'free'
		a.vm.network "forwarded_port", guest: 22, host: 22223, id: 'ssh'
		a.ssh.insert_key = true
		a.vm.network "private_network", :ip => "10.0.2.3"
		a.vm.network "private_network", :ip => "10.0.4.3"
		a.vm.provider :libvirt do |v|
			v.driver = "kvm"
			v.memory = 2048
			v.cpus = 2
		end
		a.vm.provision :shell, path: "./machines/free/setup_net.sh"
		a.vm.synced_folder  "./machines/free/", "/vagrant", disabled: false
	end

	config.vm.define "censored" do |a|
		a.vm.box = "generic/ubuntu2004"
		a.vm.hostname = 'censored'
		a.vm.network "forwarded_port", guest: 22, host: 22224, id: 'ssh'
		a.ssh.insert_key = true
		a.vm.network "private_network", :ip => "10.0.3.4"
		a.vm.provider :libvirt do |v|
			v.driver = "kvm"
			v.memory = 2048
			v.cpus = 2
		end
		a.vm.provision :shell, path: "./machines/censored/setup_net.sh"
		a.vm.synced_folder  "./machines/censored/", "/vagrant", disabled: false
	end

	config.vm.define "webserver" do |a|
		a.vm.box = "generic/ubuntu2004"
		a.vm.hostname = 'webserver'
		a.vm.network "forwarded_port", guest: 22, host: 22225, id: 'ssh'
		a.ssh.insert_key = true
		a.vm.network "private_network", :ip => "10.0.4.5"
		a.vm.provider :libvirt do |v|
			v.driver = "kvm"
			v.memory = 2048
			v.cpus = 2
		end
		a.vm.provision :shell, path: "./machines/webserver/setup_net.sh"
		a.vm.synced_folder  "./machines/webserver/", "/vagrant", disabled: false
	end
end
