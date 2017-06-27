Configuring Postgres slaves
================

The previous script of preparing the server for standalone mode actually killed two birds with one stone by preconfiguring/enabling a slave host using the configuration files **postgresql.conf** and **server.conf**, which are copied to the slave using the **pg\_basebackup** command. What's especially interesting in this example is how we created a cascading replicated slave **pg3** which gets its data from the slave **pg2**. Take note of the second part of the script; we're taking advantage of Ansible's public key we installed in a previous script by logging directly into Postgres instead of Sudo:

    ansible-playbook -i step-05/hosts.cfg 05.configure_slave_94.yml --extra-vars "master=pg1 slave=pg2 passwd=mypassword"
    ansible-playbook -i step-05/hosts.cfg 05.configure_slave_94.yml --extra-vars "master=pg2 slave=pg3 passwd=mypassword"

``` ansible
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

Now head to next step in directory [step-06](https://github.com/4orbit/ansible-PG-tuto/tree/master/step-06).
