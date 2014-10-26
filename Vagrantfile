Vagrant.configure("2") do |config|

  config.vm.box = "vagrantcloud-ubuntu-trusty-64"
  config.vm.box_url = "http://vagrantcloud.com/ubuntu/boxes/trusty64/versions/1/providers/virtualbox.box"

  config.vm.provider "virtualbox" do |vm|
    vm.memory = 1024
    vm.cpus = 1
  end

  (1..3).each do |i|
    config.vm.define "consul-#{i}" do |node|
      node.vm.network :private_network, ip: "11.0.0.#{i + 1}"
      if i == 3
        node.vm.provision :ansible do |ansible|
          ansible.playbook = "none.yml"
          ansible.groups = {
            "consul_servers" => ["consul-1", "consul-2", "consul-3"]
          }
        end
      end
    end
  end

end
