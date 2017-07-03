How to administrate a cluster of database servers on a developer workstation
================

As root, I create my template container:

	lxc-create -t download -n template_centos7 -- --dist centos --release 7 --arch amd64

Let's start the container, adding the following packages:

```bash
lxc-start -n template_centos7

lxc-attach -n template_centos7 -- <<_eof_
	yum update -y
	yum install openssh-server screen mlocate man vim-enhanced python-psycopg2 git sudo -y
	/usr/bin/updatedb
	useradd ansible
	echo ansible | passwd --stdin ansible
	echo -e '\n\n# ANSIBLE GLOBAL PERMISSIONS FOR DEMO PURPOSES ONLY\nansible ALL=(ALL) PASSWD:ALL' >> /etc/sudoers
_eof_
```

Now we're ready to make our actual containers:

```bash
lxc-stop -n template_centos7

for u in ansible pg1 pg2 pg3
do
	lxc-copy -n template_centos7 -N $u
done
```

Let's turn everything on:

PG servers^
```bash
for u in $(seq 3)
do
	lxc-start -n pg$u
done
```
and ansible:

   lxc-start -n ansible

And see what our environment looks like:

```bash
root@zhuhavlev:~# lxc-ls -f
NAME             STATE   AUTOSTART GROUPS IPV4       IPV6 
ansible          RUNNING 0         -      10.0.3.160 -    
pg1              RUNNING 0         -      10.0.3.74  -    
pg2              RUNNING 0         -      10.0.3.105 -    
pg3              RUNNING 0         -      10.0.3.184 -    
template_centos7 STOPPED 0         -      -          -   
```

Let's prepare container *Ansible*:

```bash
lxc-attach -n ansible <<_eof_
	rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
	yum install ansible -y
	/usr/bin/updatedb
	su -c "ssh-keygen -t rsa -N '' -f /home/ansible/.ssh/id_rsa" ansible
_eof_
```

# Configuring our Ansible container

Now let's get to work and create our playbooks on *guest* host *Ansible*. Ansible uses a special configuration file that defines all those hosts we'd like to administrate:


## Cloning the tutorial

```bash
lxc-attach -n ansible
su - ansible

git clone https://github.com/4orbit/ansible-PG-tuto.git
cd ansible-PG-tuto

[ansible@ansible ansible-PG-tuto]$ cat step-00/hosts.cfg 
[dbservers]
pg1 ansible_ssh_pass=ansible ansible_sudo_pass=ansible
pg2 ansible_ssh_pass=ansible ansible_sudo_pass=ansible
pg3 ansible_ssh_pass=ansible ansible_sudo_pass=ansible
```

## Ping pg servers


	ansible -i step-00/hosts.cfg -m ping all


If not whant add accept all ssh key manyaly. Run command like this:
	
	ANSIBLE_HOST_KEY_CHECKING=false ansible -i step-00/hosts.cfg -m ping all


Here's the output:

```bash
pg2 | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
pg3 | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
pg1 | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
```

# If ssh to slow

Аdd string at ent of **/etc/ssh/sshd\_conf** on pgX servers

	UseDNS no

and set 

	GSSAPIAuthentication no
	#	GSSAPIAuthentication yes

Add string at end of **/etc/ssh/ssh\_conf** on ansible server

	AddressFamily inet

Now head to next step in directory [step-01](https://github.com/4orbit/ansible-PG-tuto/tree/master/step-01).
