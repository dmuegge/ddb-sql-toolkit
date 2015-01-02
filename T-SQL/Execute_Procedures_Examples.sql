-- ==============================================================================================
-- Example:		Calling SQL Server Data Domain Boost Scripting Toolkit stored procedures
-- Author:		David Muegge
-- Purpose:		For use with SQL Server Data Domain Boost Scripting Toolkit
--
-- Create date: 20141026
-- Description:	Various examples for using all toolkit stored procedures
--				
--
-- History:		20150101 - Added backup,expire and catalog examples, added license information
--
--
-- Notes:		None
-- 
--
-- Disclaimer
--   ****************************************************************
--   * THIS SCRIPT IS PROVIDED WITHOUT WARRANTY OF ANY KIND.        *
--   *                                                              *
--   * This script is licensed under the terms of the MIT license.  *
--   *                                                              *
--   ****************************************************************  
-- ==============================================================================================

-- Backup databases
-- Full Backup Production to primary DD - Run from primary
Use DMadmin
Exec dbo.DDBMABackup @ClientHost = 'SQL2012.ddlab.local',
	@BackupLevel = 'full',
	@BackupSetName = 'ContactsFull', 
	@BackupSetDescription = 'Contacts Full Backup',
	@RetentionDays = 7,
	@DDHost = 'dd640-01.ddlab.local',
	@DDBoostUser = 'ddboost',
	@DDStorageUnit = '/Boost-SQL',
	@SQLDatabaseName = 'Contacts'
	
-- Incr/Log Backup Production to primary DD - Run from primary
Use DMadmin
Exec dbo.DDBMABackup @ClientHost = 'SQL2012.ddlab.local',
	@BackupLevel = 'incr',
	@BackupSetName = 'ContactsLog', 
	@BackupSetDescription = 'Contacts Transaction Log Backup',
	@RetentionDays = 7,
	@DDHost = 'dd640-01.ddlab.local',
	@DDBoostUser = 'ddboost',
	@DDStorageUnit = '/Boost-SQL',
	@SQLDatabaseName = 'Contacts'

-- Full backup of system databases (master,model,msdb)
declare @cur cursor;
declare @dbname nvarchar(100);
declare @bsetname nvarchar(255);
declare @bsetdescription nvarchar(255);
DECLARE @t TABLE (DBNAME NVARCHAR(100))
INSERT INTO @t
	Select Name From Sys.Databases Where (name <> 'tempdb') and (database_id < 5)
SET @cur = Cursor FOR
SELECT DBNAME FROM @t
open @cur
fetch next FROM @cur INTO @dbname
while @@fetch_status = 0
begin
	print '--------------------------------------------------------------'
	print 'Backing up ' + @dbname
	print '--------------------------------------------------------------'

	Set @bsetname = @dbname + '_Full';
	Set @bsetdescription = @dbname + ' Full Backup';

	Use DMadmin
	Exec dbo.DDBMABackup @ClientHost = 'SQL2012.ddlab.local',
		@BackupLevel = 'full',
		@BackupSetName = @bsetname,
		@BackupSetDescription = @bsetdescription,
		@RetentionDays = 7,
		@DDHost = 'dd640-01.ddlab.local',
		@DDBoostUser = 'ddboost',
		@DDStorageUnit = '/Boost-SQL',
		@SQLDatabaseName = @dbname
	
	fetch next FROM @cur INTO @dbname
end
close @cur;
Deallocate @cur;

-- Full backup of all user databases
declare @cur cursor;
declare @dbname nvarchar(100);
declare @bsetname nvarchar(255);
declare @bsetdescription nvarchar(255);
DECLARE @t TABLE (DBNAME NVARCHAR(100))
INSERT INTO @t
	Select Name From Sys.Databases Where (database_id > 5)
SET @cur = Cursor FOR
SELECT DBNAME FROM @t
open @cur
fetch next FROM @cur INTO @dbname
while @@fetch_status = 0
begin
	print '--------------------------------------------------------------'
	print 'Backing up ' + @dbname
	print '--------------------------------------------------------------'

	Set @bsetname = @dbname + '_Full';
	Set @bsetdescription = @dbname + ' Full Backup';

	Use DMadmin
	Exec dbo.DDBMABackup @ClientHost = 'SQL2012.ddlab.local',
		@BackupLevel = 'full',
		@BackupSetName = @bsetname,
		@BackupSetDescription = @bsetdescription,
		@RetentionDays = 7,
		@DDHost = 'dd640-01.ddlab.local',
		@DDBoostUser = 'ddboost',
		@DDStorageUnit = '/Boost-SQL',
		@SQLDatabaseName = @dbname
	
	fetch next FROM @cur INTO @dbname
end
close @cur;
Deallocate @cur;

-- Full backup of specific databases
declare @cur cursor;
declare @dbname nvarchar(100);
declare @bsetname nvarchar(255);
declare @bsetdescription nvarchar(255);
DECLARE @t TABLE (DBNAME NVARCHAR(100))
INSERT INTO @t
	Select Name From Sys.Databases Where Name in ('master','contacts')
