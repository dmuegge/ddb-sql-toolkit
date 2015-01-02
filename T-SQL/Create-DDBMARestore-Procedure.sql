-- ==============================================================================================
-- Procedure:	DDBMARestore
-- Author:		David Muegge
-- Purpose:		SQL Server Data Domain Boost Scripting Toolkit
--
-- Create date: 20141026
-- Description:	Execute Data Domain Boost SQL Restore and output status/results
--				
--
-- History:		20150101 - Updated error handling, added license information
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID ( 'dbo.DDBMARestore', 'P' ) IS NOT NULL 
    DROP PROCEDURE dbo.DDBMARestore;
GO
CREATE PROCEDURE dbo.DDBMARestore 
	@ClientHost					varchar (50),							-- -c Client/Host SQL Server Backup Source
	@RecoveryState				varchar (10)	= "normal",				-- -S Recovery State <normal,norecover,standby>
	@DDHost						varchar (50),							-- -a NSR_DFA_SI_DD_HOST - Data Domain Host Name
	@DDBoostUser				varchar (50),							-- -a NSR_DFA_SI_DD_USER - DD Boost User
	@DDStorageUnit				varchar (50),							-- -a NSR_DFA_SI_DEVICE_PATH - Storage Unit Name
	@SQLDatabaseName			varchar (100),							-- SQL Database Name
	@SQLInstanceName 			varchar (50)  	= "MSSQL",				-- SQL INstance Name - Defaults to MSSQL
	@StandbyFile				varchar (255)	= NULL,					-- File path of standby file for standby recovery option
	@BackupTimeStamp 			varchar (50)  	= NULL,					-- -t Last Backup Time Stamp
	@Overwrite					bit				= 0,					-- -f Overwrites the existing database with the current database that you restore,if the names of both the databases are same.
	@CCheck						bit				= NULL,					-- -j Performs a database consistency check between the SQL Server backed up data and the SQL Server restored data.
	@CreateChecksum				bit				= NULL,					-- -k Performs checksum before restoring the data from the device.
	@ContinueOnChecksumErr		bit				= NULL,					-- -u Performs checksum and continues the operation even in case of errors.
	@Relocate					bit				= NULL,					-- -C Relocates the database files (.mdf and .ldf) to a different folder.
	@DataPath					varchar(255)	= NULL,					-- Path to relocate SQL .mdf data file 'Contacts'='C:\AW_DB\Contacts.mdf'
	@LogPath					varchar(255)	= NULL,					-- Path to relocate SQL .ldf log file  'Contacts_log'='C:\AW_DB\Contacts_log.ldf'"
	@Quiet						bit				= NULL,					-- -q Displays ddbmsqlrc messages in the quiet mode, that is, the option provides minimal information about the progress of the restore operation including error messages.
	@DebugLevel					char(1)			= NULL					-- -D Generates detailed logs that you can use to troubleshoot the backup issues. <0-9>
	
	-- The following options of the ddbmsqlrc.exe command have not been implemented
	--@BackupLevel				varchar (10)	= NULL					-- THIS MAY BE A TYPO IN THE MANUAL -- GUI DOES NOT SEEM CREATE THIS OPTION --if @BackupLevel is not null Set @ddbmacmd = @ddbmacmd + ' -l "' + @BackupLevel + '"'  INVALID RESTORE OPTION ??
	--@TailLog					bit				= NULL,					-- -H Performs a tail-log backup of the database and leave it in the restoring state. IN GUI BUT NOT DOCUMENTED FOR COMMAND LINE
	--@VirtualServer			varchar (50)  	= NULL					-- -A Note: This appears to be intended for use with virtual cluster nodes, but is not documented well in the administration guide
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if @ClientHost is null raiserror('Null values not allowed for ClientHost', 16, 1)
	if @RecoveryState is null raiserror('Null values not allowed for RestoreType', 16, 1)
	if @DDHost is null raiserror('Null values not allowed for DDHost', 16, 1)
	if @DDBoostUser is null raiserror('Null values not allowed for DDBoostUser', 16, 1)
	if @DDStorageUnit is null raiserror('Null values not allowed for DDStorageUnit', 16, 1)
	if @SQLInstanceName is null raiserror('Null values not allowed for SQLInstanceName', 16, 1)
	if @SQLDatabaseName is null raiserror('Null values not allowed for SQLDatabaseName', 16, 1)
	
	declare @ddbmacmd nvarchar(4000);
	declare @cur cursor;
	declare @line nvarchar(4000);
	declare @rcode bit;
	
	-- Set return code to error state
	SET @rcode = 1;
	
	-- Base DD Boost Command
	SET @ddbmacmd = 'ddbmsqlrc.exe -c ' + @ClientHost
	if @RecoveryState = 'normal'
	Begin
		Set @ddbmacmd = @ddbmacmd + ' -S ' + @RecoveryState	
	End
	if @RecoveryState = 'norecover'
	Begin
		Set @ddbmacmd = @ddbmacmd + ' -S ' + @RecoveryState	
	End
	if @RecoveryState = 'standby'
	begin
		Set @ddbmacmd = @ddbmacmd + '''' + @SQLDatabaseName + '''=''' + '''' + @StandbyFile + ''''
	end
	
	-- Optional DD Boost command switches
	if @Overwrite = 1 Set @ddbmacmd = @ddbmacmd + ' -f '
	if @BackupTimeStamp is not null Set @ddbmacmd = @ddbmacmd + ' -t "' + @BackupTimeStamp + '"'
	if @CCheck is not null 
	Begin 
		if @CCheck = 1 Set @ddbmacmd = @ddbmacmd + ' -j '
	End
	if @CreateChecksum is not null 
	Begin 
		if @CreateChecksum = 1 Set @ddbmacmd = @ddbmacmd + ' -k '
		if @ContinueOnChecksumErr = 1 Set @ddbmacmd = @ddbmacmd + ' -u '
	End
	if @Relocate = 1
	begin
		Set @ddbmacmd = @ddbmacmd + '-C '"''' + @SQLDatabaseName + '''=''' + '''' + @DataPath + ''''
		Set @ddbmacmd = @ddbmacmd + '''' + @SQLDatabaseName + '_log''=''' + '''' + @LogPath + '''"'
	end
	if @Quiet is not null 
	Begin 
		if @Quiet = 1 Set @ddbmacmd = @ddbmacmd + ' -q '
	End
	if @DebugLevel is not null Set @ddbmacmd = @ddbmacmd + ' -D ' + @DebugLevel

	-- Standard DD Boost options
	Set @ddbmacmd = @ddbmacmd + 
	' -a "NSR_DFA_SI=TRUE"' +
	' -a "NSR_DFA_SI_USE_DD=TRUE"' +
	' -a "NSR_DFA_SI_DD_HOST=' + @DDHost + '"' +
	' -a "NSR_DFA_SI_DD_USER=' + @DDBoostUser + '"' +
	' -a "NSR_DFA_SI_DEVICE_PATH=' + @DDStorageUnit + '"' +
	' "' + @SQLInstanceName + ':' + @SQLDatabaseName + '"'
	
	-- Setup temprorary in memory table to loop through DDB executable output
	DECLARE @t TABLE (LINE NVARCHAR(4000))
	INSERT INTO @t
	exec xp_cmdshell @ddbmacmd
	SET @cur = Cursor FOR
	SELECT LINE FROM @t
	open @cur
	fetch next FROM @cur INTO @line
	while @@fetch_status = 0
	begin
		
		-- Check if restore was successful
		IF @line LIKE '%restore of database % completed successfully.'
		BEGIN
			-- Set return code to non error state
			SET @rcode = 0
		END
		
		-- Print output and process next line
		print @line
		fetch next FROM @cur INTO @line
	end
	close @cur;
	Deallocate @cur;
	
	-- Report if errors were returned
	IF @rcode = 1
		raiserror('An error occured with the restore',16,1)

END
GO