Add repos: PostgreSQL Versions 9.4 and 9.6
================

Playbook **01.install\_repo.yml** installs the **postgres.org** repository onto each **guest** host. Notice we're going to install two versions of Postgres—versions 9.4 and 9.6—which makes it possible to perform an inline upgrade:

	ansible-playbook -i step-01/hosts.cfg 01.install_repo.yml

``` ansible
---
- hosts: dbservers
  remote_user: ansible
  become: yes
 
  tasks:
    - name: install repo for PostgreSQL 9.4
      yum:
        name: https://download.postgresql.org/pub/repos/yum/9.4/redhat/rhel-6-x86_64/pgdg-centos94-9.4-3.noarch.rpm
        state: present
 
    - name: install repo for PostgreSQL 9.6
      yum:
        name: https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-6-x86_64/pgdg-centos96-9.6-3.noarch.rpm
        state: present
...
```

Now head to next step in directory [step-02](https://github.com/4orbit/ansible-PG-tuto/tree/master/step-02).
