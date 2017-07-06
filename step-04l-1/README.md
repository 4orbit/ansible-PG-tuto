Configure londiste replication
================

Let's create another server pg4. Let it be a copy of the already created pg1.

	lxc-stop -n pg1 && lxc-copy -n pg1 -N pg4 && lxc-start -n pg1 ; lxc-start -n pg4

Suppose that in our example, server pg4 has a database l3simple\_db1, from which we will replicate several tables (pgbench\*) into the l3simple\_db2 database at server pg1.
See file step-04l-1/hosts.cfg -- added server pg4. Test it with:

        ansible -i step-04l-1/hosts.cfg -m ping all

Then taste londiste with follow steps:
* install skytools packages -- we do it at step 02
* create databases l3simple\_db1 on pg4, l3simple\_db2 on pg1

```yaml
ansible -i step-04l-1/hosts.cfg pg4 -m shell -a "psql -c 'CREATE DATABASE l3simple_db1;'" --become --become-user postgres
ansible -i step-04l-1/hosts.cfg pg1 -m shell -a "psql -c 'CREATE DATABASE l3simple_db2;'" --become --become-user postgres

```


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


Now head to next step in directory [step-04l-2](https://github.com/4orbit/ansible-PG-tuto/tree/master/step-04l-2).
