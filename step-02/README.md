Add repos: PostgreSQL Versions 9.4 and 9.6
================

With the repo configured, we can now install the **rpms**. Notice the use of variables and the loop **with\_items** in our playbook invocation:

	ansible-playbook -i step-02/hosts.cfg 02.install_94.yml --extra-vars "host=dbservers"

``` ansible
---
- hosts: "{{ host }}"
  remote_user: ansible
  become: yes
 
  tasks:
    - name: install PostgreSQL version 9.4
      yum:
        name: "{{ item }}"
        state: latest
      with_items:
        - postgresql94-server
        - postgresql94-contrib
        - pg_repack94
...
```
Note: Although not discussed, pg\_repack94 removes database bloat, so I invite you to take time to read up on it.

Now head to next step in directory [step-03](https://github.com/4orbit/ansible-PG-tuto/tree/master/step-03).
