Install Postgres 9.6 packages
================

With the repo configured, we can now install the **rpms**. Notice the use of variables and the loop **with\_items** in our playbook invocation:

	ansible-playbook -i step-02/hosts.cfg 02.install_96.yml --extra-vars "host=dbservers"

``` yaml
---
- hosts: "{{ host }}"
  remote_user: ansible
  become: yes
 
  tasks:
    - name: install PostgreSQL version 9.6
      yum:
        name: "{{ item }}"
        state: latest
      with_items:
        - postgresql96-server
        - postgresql96-contrib
...
```
Note: Although not discussed, pg\_repack96 removes database bloat, so I invite you to take time to read up on it.

Now head to next step in directory [step-03](https://github.com/4orbit/ansible-PG-tuto/tree/master/step-03).
