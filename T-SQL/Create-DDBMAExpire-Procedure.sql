-- ==============================================================================================
-- Procedure:	DDBMAExpire
-- Author:		David Muegge
-- Purpose:		SQL Server Data Domain Boost Scripting Toolkit
--
-- Create date: 20141108
-- Description:	Execute Data Domain Boost SQL Expire tool and output status/results
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
IF OBJECT_ID ( 'dbo.DDBMAExpire', 'P' ) IS NOT NULL 
    DROP PROCEDURE dbo.DDBMAExpire;
GO
CREATE PROCEDURE dbo.DDBMAExpire 
	@SaveSet					varchar (100)	= NULL,					-- -a specifies a filter on the save set name for display and deletes both.
	@StartTime					varchar (30)	= NULL,					-- -b specifies the lower boundary of the expiry time of the save set - Hr(24 hour format):Min:Sec Month DD, YYYY
	@EndTime	 				varchar (30)	= NULL,					-- -e specifies the upper boundary of the expiry time of the save set - Hr(24 hour format):Min:Sec Month DD, YYYY
	@AppType		 			varchar (10)  	= "mssql",				-- -n specifies the application type
	@ConfigFile					varchar (255)	= NULL,					-- -z specifies the configuration file path
	@Clean						bit				= NULL,					-- -c cleans up the corrupted or invalid catalogue information
	@DelExpired					bit				= NULL,					-- -r deletes the expired savesets 
	@Verbose					bit				= NULL					-- -v prints the verbose output on the console
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Check required parameters
	if @AppType is null raiserror('Null values not allowed for AppType', 16, 1)
	if @ConfigFile is null raiserror('Null values not allowed for ConfigFile', 16, 1)
		
	declare @ddbmacmd nvarchar(4000);
	declare @cur cursor;
	declare @line nvarchar(4000);
	declare @rcode bit;
	declare @rreturned bit;
	
	-- Set return code to no errors and records returned to 0
	SET @rcode = 0;
	SET @rreturned = 0;
	
	-- Base DD Boost Command
	SET @ddbmacmd = 'echo Y | ddbmexptool.exe -n ' + @AppType + 
	' -z "' + @ConfigFile + '"'
	
	-- Optional DD Boost command switches
	if @SaveSet is not null Set @ddbmacmd = @ddbmacmd + ' -a ' + @SaveSet
	if @StartTime is not null Set @ddbmacmd = @ddbmacmd + ' -b "' + @StartTime + '"'
	if @EndTime is not null Set @ddbmacmd = @ddbmacmd + ' -e "' + @EndTime + '"'
	if @Clean is not null 
	Begin 
		if @Clean = 1 Set @ddbmacmd = @ddbmacmd + ' -c '
	End
	if @DelExpired is not null 
	Begin 
		if @DelExpired = 1 Set @ddbmacmd = @ddbmacmd + ' -r '
	End
	if @Verbose is not null 
	Begin 
		if @Verbose = 1 Set @ddbmacmd = @ddbmacmd + ' -v '
	End
	
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
		-- Check if option to delete expire images was passed
		IF @DelExpired is not null
		BEGIN
		
			-- Check if expired imaged were returned for for deletion
			IF @line LIKE 'Deleting saveset name%'
			BEGIN
				SET @rreturned = 1
			END
			
			-- Check for error messages
			IF @line LIKE 'Failed to delete item%'
			BEGIN
				SET @rcode = 1
			END
			
		END
		
		-- Expired images were requested only for listing
		IF @DelExpired is null
		BEGIN
			-- Check if expired images were returned
			IF @line LIKE 'client%size%retent%'
			BEGIN
				SET @rreturned = 1
			END
						
			-- Check for error messages
			IF @line LIKE '%error%failed%'
			BEGIN
				SET @rcode = 1
			END
		END
		
		-- Print output and process next line
		print @line
		fetch next FROM @cur INTO @line
	end
	close @cur;
	Deallocate @cur;
	
	-- Report if no expired images were returned
	IF @rreturned = 0
		print 'No expired images found';
	
	-- Report if errors were returned
	IF @rcode = 1
		raiserror('An error occured with the backup',16,1)	
END
GO

