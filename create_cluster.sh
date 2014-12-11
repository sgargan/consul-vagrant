#/bin/bash
#
# consul-vagrant
#
# Spins up 3 vagrant vms and configures a  consul cluster cluster on them using Ansible
# Installs a consul agent on the local machine and configures it to talk to cluster.
#
echo "Creating Consul cluster..."

if [[ ! -e roles/sgargan.consul ]]; then
  echo "Grab roles from github"
  mkdir -p roles
  ansible-galaxy install -p roles sgargan.supervisor
  ansible-galaxy install -p roles sgargan.consul

  echo "Generating crypto artifacts for cluster security"
  ./roles/sgargan.consul/files/certs.sh
fi

echo "Starting Consul Server Vms"
vagrant up --provider virtualbox

echo "Configuring Consul cluster"
ansible-playbook -i consul_hosts consul.yml -e local_agent_dir=$HOME/consul_agent

echo "Starting the local Consul agent"
~/consul_agent/bin/consul agent -config-dir=/Users/sgargan/consul_agent/conf.d
