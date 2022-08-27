
alter session set container = ORCLPDB1;

create user localdev identified by localdev;

CREATE TABLESPACE t_tab DATAFILE '/opt/oracle/jp_tab.DAT' SIZE 1 M REUSE AUTOEXTEND ON NEXT 1 M;

CREATE TABLESPACE t_idx DATAFILE '/opt/oracle/jp_idx.DAT' SIZE 1 M REUSE AUTOEXTEND ON NEXT 1 M;

CREATE TABLESPACE t_lob DATAFILE '/opt/oracle/jp_lob.DAT' SIZE 1 M REUSE AUTOEXTEND ON NEXT 1 M;

alter user localdev DEFAULT TABLESPACE t_tab;

GRANT AQ_ADMINISTRATOR_ROLE TO localdev;

GRANT DBA TO localdev;

grant create session to localdev;
grant create table to localdev;
grant create materialized view to localdev;
grant create view to localdev;
grant create synonym to localdev;
grant unlimited tablespace to localdev;
grant "CONNECT" to localdev;
grant "RESOURCE" to localdev;

create or replace directory LOCAL_PUMP_DIR as '/opt/oracle/dump';