Configure londiste replication
================

Let's create another server pg4. Let it be a copy of the already created pg1.

	lxc-stop -n pg1 && lxc-copy -n pg1 -N pg4 && lxc-start -n pg1 ; lxc-start -n pg4

Suppose that in our example, server pg4 has a database l3simple\_db1, from which we will replicate several tables (pgbench\*) into the l3simple\_db2 database at server pg1.
See file step-04l-1/hosts.cfg -- added server pg4.


``` yaml
---
- hosts: "{{ host }}"
  remote_user: ansible
  become: yes
 
  tasks:
    - name: install PostgreSQL version 9.6
      yum:
        name: "{{ item }}"
        state: latest
      with_items:
        - postgresql96-server
        - postgresql96-contrib
        - pg_repack96
        - skytools-96
        - skytools-94-modules
...
```
Note: Although not discussed, pg\_repack96 removes database bloat, so I invite you to take time to read up on it.

Packages skytools-96\* will be needed to demonstrate logical replication with londiste.

Now head to next step in directory [step-03](https://github.com/4orbit/ansible-PG-tuto/tree/master/step-03).
