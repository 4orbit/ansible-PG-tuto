Configure each host as a standalone service
================

All the pieces are now in place, and it's time to create our Postgres servers! I like building out my network incrementally; that way I save myself debugging grief if something goes wrong.

In addition to initializing the data cluster, we include the following steps in this playbook:
* Start the Postgres service
* Create role **replicant** with a password
* Update **pg\_hba.conf** allowing remote access
* Update **postgresql.conf** for master/slave service

Now I'm going to get a little fancy: In order to keep changes as clean and as clear as possible, I'm appending to the configuration file **postgresql.conf** with a single line describing an **include** file where we'll locate all our changes in a separate and distinct file, thus improving clarity. The Ansible keyword **blockinfile** is cool, as it adds text in a file identifying itself within a nice, big labeled block.

The connection permissions between master and slaves are updated in **pg\_hba.conf**. Keep in mind that truly secure environments always use SSL encryption between replicating servers, which we are not doing here.

And here's our invocation. Notice we've typed out the replication password as an argument; not only is it secure, but now we add flexibility to our script:

	ansible-playbook -i step-04/hosts.cfg 04.configure_standalone_96.yml --extra-vars "host=dbservers passwd=mypassword"

``` yaml
---
- hosts: "{{ host }}"
  remote_user: ansible
  become: yes
 
  tasks:
    - name: create data cluster
      command: /usr/pgsql-9.6/bin/postgresql96-setup initdb
      ignore_errors: True
      
 
    - name: start PG
      systemd:
        name: postgresql-9.6
        state: started
 
- hosts: "{{ host }}"
  remote_user: postgres
 
  tasks:
    - name: create ROLE replicant
      postgresql_user:
        db: postgres
        login_unix_socket: /tmp
        name: replicant
        password: "{{ passwd }}"
        role_attr_flags: LOGIN,REPLICATION
 
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
          max_wal_size = 480
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
 
- hosts: "{{ host }}"
  remote_user: ansible
  become: yes
 
  tasks:
    - name: enable and restart PG
      systemd:
        name: postgresql-9.6
        state: restarted
        enabled: True
...
```
Make clone pg3 as pg4, which we weel use for test logical replications.

```bash
lxc-stop -n pg3; lxc-copy -n pg3 -N pg4; lxc-start -n pg3
```

Now head to next step in directory [step-05](https://github.com/4orbit/ansible-PG-tuto/tree/master/step-05).
