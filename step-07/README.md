Upgrade servers from 9.4 to 9.6
================

Upgrading from one version of Postgres to another at the best of times can be tricky. But a correctly configured playbook can make even this a straightforward proposition:

	ansible-playbook -i step-07/hosts.cfg 07.pg1_upgrade_94-96.yml

In this example, we upgrade **pg1**, which was shut down in our failover example, by executing the following steps:

* Install the Postgres ver 9.6, binaries onto our three hosts
* Shut down the 9.4 service and disable the binaries from starting upon server restart
* Enable the 9.6 binaries in case the machine is required to restart
* Create an empty data cluster for the upgraded version of Postgres; optionally remove any previously existing one
* Execute upgrade process using the **pg\_upgrade** utility; notice the use of two different port numbers
* Update the version 9.6 data cluster with an updated set of configuration, i.e. **postgresql.conf**, **server.conf**, and **pg\_hba.conf**
* Update runtime environment variables when logging into the Unix Postgres account for easier administration
* Start up our new Postgres version 9.6 service

Before upgrade:
```
[ansible@ansible ansible-PG-tuto]$ ansible -i step-02/hosts.cfg all -m shell -a "psql -c 'select version();'"  -u postgres
pg1 | FAILED | rc=2 >>
psql: could not connect to server: No such file or directory
	Is the server running locally and accepting
	connections on Unix domain socket "/tmp/.s.PGSQL.5432"?

pg3 | SUCCESS | rc=0 >>
                                                    version                                                     
----------------------------------------------------------------------------------------------------------------
 PostgreSQL 9.4.12 on x86_64-unknown-linux-gnu, compiled by gcc (GCC) 4.4.7 20120313 (Red Hat 4.4.7-18), 64-bit
(1 row)

pg2 | SUCCESS | rc=0 >>
                                                    version                                                     
----------------------------------------------------------------------------------------------------------------
 PostgreSQL 9.4.12 on x86_64-unknown-linux-gnu, compiled by gcc (GCC) 4.4.7 20120313 (Red Hat 4.4.7-18), 64-bit
(1 row)

```

Note: As there's more than one way to skin a cat, so too are there many ways of writing this playbook; it's up to you.

```
---
- hosts: all
  remote_user: ansible
  become: yes
 
  tasks:
    - name: install repo for PostgreSQL 9.6
      yum:
        name: https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-6-x86_64/pgdg-centos96-9.6-3.noarch.rpm
        state: present
 
    - name: install PostgreSQL version 9.6
      yum:
        name: "{{ item }}"
        state: latest
      with_items:
        - postgresql96-server
        - postgresql96-contrib
        - pg_repack96
 
    - name: disable init for 9.4
      shell: chkconfig --level 2345 postgresql-9.4 off
 
    - name: enable init for 9.6
      shell: chkconfig --level 2345 postgresql-9.6 on
 
- hosts: pg1
  remote_user: ansible
  become: yes
 
  tasks:
    - service:
        name: postgresql-9.6
        state: stopped
 
    - file:
        path: /var/lib/pgsql/9.6/data/
        state: absent
 
    - name: create data cluster
      command: service postgresql-9.6 initdb
 
- hosts: pg1
  remote_user: postgres
 
  tasks:
    - name: execute the upgrade from 9.4 to 9.6
      shell: |
        /usr/pgsql-9.6/bin/pg_upgrade \
          -d /var/lib/pgsql/9.4/data \
          -D /var/lib/pgsql/9.6/data \
          -b /usr/pgsql-9.4/bin \
          -B /usr/pgsql-9.6/bin \
          -p 10094 \
          -P 5432
 
        exit 0
 
    - name: add new configuration to "postgresql.conf"
      blockinfile:
        dest: /var/lib/pgsql/9.6/data/postgresql.conf
        block: |
          include 'server.conf'
 
    - name: add new configuration to "server.conf"
      blockinfile:
        create: yes
        dest: /var/lib/pgsql/9.6/data/server.conf
        block: |
          listen_addresses = '*'
          wal_level = hot_standby
          max_wal_senders = 6
          wal_keep_segments = 10
          hot_standby = on
 
    - name: add new configuration to "pg_hba.conf"
      blockinfile:
        dest: /var/lib/pgsql/9.6/data/pg_hba.conf
        block: |
          host    all             all             0.0.0.0/0                md5
          host    replication     replicant       0.0.0.0/0                md5
 
    - name: update environment variables in UNIX account postgres
      blockinfile:
        create: yes
        dest: /var/lib/pgsql/.pgsql_profile
        block: |
          export PGHOST=/tmp PAGER=less PGDATA=/var/lib/pgsql/9.6/data
 
- hosts: pg1
  remote_user: ansible
  become: yes
 
  tasks:
    - service:
        name: postgresql-9.6
        state: started
...

```
After upgrade
```
[ansible@ansible ansible-PG-tuto]$ ansible -i step-02/hosts.cfg all -m shell -a "psql -c 'select version();'"  -u postgres
pg2 | FAILED | rc=2 >>
psql: could not connect to server: No such file or directory
	Is the server running locally and accepting
	connections on Unix domain socket "/var/run/postgresql/.s.PGSQL.5432"?

pg1 | SUCCESS | rc=0 >>
                                                 version                                                  
----------------------------------------------------------------------------------------------------------
 PostgreSQL 9.6.3 on x86_64-pc-linux-gnu, compiled by gcc (GCC) 4.4.7 20120313 (Red Hat 4.4.7-18), 64-bit
(1 row)

pg3 | FAILED | rc=2 >>
psql: could not connect to server: No such file or directory
	Is the server running locally and accepting
	connections on Unix domain socket "/var/run/postgresql/.s.PGSQL.5432"?
```



Now head to next step in directory [step-08](https://github.com/4orbit/ansible-PG-tuto/tree/master/step-08).
