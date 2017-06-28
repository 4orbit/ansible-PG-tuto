Add public key on all database servers for Unix account Ansible
================

Adding a public key is a practice I adopted years ago. It is a secure and easy way to access your machine, not to mention really useful for those emergency situations when you panic and accidently lock yourself out of the server(s) as you mistype your password.

Here's our playbook, **03.install\_key.yml**:

	ansible-playbook -i step-02/hosts.cfg 02.install_94.yml --extra-vars "host=dbservers"

``` yaml
---
- hosts: dbservers
  remote_user: ansible
  become: yes
 
  tasks:
    - name: install SSH key
      authorized_key:
	      key: "{{ lookup('file', '/home/ansible/.ssh/id_rsa.pub') }}"
	      user: "{{user}}"
	      state: present
...
```
And here's our invocation. Notice the use the extra variable identifying Unix account **Ansible**:

	ansible-playbook -i step-03/hosts.cfg 03.install_key.yml --extra-vars "user=ansible"
	ansible-playbook -i step-03/hosts.cfg 03.install_key.yml --extra-vars "user=postgres"

Now head to next step in directory [step-04](https://github.com/4orbit/ansible-PG-tuto/tree/master/step-04).
