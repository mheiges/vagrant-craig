Vagrant.configure(2) do |config|

  config.vm.box_url = 'http://software.apidb.org/vagrant/centos-7-64-puppet.json'
  config.vm.box = "ebrc/centos-7-64-puppet"

  config.vm.provider "virtualbox" do |v|
    v.memory = 8192
    v.cpus = 2
    v.customize ["modifyvm", :id, "--ioapic", "on"]
  end

  config.ssh.forward_agent = 'true'

  config.vm.provision "shell", path: "provision.sh"

end
