Upgrade servers from 9.6 to 10
================

Upgrading from one version of Postgres to another at the best of times can be tricky. But a correctly configured playbook can make even this a straightforward proposition:

	ansible-playbook -i step-07/hosts.cfg 07.pg1_upgrade_96-10.yml

In this example, we upgrade **pg1**, which was shut down in our failover example, by executing the following steps:

* Install the Postgres ver 10, binaries onto our three hosts
* Shut down the 9.6 service and disable the binaries from starting upon server restart
* Enable the 10 binaries in case the machine is required to restart
* Create an empty data cluster for the upgraded version of Postgres; optionally remove any previously existing one
* Execute upgrade process using the **pg\_upgrade** utility; notice the use of two different port numbers
* Update the version 10 data cluster with an updated set of configuration, i.e. **postgresql.conf**, **server.conf**, and **pg\_hba.conf**
* Update runtime environment variables when logging into the Unix Postgres account for easier administration
* Start up our new Postgres version 10 service

Before upgrade:
```bash
[ansible@ansible ansible-PG-tuto]$ ansible -i step-02/hosts.cfg all -m shell -a "psql -c 'select version();'"  -u postgres
pg1 | FAILED | rc=2 >>
psql: could not connect to server: No such file or directory
	Is the server running locally and accepting
	connections on Unix domain socket "/tmp/.s.PGSQL.5432"?

pg3 | SUCCESS | rc=0 >>
                                                    version                                                     
----------------------------------------------------------------------------------------------------------------
 PostgreSQL 9.6.12 on x86_64-unknown-linux-gnu, compiled by gcc (GCC) 4.4.7 20120313 (Red Hat 4.4.7-18), 64-bit
(1 row)

pg2 | SUCCESS | rc=0 >>
                                                    version                                                     
----------------------------------------------------------------------------------------------------------------
 PostgreSQL 9.6.12 on x86_64-unknown-linux-gnu, compiled by gcc (GCC) 4.4.7 20120313 (Red Hat 4.4.7-18), 64-bit
(1 row)

```

Note: As there's more than one way to skin a cat, so too are there many ways of writing this playbook; it's up to you.

```yanl
---
- hosts: all
  remote_user: ansible
  become: yes
 
  tasks:
    - name: install repo for PostgreSQL 10
      yum:
        name: https://download.postgresql.org/pub/repos/yum/testing/10/redhat/rhel-7-x86_64/pgdg-centos10-10-1.noarch.rpm
        state: present
 
    - name: install PostgreSQL version 10
      yum:
        name: "{{ item }}"
        state: latest
      with_items:
        - postgresql10-server
        - postgresql10-contrib
        - pg_repack10
 
    - name: disable init for 9.6
      systemd:
        name: postgresql-9.6
        state: stop
        enabled: False
 
    - name: enable init for 10
      systemd: 
        name: postgresql-10
        state: start
        enabled: True
 
- hosts: pg1
  remote_user: ansible
  become: yes
 
  tasks:
    - name: stop PG 10
      systemd: 
        name: postgresql-10
        state: stop
 
    - file:
        path: /var/lib/pgsql/10/data/
        state: absent
 
    - name: create data cluster
      command: service postgresql-10 initdb
 
- hosts: pg1
  remote_user: postgres
 
  tasks:
    - name: execute the upgrade from 9.6 to 10
      shell: |
        /usr/pgsql-10/bin/pg_upgrade \
          -d /var/lib/pgsql/9.6/data \
          -D /var/lib/pgsql/10/data \
          -b /usr/pgsql-9.6/bin \
          -B /usr/pgsql-10/bin \
          -p 10094 \
          -P 5432
 
        exit 0
 
    - name: add new configuration to "postgresql.conf"
      blockinfile:
        dest: /var/lib/pgsql/10/data/postgresql.conf
        block: |
          include 'server.conf'
 
    - name: add new configuration to "server.conf"
      blockinfile:
        create: yes
        dest: /var/lib/pgsql/10/data/server.conf
        block: |
          listen_addresses = '*'
          wal_level = hot_standby
          max_wal_senders = 6
          max_wal_size = 480
          hot_standby = on
 
    - name: add new configuration to "pg_hba.conf"
      blockinfile:
        dest: /var/lib/pgsql/10/data/pg_hba.conf
        block: |
          host    all             all             0.0.0.0/0                md5
          host    replication     replicant       0.0.0.0/0                md5
 
    - name: update environment variables in UNIX account postgres
      blockinfile:
        create: yes
        dest: /var/lib/pgsql/.pgsql_profile
        block: |
          export PGHOST=/tmp PAGER=less PGDATA=/var/lib/pgsql/10/data
 
- hosts: pg1
  remote_user: ansible
  become: yes
 
  tasks:
    - name: start PG 10
      systemd: 
        name: postgresql-10
        state: start
...

```
After upgrade
```bash
[ansible@ansible ansible-PG-tuto]$ ansible -i step-02/hosts.cfg all -m shell -a "psql -c 'select version();'"  -u postgres
pg2 | FAILED | rc=2 >>
psql: could not connect to server: No such file or directory
	Is the server running locally and accepting
	connections on Unix domain socket "/var/run/postgresql/.s.PGSQL.5432"?

pg1 | SUCCESS | rc=0 >>
                                                 version                                                  
----------------------------------------------------------------------------------------------------------
 PostgreSQL 10.3 on x86_64-pc-linux-gnu, compiled by gcc (GCC) 4.4.7 20120313 (Red Hat 4.4.7-18), 64-bit
(1 row)

pg3 | FAILED | rc=2 >>
psql: could not connect to server: No such file or directory
	Is the server running locally and accepting
	connections on Unix domain socket "/var/run/postgresql/.s.PGSQL.5432"?
```



Now head to next step in directory [step-08](https://github.com/4orbit/ansible-PG-tuto/tree/master/step-08).
