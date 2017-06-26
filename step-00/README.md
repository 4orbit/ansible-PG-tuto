How to administrate a cluster of database servers on a developer workstation
================

As root, I create my template container:

	lxc-create -t download -n template_centos6 -- --dist centos --release 6 --arch amd64

Let's start the container, adding the following packages:

	lxc-start -n template_centos6
 
	lxc-attach -n template_centos6 -- <<_eof_
		yum update -y
		yum install openssh-server screen mlocate man vim-enhanced python-psycopg2 git sudo -y
		/usr/sbin/makewhatis
		/usr/bin/updatedb
		useradd ansible
		echo ansible | passwd --stdin ansible
		echo -e '\n\n# ANSIBLE GLOBAL PERMISSIONS FOR DEMO PURPOSES ONLY\nansible ALL=(ALL) PASSWD:ALL' >> /etc/sudoers
	_eof_

Now we're ready to make our actual containers:

	lxc-stop -n template_centos6
 
	for u in ansible pg1 pg2 pg3
	do
		lxc-copy -n template_centos6 -N $u
	done

Let's prepare container *Ansible*:
	lxc-start -n ansible
	lxc-attach -n ansible <<_eof_
		rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
		yum install ansible -y
		/usr/sbin/makewhatis
		/usr/bin/updatedb
		su -c "ssh-keygen -t rsa -N '' -f /home/ansible/.ssh/id_rsa" ansible
	_eof_

Let's turn everything on:

	for u in $(seq 3)
	do
		lxc-start -n pg$u
	done

And see what our environment looks like:

	root@zhuhavlev:~# lxc-ls -f
	NAME             STATE   AUTOSTART GROUPS IPV4       IPV6 
	ansible          RUNNING 0         -      10.0.3.160 -    
	pg1              RUNNING 0         -      10.0.3.74  -    
	pg2              RUNNING 0         -      10.0.3.105 -    
	pg3              RUNNING 0         -      10.0.3.184 -    
	template_centos6 STOPPED 0         -      -          -   

# Configuring our Ansible container

Now let's get to work and create our playbooks on *guest* host *Ansible*. Ansible uses a special configuration file that defines all those hosts we'd like to administrate:


## Cloning the tutorial

	git clone https://github.com/4orbit/ansible-PG-tuto.git
	cd ansible-PG-tuto

	[ansible@ansible ansible-PG-tuto]$ cat step-00/hosts.cfg 
	[dbservers]
	pg1 ansible_ssh_pass=ansible ansible_sudo_pass=ansible
	pg2 ansible_ssh_pass=ansible ansible_sudo_pass=ansible
	pg3 ansible_ssh_pass=ansible ansible_sudo_pass=ansible

## Ping pg servers




