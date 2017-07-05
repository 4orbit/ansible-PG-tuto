-- add primary key to history table
ALTER TABLE pgbench_history ADD COLUMN hid SERIAL PRIMARY KEY;

-- add foreign keys
ALTER TABLE pgbench_tellers ADD CONSTRAINT pgbench_tellers_branches_fk FOREIGN KEY(bid) REFERENCES pgbench_branches;
ALTER TABLE pgbench_accounts ADD CONSTRAINT pgbench_accounts_branches_fk FOREIGN KEY(bid) REFERENCES pgbench_branches;
ALTER TABLE pgbench_history ADD CONSTRAINT pgbench_history_branches_fk FOREIGN KEY(bid) REFERENCES pgbench_branches;
ALTER TABLE pgbench_history ADD CONSTRAINT pgbench_history_tellers_fk FOREIGN KEY(tid) REFERENCES pgbench_tellers;
ALTER TABLE pgbench_history ADD CONSTRAINT pgbench_history_accounts_fk FOREIGN KEY(aid) REFERENCES pgbench_accounts;

----

