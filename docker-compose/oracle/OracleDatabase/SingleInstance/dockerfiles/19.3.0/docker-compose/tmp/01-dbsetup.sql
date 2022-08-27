create or replace directory LOCAL_PUMP_DIR as '/opt/oracle/vood_data';

CREATE TABLESPACE vood_tab DATAFILE '/opt/oracle/vood_data/jp_tab.DAT' SIZE 1 M REUSE AUTOEXTEND ON NEXT 1 M;

CREATE TABLESPACE vood_tab DATAFILE '/opt/oracle/vood_data/jp_idx.DAT' SIZE 1 M REUSE AUTOEXTEND ON NEXT 1 M;

CREATE TABLESPACE vood_lob DATAFILE '/opt/oracle/vood_data/jp_lob.DAT' SIZE 1 M REUSE AUTOEXTEND ON NEXT 1 M;

alter session set container = ORCLPDB1;

create user vood identified by vood
    DEFAULT TABLESPACE vood_tab
;

grant create session to vood;
grant create table to vood;
grant create materialized view to vood;
grant create view to vood;
grant create synonym to vood;
grant unlimited tablespace to vood;
grant "CONNECT" to vood;
grant "RESOURCE" to vood;

GRANT AQ_ADMINISTRATOR_ROLE TO JP;

create or replace directory LOCAL_PUMP_DIR as '/opt/oracle/dump';