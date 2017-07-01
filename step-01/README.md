Add repos: PostgreSQL Versions 9.6 and 10
================

Playbook **01.install\_repo.yml** installs the **postgres.org** repository onto each **guest** host. Notice we're going to install two versions of Postgres—versions 9.6 and 10—which makes it possible to perform an inline upgrade:

	ansible-playbook -i step-01/hosts.cfg 01.install_repo.yml

``` yaml
---
- hosts: dbservers
  remote_user: ansible
  become: yes
 
  tasks:
    - name: install repo for PostgreSQL 9.6
      yum:
        name: https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm
        state: present
 
    - name: install repo for PostgreSQL 10
      yum:
        name: https://download.postgresql.org/pub/repos/yum/testing/10/redhat/rhel-7-x86_64/pgdg-centos10-10-1.noarch.rpm
        state: present
...
```

Now head to next step in directory [step-02](https://github.com/4orbit/ansible-PG-tuto/tree/master/step-02).
