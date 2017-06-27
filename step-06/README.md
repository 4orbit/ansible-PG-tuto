Invoke failover
================

Actually we just shut it down.

Test **pg2**

```
[ansible@ansible ansible-PG-tuto]$ ssh postgres@pg2
Last login: Tue Jun 27 08:49:28 2017 from 10.0.3.160
-bash-4.1$ psql
psql (9.4.12)
Type "help" for help.

postgres=# create table pg2_random as select s, md5(random()::text) from generate_Series(1,20) s;
ERROR:  cannot execute CREATE TABLE AS in a read-only transaction

```

Failover and promotion is super easy; just execute a single command against **pg2** and you're done. Because **pg3** is configured as a cascaded slave it will automatically replicate from the newly promoted master. The secret is in the recovery.conf file, where we configured it to always read the most recent timeline:

	ansible-playbook -i step-06/hosts.cfg 06.failover_94.yml --extra-vars "old_master=pg1 new_master=pg2"

``` ansible
---
- hosts: {{ old_master }}
  remote_user: ansible
  become: yes
 
  tasks:
    - service:
        name: postgresql-9.4
        state: stopped
 
- hosts: {{ new_master }}
  remote_user: postgres
 
  tasks:
    - name: promote data cluster pg4
      command:  /usr/pgsql-9.4/bin/pg_ctl -D /var/lib/pgsql/9.4/data/ promote
...
```

Now head to next step in directory [step-03](https://github.com/4orbit/ansible-PG-tuto/tree/master/step-03).
