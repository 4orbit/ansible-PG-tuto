Invoke failover
================

Actually we just shut it down.

Test **pg2**

```bash
[ansible@ansible ansible-PG-tuto]$ ssh postgres@pg2
-bash-4.2$ psql 
psql (9.6.3)
Type "help" for help.

postgres=#  create table pg2_random as select s, md5(random()::text) from generate_Series(1,2) s;
ERROR:  cannot execute CREATE TABLE AS in a read-only transaction
```

Failover and promotion is super easy; just execute a single command against **pg2** and you're done. Because **pg3** is configured as a cascaded slave it will automatically replicate from the newly promoted master. The secret is in the recovery.conf file, where we configured it to always read the most recent timeline:

	ansible-playbook -i step-06/hosts.cfg 06.failover_96.yml --extra-vars "old_master=pg1 new_master=pg2"

``` yaml
---
- hosts: "{{ old_master }}"
  remote_user: ansible
  become: yes
 
  tasks:
    - service:
        name: postgresql-9.6
        state: stopped
 
- hosts: "{{ new_master }}"
  remote_user: postgres
 
  tasks:
    - name: promote new master for data cluster
      command:  /usr/pgsql-9.6/bin/pg_ctl -D /var/lib/pgsql/9.6/data/ promote
...
```

a) Go to new master **pg2** and try create table

```bash
[ansible@ansible ansible-PG-tuto]$ ssh postgres@pg2
Last login: Tue Jun 27 09.67:03 2017 from 10.0.3.160
-bash-4.1$ psql
psql (9.6.12)
Type "help" for help.

postgres=# create table pg2_random as select s, md5(random()::text) from generate_Series(1,20) s;
SELECT 20
postgres=# table pg2_random ;
 s  |               md5                
----+----------------------------------
  1 | 408b7b92aeea246832729d8f4efa2e85
  2 | 8fc2b1b94240543861b02bd91378713e
  3 | 13e7b2a22c63bdf5cc15f6e1b27b61a3
  4 | 23673988855bb46ad58d4da50e28b250
  5 | 96e8d5740740d0a2b9ddd78372c1713c
  6 | d8d403fb2768f1561f809a1873e6b918
  7 | 7689b82cf3289eeedae29298e4c16ebd
  8 | f7a70313319d76a1afbd5d9f0cabfa4e
  9 | a6efb98a1bd0ee71a4d973141d0f65fc
 10 | 4f4faabc5f5dace6c5314b7f1334afb7
 11 | 6fd2eb2804fd30562f619a071373338c
 12 | a72baf0a4538ff9ac5fbea7fd770a80f
 13 | b9c3558e0533654a738f5645fd76971b
 14 | 5986f3cab0377536a82de31b9bfc918c
 15 | 3b1dd927d77f9.62a4b594e29d0a65be
 16 | e1d770edaa227a426215618422df04a9
 17 | 2b4087f738538d0bdb19ec68e328a478
 18 | 46963a43d98ceb5fd11dbaa2f6f7e5a7
 19 | 20bbff5bb0b16cbf09885746767cd509
 20 | c5f63aa879.636b8aa9f9f250283db79
(20 rows)
```

b) See same data on **pg3**

```bash
[ansible@ansible ansible-PG-tuto]$ ssh postgres@pg3
Last login: Tue Jun 27 09:08:09 2017 from 10.0.3.160
-bash-4.1$ psql 
psql (9.6.12)
Type "help" for help.

postgres=# table pg2_random ;
 s  |               md5                
----+----------------------------------
  1 | 408b7b92aeea246832729d8f4efa2e85
  2 | 8fc2b1b94240543861b02bd91378713e
  3 | 13e7b2a22c63bdf5cc15f6e1b27b61a3
  4 | 23673988855bb46ad58d4da50e28b250
  5 | 96e8d5740740d0a2b9ddd78372c1713c
  6 | d8d403fb2768f1561f809a1873e6b918
  7 | 7689b82cf3289eeedae29298e4c16ebd
  8 | f7a70313319d76a1afbd5d9f0cabfa4e
  9 | a6efb98a1bd0ee71a4d973141d0f65fc
 10 | 4f4faabc5f5dace6c5314b7f1334afb7
 11 | 6fd2eb2804fd30562f619a071373338c
 12 | a72baf0a4538ff9ac5fbea7fd770a80f
 13 | b9c3558e0533654a738f5645fd76971b
 14 | 5986f3cab0377536a82de31b9bfc918c
 15 | 3b1dd927d77f9.62a4b594e29d0a65be
 16 | e1d770edaa227a426215618422df04a9
 17 | 2b4087f738538d0bdb19ec68e328a478
 18 | 46963a43d98ceb5fd11dbaa2f6f7e5a7
 19 | 20bbff5bb0b16cbf09885746767cd509
 20 | c5f63aa879.636b8aa9f9f250283db79
(20 rows)
```

Now head to next step in directory [step-07](https://github.com/4orbit/ansible-PG-tuto/tree/master/step-07).
