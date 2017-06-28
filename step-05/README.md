Configuring Postgres slaves
================

The previous script of preparing the server for standalone mode actually killed two birds with one stone by preconfiguring/enabling a slave host using the configuration files **postgresql.conf** and **server.conf**, which are copied to the slave using the **pg\_basebackup** command. What's especially interesting in this example is how we created a cascading replicated slave **pg3** which gets its data from the slave **pg2**. Take note of the second part of the script; we're taking advantage of Ansible's public key we installed in a previous script by logging directly into Postgres instead of Sudo:

    ansible-playbook -i step-05/hosts.cfg 05.configure_slave_94.yml --extra-vars "master=pg1 slave=pg2 passwd=mypassword"
    ansible-playbook -i step-05/hosts.cfg 05.configure_slave_94.yml --extra-vars "master=pg2 slave=pg3 passwd=mypassword"

``` yaml
---
- hosts: "{{ slave }}"
  remote_user: ansible
  become: yes
 
  tasks:
    - service:
        name: postgresql-9.4
        state: stopped
 
    - file:
       path: /var/lib/pgsql/9.4/data/
       state: absent
 
    - file:
       path:  /var/lib/pgsql/9.4/data/
       owner: postgres
       group: postgres
       mode:  0700
       state: directory
 
- hosts: "{{ slave }}"
  remote_user: postgres
 
  tasks:
    - name: execute base backup
      shell: export PGPASSWORD="{{ passwd }}" && /usr/pgsql-9.4/bin/pg_basebackup -h {{ master }} -U replicant -D /var/lib/pgsql/9.4/data -P -v --xlog-method=stream 2>&1
 
    - name: add new configuration "recovery.conf"
      blockinfile:
        create: yes
        dest: /var/lib/pgsql/9.4/data/recovery.conf
        block: |
          standby_mode = 'on'
          primary_conninfo = 'user=replicant password={{ passwd }} host={{ master }} port=5432 sslmode=prefer'
          recovery_target_timeline = 'latest'
 
- hosts: "{{ slave }}"
  remote_user: ansible
  become: yes
 
  tasks:
    - service:
        name: postgresql-9.4
        state: started
...
```
Test our cluster install with next command:

a) on **pg1**

```bash
[ansible@ansible ansible-PG-tuto]$ ssh postgres@pg1
Last login: Tue Jun 27 08:47:31 2017 from 10.0.3.160
-bash-4.1$ psql
psql (9.4.12)
Type "help" for help.

postgres=# create table t_random as select s, md5(random()::text) from generate_Series(1,20) s;
SELECT 20
postgres=# table t_random ;
 s  |               md5                
----+----------------------------------
  1 | 0100a7fcf26348f1f52bb6c955d50e88
  2 | 500b4e49d6cbe0a4f65aa0079bbe9a3a
  3 | b0acee3ae49bc6254b8ee9ab046922d5
  4 | d3d12ee2204fb431b5c1febde8acb714
  5 | 4783c7faa9dedfafcb6b6b5079f31801
  6 | 02fd9567b2d490fe2e7f18575625c204
  7 | 20046c30800f74ac6eab2727c920f9e2
  8 | 03837a20825edaae425a8cd6bd49cb98
  9 | 9fd34729bf83ce0a9363a214f5f11b76
 10 | df76bc2877fd114f8cd088bdfebfe8fb
 11 | 9e7f27e4a26dc4f114310d1c2bf09963
 12 | 71fe4c35389b1990d41844735f2cf4be
 13 | ec3f1c810fa6c8b8b5eaaa60dace7a02
 14 | a671b8115d4053414c3c41a48f7c9873
 15 | 49b8abdaba60ee95e66967f5e7df61bf
 16 | e7b78c8e7b81825f6018ca4d80831e0f
 17 | f8c26858f5724adef3bd9274edde1cbf
 18 | 5cf817572a526c702f52e8d52c600e66
 19 | 4f7726e03970ed9e02a78be5600e7850
 20 | 1ffafbbf2739d1a68b32ae9cb9c6e6ed
(20 rows)

postgres=# \q
-bash-4.1$ logout
Connection to pg1 closed.
[ansible@ansible ansible-PG-tuto]$ 

```

b) on **pg3**

```bash
[ansible@ansible ansible-PG-tuto]$ ssh postgres@pg3
Last login: Tue Jun 27 08:51:47 2017 from 10.0.3.160
-bash-4.1$ psql 
psql (9.4.12)
Type "help" for help.

postgres=# table t_random ;
 s  |               md5                
----+----------------------------------
  1 | 0100a7fcf26348f1f52bb6c955d50e88
  2 | 500b4e49d6cbe0a4f65aa0079bbe9a3a
  3 | b0acee3ae49bc6254b8ee9ab046922d5
  4 | d3d12ee2204fb431b5c1febde8acb714
  5 | 4783c7faa9dedfafcb6b6b5079f31801
  6 | 02fd9567b2d490fe2e7f18575625c204
  7 | 20046c30800f74ac6eab2727c920f9e2
  8 | 03837a20825edaae425a8cd6bd49cb98
  9 | 9fd34729bf83ce0a9363a214f5f11b76
 10 | df76bc2877fd114f8cd088bdfebfe8fb
 11 | 9e7f27e4a26dc4f114310d1c2bf09963
 12 | 71fe4c35389b1990d41844735f2cf4be
 13 | ec3f1c810fa6c8b8b5eaaa60dace7a02
 14 | a671b8115d4053414c3c41a48f7c9873
 15 | 49b8abdaba60ee95e66967f5e7df61bf
 16 | e7b78c8e7b81825f6018ca4d80831e0f
 17 | f8c26858f5724adef3bd9274edde1cbf
 18 | 5cf817572a526c702f52e8d52c600e66
 19 | 4f7726e03970ed9e02a78be5600e7850
 20 | 1ffafbbf2739d1a68b32ae9cb9c6e6ed
(20 rows)

postgres=# \q
-bash-4.1$ logout
Connection to pg3 closed.
[ansible@ansible ansible-PG-tuto]$ 

```

Now head to next step in directory [step-06](https://github.com/4orbit/ansible-PG-tuto/tree/master/step-06).
