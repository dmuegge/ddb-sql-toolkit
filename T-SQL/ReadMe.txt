This is the T-SQL version of the SQL Server Data Domain Boost Scripting Toolkit.

The toolkit consists of T-SQL procedures and code to automate DD Boost SQL Server backups using T-SQL, Agent Jobs, and Maintenance Plans. It is recommended to
deploy the toolkit resources into an adminstrative database on each SQL Server.

This is a list of the files included in the toolkit and a brief description. Additional information is included in each file.

SQL Stored Procedures
-------------------------------------------------------------------------
Create-DDBMABackup-Procedure.sql - T-SQL to create backup procedure
Create-DDBMARestore-Procedure.sql - T-SQL to create restore procedure
Create-DDBMAExpire-Procedure.sql - T-SQL to create expire procedure
Create-DDBMACatalog-Procedure.sql - T-SQL to create catalog procedure

SQL Table
-------------------------------------------------------------------------
Create-DDBMASQLCatalog-Table.sql - T-SQL to create catalog table


T-SQL Examples for calling procedures
-------------------------------------------------------------------------
Execute_Procedures_Examples.sql


T-SQL for Prerequisite configuration and example DD Boost configuration file
-------------------------------------------------------------------------
PreRequisite_Configuration.sql
DDBMA_SQL_Example.cfg


Notes:
--------------------------------------------------------------------------
This scripting toolkit relies on EMC DD Boost for SQL Server executables.
Changes to those executables could affect operation of this toolkit.
Please test new versions before deploying to production environments.


Disclaimer
---------------------------------------------------------------------------
   ****************************************************************
   * THE (SQL Server Data Domain Boost Scripting Toolkit)         *
   * IS PROVIDED WITHOUT WARRANTY OF ANY KIND.                    *
   *                                                              *
   * This toolkit is licensed under the terms of the MIT license. *
   * See license.txt in the root of the github project            *
   *                                                              *
   ****************************************************************  