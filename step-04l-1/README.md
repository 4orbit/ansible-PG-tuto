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

``` yaml
---
вставлю. когда будет рабочий файл -- 04l-1.configure_londiste.yml
...
```
Note: Although not discussed, pg\_repack96 removes database bloat, so I invite you to take time to read up on it.


Now head to next step in directory [step-04l-2](https://github.com/4orbit/ansible-PG-tuto/tree/master/step-04l-2).
