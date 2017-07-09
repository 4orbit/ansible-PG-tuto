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
* instrt data into database l3simple\_db1 and applay sql script for create indexes and etc.
* populate target database l3simple\_db2
* create configuration file for londiste on eatch server and for pgqd on pg4


```bash
ansible -i step-04l-1/hosts.cfg pg4 -m shell -a "psql -c 'CREATE DATABASE l3simple_db1;'" --become --become-user postgres
ansible -i step-04l-1/hosts.cfg pg1 -m shell -a "psql -c 'CREATE DATABASE l3simple_db2;'" --become --become-user postgres
ansible -i step-04l-1/hosts.cfg pg4 -m shell -a "/usr/pgsql-9.6/bin/pgbench -i -s 2 -F 80 l3simple_db1" --become --become-user postgres
ansible -i step-04l-1/hosts.cfg pg4 -m copy -a "src=step-04l-1/prepare_pgbenchdb_for_londiste.sql dest=~" --become --become-user postgres
ansible -i step-04l-1/hosts.cfg pg4 -m shell -a "psql l3simple_db1 -f prepare_pgbenchdb_for_londiste.sql" --become --become-user postgres
ssh postgres@pg4 "pg_dump -s -t pgbench* l3simple_db1" | ssh postgres@pg1 "psql l3simple_db2"

```
Let's create the files needed for setup londiste.

```bash
ansible-playbook -i step-04l-1/hosts.cfg 04l-1.configure_londiste.yml --extra-vars "host=st3-replication"

```

and manualy add string to pg\_hba.conf

```bash
host    all             postgres             127.0.0.1/32            trust
host    all             postgres             10.0.1.0/24            trust

```
and PG need reload ater this

manual command on master

```bash
st3simple/st3_l3simple_primary.ini create-root node1 "user=postgres host=pg4 dbname=l3simple_db1"
londiste3 -d st3simple/st3_l3simple_primary.ini worker

```

on standby

```bash
londiste3 st3simple/st3_l3simple_leaf.ini create-leaf node2 dbname=l3simple_db2 --provider="dbname=l3simple_db1 user=postgres host=pg4"
londiste3 -d st3simple/st3_l3simple_leaf.ini worker
```
Launch ticker daemon: (on master node1)

```bash
pgqd -d st3simple/pgqd.ini
```
Run command :
```bash
londiste3 st3simple/st3_l3simple_primary.ini add-table pgbench_*
londiste3 st3simple/st3_l3simple_leaf.ini add-table pgbench_*
```

After add data and check replica working

```bash
pgbench -T 40 -c 5 l3simple_db1

londiste3 st3simple/st3_l3simple_primary.ini compare
londiste3 st3simple/st3_l3simple_leaf.ini compare

londiste3 st3simple/st3_l3simple_leaf.ini status

londiste3 st3simple/st3_l3simple_leaf.ini status

```



``` yaml
---
- hosts: "{{ host }}"
  remote_user: postgres

  tasks:
    - name: crate dir for st3simple config files
      file: path=~/st3simple/{{item}} state=directory mode=0755
      with_items:
        - "log"
        - "pid"

- hosts: st3-master
  remote_user: postgres

  tasks:
    - name: add new configuration to "st3simple/pgqd.ini"
      blockinfile:
        create: yes
        dest: ~/st3simple/pgqd.ini
        block: |
            [pgqd]
            logfile = st3simple/log/pgqd.log
            pidfile = st3simple/pid/pgqd.pid

    - name: add new configuration to "st3simple/st3_l3simple_primary.ini"
      blockinfile:
        create: yes
        dest: ~/st3simple/st3_l3simple_primary.ini
        block: |
            [londiste3]
            job_name = st3_l3simple_db1
            db = dbname=l3simple_db1
            queue_name = replika
            logfile = st3simple/log/st3_l3simple_db1.log
            pidfile = st3simple/pid/st3_l3simple_db1.pid

- hosts: st3-standby
  remote_user: postgres

  tasks:
    - name: add new configuration to "st3simple/st3_l3simple_leaf.ini"
      blockinfile:
        create: yes
        dest: ~/st3simple/st3_l3simple_leaf.ini
        block: |
            [londiste3]
            job_name = st3_l3simple_db2
            db = dbname=l3simple_db2
            queue_name = replika
            logfile = st3simple/log/st3_l3simple_db2.log
            pidfile = st3simple/pid/st3_l3simple_db2.pid

...

```
Note: Although not discussed, pg\_repack96 removes database bloat, so I invite you to take time to read up on it.


Now head to next step in directory [step-04l-2](https://github.com/4orbit/ansible-PG-tuto/tree/master/step-04l-2).