SET @cur = Cursor FOR
SELECT DBNAME FROM @t
open @cur
fetch next FROM @cur INTO @dbname
while @@fetch_status = 0
begin
	print '--------------------------------------------------------------'
	print 'Backing up ' + @dbname
	print '--------------------------------------------------------------'

	Set @bsetname = @dbname + '_Full';
	Set @bsetdescription = @dbname + ' Full Backup';

	Use DMadmin
	Exec dbo.DDBMABackup @ClientHost = 'SQL2012.ddlab.local',
		@BackupLevel = 'full',
		@BackupSetName = @bsetname,
		@BackupSetDescription = @bsetdescription,
		@RetentionDays = 7,
		@DDHost = 'dd640-01.ddlab.local',
		@DDBoostUser = 'ddboost',
		@DDStorageUnit = '/Boost-SQL',
		@SQLDatabaseName = @dbname
	
	fetch next FROM @cur INTO @dbname
end
close @cur;
Deallocate @cur;



-- Restore databases - Note: to restore to different target run restore command on target server but specify source server in @ClientHost parameter
-- Restore backup from primary and complete recovery
Use DMadmin
Exec DMAdmin.dbo.DDBMARestore @ClientHost = 'SQL2012.ddlab.local',
	@RecoveryState = 'normal',
	@DDHost = 'dd640-01.ddlab.local',
	@DDBoostUser = 'ddboost',
	@DDStorageUnit = '/Boost-SQL',
	@SQLDatabaseName = 'Contacts',
	@Overwrite = 1

-- Restore backup from secondary and complete recovery
Use DMadmin
Exec dbo.DDBMARestore @ClientHost = 'SQL2012.ddlab.local',
	@RecoveryState = 'normal',
	@DDHost = 'dd610-02.ddlab.local',
	@DDBoostUser = 'boost',
	@DDStorageUnit = '/Boost-SQL',
	@SQLDatabaseName = 'Contacts',
	@Overwrite = 1

-- Restore backup from secondary leave in recovery mode for transaction log restores
Use DMadmin
Exec DDBMARestore @ClientHost = 'SQL2012.ddlab.local',
	@BackupTimeStamp = '11/13/2014 22:32:25',
	@RecoveryState = 'norecover',
	@DDHost = 'dd610-02.ddlab.local',
	@DDBoostUser = 'boost',
	@DDStorageUnit = '/Boost-SQL',
	@SQLDatabaseName = 'Contacts',
	@Overwrite = 1
	
-- Complete recovery and leave database in normal state
Use DMadmin
Exec DDBMARestore @ClientHost = 'SQL2012.ddlab.local',
	@BackupTimeStamp = '11/14/2014 07:48:20',
	@RecoveryState = 'normal',
	@DDHost = 'dd610-02.ddlab.local',
	@DDBoostUser = 'boost',
	@DDStorageUnit = '/Boost-SQL',
	@SQLDatabaseName = 'Contacts'	

	
-- Manager SQL backup catalog table	
-- Get SQL Backup Catalog
Use DMadmin
Exec DDBMACatalog

-- Get SQL Backup Catalog entries for BackupSetName
Use DMadmin
Exec DDBMACatalog @BackupSetName = 'ContactsFull'

-- Get SQL Backup Catalog entries for DatabaseName
Use DMadmin
Exec DDBMACatalog @DatabaseName = 'ContactsFull'

-- Get SQL Backup Catalog entries for time period based on backup date
Use DMadmin
Exec DDBMACatalog

-- Get SQL Backup Catalog entries for time period based on expiration date
Use DMadmin
Exec DDBMACatalog

-- Delete SQL Backup Catalog entries for time period based on expiration date
Use DMadmin
Exec DDBMACatalog

-- Delete Expired Entries between 90 and 100 days old
declare @StartDate datetime = dateadd(day,-50,getdate())
declare @EndDate datetime = dateadd(day,-1,getdate())
Exec DDBMACatalog @BackupExpireStart = @StartDate, @BackupExpireEnd = @EndDate

	
-- Manage expired backup images on Data Domain storage unit
-- Show all backup images 
Use DMadmin
Exec dbo.DDBMAExpire @AppType = 'mssql',
	@ConfigFile = 'C:\dd640-dm.cfg'
	
-- Show specific backup images
Use DMadmin
Exec dbo.DDBMAExpire @AppType = 'mssql',
	@ConfigFile = 'C:\dd640-dm.cfg',
	@StartTime = '11/18/2014 10:45:40',
	@EndTime = '11/18/2014 10:45:40',
	@SaveSet = 'Contacts_Full',
	@DelExpired = NULL,
	@Clean = NULL,
	@Verbose = NULL
	
-- Delete specific backup images
Use DMadmin
Exec dbo.DDBMAExpire @AppType = 'mssql',
	@ConfigFile = 'C:\dd640-dm.cfg',
	@StartTime = '11/18/2014 10:45:40',
	@EndTime = '11/18/2014 10:45:40',
	@SaveSet = 'Contacts_Full',
	@DelExpired = 1,
	@Clean = NULL,
	@Verbose = NULL

-- Delete Expired Entries between 90 and 100 days old
Use DMadmin
declare @StartDatetime varchar(25) = convert(varchar(25),Format(dateadd(day,-100,getdate()), 'MM/dd/yyyy hh:mm:ss'))
declare @EndDatetime varchar(25) = convert(varchar(25),Format(dateadd(day,-90,getdate()), 'MM/dd/yyyy hh:mm:ss'))
Exec dbo.DDBMAExpire @AppType = 'mssql',
	@ConfigFile = 'C:\dd640-dm.cfg',
	@StartTime = '11/18/2014 10:45:40',
	@EndTime = '11/18/2014 10:45:40',
	@SaveSet = 'Contacts_Full',
	@DelExpired = 1,
	@Clean = NULL,
	@Verbose = NULL
	

