Invoke failover
================

This script is virtually the same as script **05.configure\_slave\_96.yml**. You might even want to edit it, thus eliminating one script from your collection:

    ansible-playbook -i step-08/hosts.cfg 08.configure_slave_10.yml --extra-vars "master=pg1 slave=pg2 passwd=mypassword"
    ansible-playbook -i step-08/hosts.cfg 08.configure_slave_10.yml --extra-vars "master=pg2 slave=pg3 passwd=mypassword"

```yaml
---
- hosts: "{{ slave }}"
  remote_user: ansible
  become: yes
 
  tasks:
    - systemd:
        name: postgresql-9.6
        state: stopped
 
    - systemd:
        name: postgresql-10
        state: stopped
 
    - file:
       path: /var/lib/pgsql/10/data/
       state: absent
 
    - file:
       path:  /var/lib/pgsql/10/data/
       owner: postgres
       group: postgres
       mode:  0700
       state: directory
 
- hosts: "{{ slave }}"
  remote_user: postgres
 
  tasks:
    - name: execute base backup
      shell: |
        export PGPASSWORD="{{ passwd }}" && \
        /usr/pgsql-10/bin/pg_basebackup \
            -h {{ master }} \
            -U replicant \
            -D /var/lib/pgsql/10/data \
            -P -v --wal-method=stream 2>&1
 
        exit 0
 
    - name: add new configuration "recovery.conf"
      blockinfile:
        create: yes
        dest: /var/lib/pgsql/10/data/recovery.conf
        block: |
          standby_mode = 'on'
          primary_conninfo = 'user=replicant password={{ passwd }} host={{ master }} port=5432 sslmode=prefer'
          recovery_target_timeline = 'latest'
 
    - name: update environment variables in UNIX account postgres
      blockinfile:
        create: yes
        dest: /var/lib/pgsql/.pgsql_profile
        block: |
          export PGHOST=/tmp PAGER=less PGDATA=/var/lib/pgsql/10/data
 
- hosts: "{{ slave }}"
  remote_user: ansible
  become: yes
 
  tasks:
    - service:
        name: postgresql-10
        state: started
...
```
Test our cluster install with next command:


```bash
[ansible@ansible ansible-PG-tuto]$ ansible -i step-02/hosts.cfg all -m shell -a "psql -c 'create table pg10a_random as select s, md5(random()::text) from generate_Series(1,2) s;'"  -u postgres
pg2 | FAILED | rc=1 >>
ERROR:  cannot execute CREATE TABLE AS in a read-only transaction

pg3 | FAILED | rc=1 >>
ERROR:  cannot execute CREATE TABLE AS in a read-only transaction

pg1 | SUCCESS | rc=0 >>
SELECT 2

```
And see replication result^
```bash
[ansible@ansible ansible-PG-tuto]$ ansible -i step-02/hosts.cfg all -m shell -a "psql -c 'table pg96a_random'"  -u postgres
pg1 | SUCCESS | rc=0 >>
 s |               md5                
---+----------------------------------
 1 | 222106cd0e0b94e7a18cd9ca42b29a7
 2 | 1a5c6c58f3a61f03ed288b6a1406b4a8
(2 rows)

pg2 | SUCCESS | rc=0 >>
 s |               md5                
---+----------------------------------
 1 | 222106cd0e0b94e7a18cd9ca42b29a7
 2 | 1a5c6c58f3a61f03ed288b6a1406b4a8
(2 rows)

pg3 | SUCCESS | rc=0 >>
 s |               md5                
---+----------------------------------
 1 | 222106cd0e0b94e7a18cd9ca42b29a7
 2 | 1a5c6c58f3a61f03ed288b6a1406b4a8
(2 rows)

```

Now head to next step in directory [step-99](https://github.com/4orbit/ansible-PG-tuto/tree/master/step-99).
