consul-vagrant
--------------

A vagrant project to configure a Consul cluster using Ansible.

Dependencies
------------

The vagrant box for the project is virtualbox image and so requires virtualbox to run.

Before running the vagrant file and provisioning with ansible, the ansible roles for consul and supervisor must be downloaded. To grab these from the galaxy repository issue the following

```bash
mkdir roles
ansible-galaxy install -p roles sgargan.supervisor
ansible-galaxy install -p roles sgargan.consul
```

Running
-------

Running vagrant will download an ubuntu 14.04 box, spin up three instances with virtualbox and create an ansible inventory containing these servers. Simplest way to do this is to run the script

```bash
./create_cluster.sh
```

To do each piece by hand you can run the following to bring up the VMs in vagrant

```bash
vagrant up --provider virtualbox
```

Then the cluster (3 servers and a local gaent) can then be provisioned with ansible as follows

```bash
ansible-playbook -i consul_hosts consul.yml
```

Once the provsioning is complete, the cluster can be tested as follows

```bash
ansible consul_servers -u vagrant -i consul_hosts -m command -a 'consul members'
```

This should output as follows

```bash
consul-2 | success | rc=0 >>
Node      Address            Status  Type    Build  Protocol
consul-2  11.0.0.3:8301      alive   server  0.4.1  2
consul-3  11.0.0.4:8301      alive   server  0.4.1  2
consul-1  11.0.0.2:8301      alive   server  0.4.1  2
sgargan   192.168.0.12:8301  alive   client  0.4.1  2

consul-3 | success | rc=0 >>
Node      Address            Status  Type    Build  Protocol
consul-3  11.0.0.4:8301      alive   server  0.4.1  2
consul-2  11.0.0.3:8301      alive   server  0.4.1  2
consul-1  11.0.0.2:8301      alive   server  0.4.1  2
sgargan   192.168.0.12:8301  alive   client  0.4.1  2

consul-1 | success | rc=0 >>
Node      Address            Status  Type    Build  Protocol
sgargan   192.168.0.12:8301  alive   client  0.4.1  2
consul-1  11.0.0.2:8301      alive   server  0.4.1  2
consul-3  11.0.0.4:8301      alive   server  0.4.1  2
consul-2  11.0.0.3:8301      alive   server  0.4.1  2

```

UI
--

Once deployed, the ui should be available from any of the servers http://11.0.0.2:8500/ui

Resetting the cluster.
----------------------

Server outages in a real Consul cluster are rare events and In the event of a server outage there is a strict protocol for bringing back up servers to avoid data loss.

http://www.consul.io/docs/guides/outage.html

If you restart your VMs you will find that the servers do not bootstrap themselves automatically. This process is manual and annoying in a local vagrant cluster this as you may be often bringing up and down the VMs. If your data is not important and you can afford to lose it you can run the following playbook to delete everything and bootstrap the cluster from scratch.

ansible-playbook -i consul_hosts reset.yml

Troubleshooting
---------------

Virtualbox networking, at least on OSX, can be flaky; if after you bring up your cluster you see networking errors or certificate errors with lots of flip flopping event messages your virtualbox network stack is usually the culprit. More often than not it requires a restart of your machine to rectify. When the cluster is working correctly your local agent log should look something like the following, if not try a reboot and a reset.

```bash
==> WARNING: It is highly recommended to set GOMAXPROCS higher than 1
==> Starting Consul agent...
==> Starting Consul agent RPC...
==> Joining cluster...
Join completed. Synced with 3 initial agents
==> Consul agent running!
Node name: 'sgargan'
Datacenter: 'dc1'
Server: false (bootstrap: false)
Client Addr: 0.0.0.0 (HTTP: 8500, DNS: 8600, RPC: 8400)
Cluster Addr: 192.168.0.12 (LAN: 8301, WAN: 8302)
Gossip encrypt: true, RPC-TLS: true, TLS-Incoming: true

==> Log data will now stream in as it occurs:

2014/12/11 12:42:31 [INFO] serf: EventMemberJoin: sgargan 192.168.0.12
2014/12/11 12:42:31 [WARN] serf: Failed to re-join any previously known node
2014/12/11 12:42:31 [INFO] agent: (LAN) joining: [11.0.0.2 11.0.0.3 11.0.0.4]
2014/12/11 12:42:31 [INFO] serf: EventMemberJoin: consul-1 11.0.0.2
2014/12/11 12:42:31 [INFO] serf: EventMemberJoin: consul-3 11.0.0.4
2014/12/11 12:42:31 [INFO] serf: EventMemberJoin: consul-2 11.0.0.3
2014/12/11 12:42:31 [INFO] consul: adding server consul-1 (Addr: 11.0.0.2:8300) (DC: dc1)
2014/12/11 12:42:31 [INFO] consul: adding server consul-3 (Addr: 11.0.0.4:8300) (DC: dc1)
2014/12/11 12:42:31 [INFO] consul: adding server consul-2 (Addr: 11.0.0.3:8300) (DC: dc1)
2014/12/11 12:42:31 [INFO] agent: (LAN) joined: 3 Err: <nil>
2014/12/11 12:42:31 [INFO] agent: Joining cluster...
2014/12/11 12:42:31 [INFO] agent: (LAN) joining: [11.0.0.2 11.0.0.3 11.0.0.4]
2014/12/11 12:42:31 [INFO] agent: (LAN) joined: 3 Err: <nil>
2014/12/11 12:42:31 [INFO] agent: Join completed. Synced with 3 initial agents
```
