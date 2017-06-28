# my notes\_tmp

      ansible -i step-02/hosts.cfg all -m shell -a "psql -c 'table t_random;'"  -u postgres
      ansible -i step-02/hosts.cfg all -m shell -a "psql -c 'table pg2_random;'"  -u postgres

exec sql commant on all my servers by ansible

determine it is master or replica:
      ansible -i step-02/hosts.cfg all -m shell -a "psql -c 'SELECT pg_is_in_recovery();'"  -u postgres

``` 
[ansible@ansible ansible-PG-tuto]$ ansible -i step-02/hosts.cfg all -m shell -a "psql -c 'create table pgf_random as select s, md5(random()::text) from generate_Series(1,6) s;'"  -u postgres
pg1 | FAILED | rc=2 >>
psql: could not connect to server: No such file or directory
	Is the server running locally and accepting
	connections on Unix domain socket "/tmp/.s.PGSQL.5432"?

pg3 | FAILED | rc=1 >>
ERROR:  cannot execute CREATE TABLE AS in a read-only transaction

pg2 | SUCCESS | rc=0 >>
SELECT 6

[ansible@ansible ansible-PG-tuto]$ ansible -i step-02/hosts.cfg all -m shell -a "psql -c 'table pgf_random;'"  -u postgres
pg3 | SUCCESS | rc=0 >>
 s |               md5                
---+----------------------------------
 1 | 18cf0c4b0ebed942d84781dde9143615
 2 | 5a22aecfb45fcf56534f5f8c59f39960
 3 | 51cddc5fdab503fb016fe3bef819c825
 4 | 594295b7d4fc8d61563210313eaf6d40
 5 | 8685a0c812afbcdcfe607db57815e1cc
 6 | f377a9c69f240563e41c1fff99e3c264
(6 rows)

pg1 | FAILED | rc=2 >>
psql: could not connect to server: No such file or directory
	Is the server running locally and accepting
	connections on Unix domain socket "/tmp/.s.PGSQL.5432"?

pg2 | SUCCESS | rc=0 >>
 s |               md5                
---+----------------------------------
 1 | 18cf0c4b0ebed942d84781dde9143615
 2 | 5a22aecfb45fcf56534f5f8c59f39960
 3 | 51cddc5fdab503fb016fe3bef819c825
 4 | 594295b7d4fc8d61563210313eaf6d40
 5 | 8685a0c812afbcdcfe607db57815e1cc
 6 | f377a9c69f240563e41c1fff99e3c264
(6 rows)

[ansible@ansible ansible-PG-tuto]$ 

```

# The end

At this point, you can try building up everything from scratch, to see
if you can properly provision your cluster with your playbook.

Fire in the hole!

    vagrant destroy -f
    vagrant up
    ansible-playbook -c paramiko -i step-00/hosts step-00/setup.yml --ask-pass --sudo

(you might need to wait a little for the network to come up before
running the last command).

All the preceeding commands are just here to set-up our test
environment. Deploying on the blank machines just requires one line:

    ansible-playbook -i step-99/hosts step-99/site.yml

Just one command to rule them all: you have your cluster, can add nodes ad
nauseam, tune settings, ... all this can be extended at will with more variables, 
other plays, etc...

# The end

Ok, seems we're done with our tutorial. Hope you enjoyed playing with Ansible, and 
felt the power of this new tool.

Now go straight to [Ansible website](http://ansible.cc), dive in the docs, check references, 
skim through playbooks, chat on freenode in #ansible, and foremost, have fun!
