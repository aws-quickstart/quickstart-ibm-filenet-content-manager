/* ------------------------------------------------------------------- */
/*                   GCD Database Schema                               */
/* ------------------------------------------------------------------- */
/* Create the Data Tablesapce */
CREATE TABLESPACE gcddata_ts LOGGING DATAFILE SIZE 400M EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO;
ALTER TABLESPACE gcddata_ts AUTOEXTEND ON MAXSIZE UNLIMITED;

/* Create the Temp Tablesapce */
CREATE TEMPORARY TABLESPACE gcdtemp_ts TEMPFILE SIZE 2G EXTENT MANAGEMENT LOCAL;
ALTER TABLESPACE gcdtemp_ts AUTOEXTEND ON;

/* Create the schema User */
CREATE USER gcduser PROFILE "DEFAULT" IDENTIFIED BY rds_password DEFAULT TABLESPACE gcddata_ts TEMPORARY TABLESPACE gcdtemp_ts ACCOUNT UNLOCK;
ALTER USER gcduser QUOTA UNLIMITED ON gcddata_ts;

/* Set the schema user permissions */
GRANT CONNECT TO gcduser;
GRANT RESOURCE TO gcduser;
GRANT CREATE SESSION TO gcduser;
GRANT CREATE TABLE TO gcduser;
GRANT CREATE VIEW TO gcduser;
GRANT CREATE SEQUENCE TO gcduser;
GRANT SELECT on dba_2pc_pending TO gcduser;
GRANT SELECT on dba_pending_transactions TO gcduser;
GRANT SELECT on DUAL TO gcduser;

/* ------------------------------------------------------------------- */
/*                   Object Store Schema                               */
/* ------------------------------------------------------------------- */
/* Create the CE Data Tablesapce */
CREATE TABLESPACE os1data_ts LOGGING DATAFILE SIZE 400M EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO;
ALTER TABLESPACE os1data_ts AUTOEXTEND ON MAXSIZE UNLIMITED;

/* Create the Index Tablesapce */
CREATE TABLESPACE os1index_ts LOGGING DATAFILE SIZE 300M EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO;
ALTER TABLESPACE os1index_ts AUTOEXTEND ON MAXSIZE UNLIMITED;

/* Create the PE Data Tablesapce */
CREATE TABLESPACE pedata_ts LOGGING DATAFILE SIZE 300M EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO;
ALTER TABLESPACE pedata_ts AUTOEXTEND ON MAXSIZE UNLIMITED;

/* Create the Temp Tablesapce */
CREATE TEMPORARY TABLESPACE os1temp_ts TEMPFILE SIZE 2G EXTENT MANAGEMENT LOCAL;
ALTER TABLESPACE os1temp_ts AUTOEXTEND ON;

/* Create the schema User */
CREATE USER os1user PROFILE "DEFAULT" IDENTIFIED BY rds_password DEFAULT TABLESPACE os1data_ts TEMPORARY TABLESPACE os1temp_ts ACCOUNT UNLOCK;
ALTER USER os1user QUOTA UNLIMITED ON os1data_ts;
ALTER USER os1user QUOTA UNLIMITED ON os1index_ts;
ALTER USER os1user QUOTA UNLIMITED ON pedata_ts;

/* Set the schema user permissions */
GRANT CONNECT TO os1user;
GRANT RESOURCE TO os1user;
GRANT CREATE SESSION TO os1user;
GRANT CREATE TABLE TO os1user;
GRANT CREATE VIEW TO os1user;
GRANT CREATE SEQUENCE TO os1user;
GRANT SELECT on dba_2pc_pending TO os1user;
GRANT SELECT on dba_pending_transactions TO os1user;
GRANT SELECT on DUAL TO os1user;

/* ------------------------------------------------------------------- */
/*                   Navigator Database Schema                         */
/* ------------------------------------------------------------------- */
/* Create the Data Tablesapce */
CREATE TABLESPACE nexusdata_ts LOGGING DATAFILE SIZE 400M EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO;
ALTER TABLESPACE nexusdata_ts AUTOEXTEND ON MAXSIZE UNLIMITED;

/* Create the Temp Tablesapce */
CREATE TEMPORARY TABLESPACE nexustemp_ts TEMPFILE SIZE 2G EXTENT MANAGEMENT LOCAL;
ALTER TABLESPACE nexustemp_ts AUTOEXTEND ON;

/* Create the schema User */
CREATE USER nexususer PROFILE "DEFAULT" IDENTIFIED BY rds_password DEFAULT TABLESPACE nexusdata_ts TEMPORARY TABLESPACE nexustemp_ts ACCOUNT UNLOCK;
ALTER USER nexususer QUOTA UNLIMITED ON nexusdata_ts;

/* Set the schema user permissions */
GRANT CONNECT TO nexususer;
GRANT RESOURCE TO nexususer;
GRANT CREATE SESSION TO nexususer;
GRANT CREATE TABLE TO nexususer;
GRANT CREATE VIEW TO nexususer;
GRANT CREATE SEQUENCE TO nexususer;
GRANT SELECT on dba_2pc_pending TO nexususer;
GRANT SELECT on dba_pending_transactions TO nexususer;
GRANT SELECT on DUAL TO nexususer;
GRANT CREATE TABLESPACE TO nexususer;
GRANT UNLIMITED TABLESPACE TO nexususer;
GRANT ALTER USER TO nexususer;
GRANT ALTER SESSION TO nexususer;

EXIT SQL.SQLCODE
