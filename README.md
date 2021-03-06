# ansible-PG-tuto
This tutorial presents ansible in actions with PostgreSQL step-by-step

Author -- [Robert Bernier](https://opensource.com/users/rbernier). Original article ["How to use Ansible to manage PostgreSQL"](https://opensource.com/article/17/6/ansible-postgresql-operations) 

Ansible, an open source automation tool, can make complex configuration and management tasks in Postgres simple.

Working with a database in a pressure-cooker production environment using an agile approach with tight deadlines can be a contradictory experience. As this article demonstrates, you can operationalize those many steps and prepare Postgres for any range of service. The key is Ansible, an open source automation engine for software provisioning, configuration management, and application deployment.

For the purposes of this article, we assume readers have some knowledge of both Ansible and PostgreSQL, not to mention Linux. I'm covering only the most basic features here; for a deeper dive, check out the references at the end of this article.


## Contents

- [How to administrate a cluster of database servers on a developer workstation](https://github.com/4orbit/ansible-PG-tuto/tree/master/step-00)
- [Add repos: PostgreSQL Versions 9.4 and 9.6](https://github.com/4orbit/ansible-PG-tuto/tree/master/step-01)
- [Install Postgres and packages 9.4](https://github.com/4orbit/ansible-PG-tuto/tree/master/step-02)
- [Add public key on all database servers for Unix account Ansible](https://github.com/4orbit/ansible-PG-tuto/tree/master/step-03)
- [Configure each host as a standalone service](https://github.com/4orbit/ansible-PG-tuto/tree/master/step-04)
- [Configuring Postgres slaves](https://github.com/4orbit/ansible-PG-tuto/tree/master/step-05)
- [Invoke failover](https://github.com/4orbit/ansible-PG-tuto/tree/master/step-06)
- [Upgrade servers from 9.4 to 9.6](https://github.com/4orbit/ansible-PG-tuto/tree/master/step-07)
- [Invoke failover](https://github.com/4orbit/ansible-PG-tuto/tree/master/step-08)
- [Conclusion](https://github.com/4orbit/ansible-PG-tuto/tree/master/step-99)


## Contributing

Thanks to all people who have contributed to this tutorial:

If you have ideas on topics that would require a chapter, please open a
PR.

I'm also open on pairing for writing chapters. Drop me a note if you're
interested.

