How to administrate a cluster of database servers on a developer workstation
================

As root, I create my template container:

	lxc-create -t download -n template_centos6 -- --dist centos --release 6 --arch amd64

Let's start the container, adding the following packages:

	lxc-start -n template_centos6
 
    lxc-attach -n template_centos6 -- <<_eof_
        yum update -y
        yum install openssh-server screen mlocate man vim python-psycopg2 sudo -y
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


# Install lxc


