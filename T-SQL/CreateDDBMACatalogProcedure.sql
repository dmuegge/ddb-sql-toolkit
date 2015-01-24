-- ==============================================================================================
-- Procedure:	DDBMACatalog
-- Author:		David Muegge
-- Purpose:		SQL Server Data Domain Boost Scripting Toolkit
--
-- Create date: 20150101
-- Description:	Execute Query or Delete on DDBMASQLCatalog table to return or remove entries
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
IF OBJECT_ID ( 'dbo.DDBMACatalog', 'P' ) IS NOT NULL 
    DROP PROCEDURE dbo.DDBMACatalog;
GO
CREATE PROCEDURE dbo.DDBMACatalog 
	@ClientHost					varchar (50)	= NULL,
	@BackupSetName				varchar (100)	= NULL,
	@DDHost						varchar (50)	= NULL,
	@DDStorageUnit				varchar (50)	= NULL,
	@SQLDatabaseName			varchar (100)   = NULL,	
	@SQLInstanceName 			varchar (50)  	= NULL,
	@BackupTimeStart 			varchar (50)  	= NULL,
	@BackupTimeEnd	 			varchar (50)  	= NULL,
	@BackupExpireStart 			varchar (50)  	= NULL,
	@BackupExpireEnd 			varchar (50)  	= NULL,
	@BackupLevel				varchar (10)	= NULL,
	@DeleteEntries				bit				= NULL
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @SQLCatalogCmd nvarchar(4000);
	declare @wherecount int;
	
	SET @wherecount = 0;
		
	if @DeleteEntries is not null 
	Begin
		-- Base Catalog Delete Command
		SET @SQLCatalogCmd = 'Delete FROM [dbo].[DDBMASQLCatalog]' 
	End
	
	if @DeleteEntries is null 
	Begin
		-- Base Catalog Select Command
		SET @SQLCatalogCmd = 'SELECT [ClientHostName]' +
		  ',[BackupLevel]' +
		  ',[BackupSetName]' +
		  ',[BackupSetDescription]' +
		  ',Concat(Convert(varchar(50),BackupDate, 101),'' '',Convert(varchar(50),BackupDate, 108)) As BackupDate' +
		  ',Concat(Convert(varchar(50),ExpDate, 101),'' '',Convert(varchar(50),ExpDate, 108)) As ExpDate' +
		  ',[DDHost]' +
		  ',[DDStorageUnit]' +
		  ',[DatabaseName]' +
		  ',[SQLInstance]' +
		' FROM [dbo].[DDBMASQLCatalog]' 
	End
	
	-- Optional where clauses
	if @ClientHost is not null 
	Begin
		if @wherecount = 0
		Begin
			SET @SQLCatalogCmd = @SQLCatalogCmd + ' Where ClientHost = ''' + @ClientHost + ''''
			SET @wherecount = 1
		End
		if @wherecount > 0
		Begin
			SET @SQLCatalogCmd = @SQLCatalogCmd + ' and ClientHost = ''' + @ClientHost + ''''
		End
	End
	if @BackupSetName is not null 
	Begin
		if @wherecount = 0
		Begin
			SET @SQLCatalogCmd = @SQLCatalogCmd + ' Where BackupSetName = ''' + @BackupSetName + ''''
			SET @wherecount = 1
		End
		if @wherecount > 0
		Begin
			SET @SQLCatalogCmd = @SQLCatalogCmd + ' and BackupSetName = ''' + @BackupSetName + ''''
		End
	End
	if @DDHost is not null 
	Begin
		if @wherecount = 0
		Begin
			SET @SQLCatalogCmd = @SQLCatalogCmd + ' Where DDHost = ''' + @DDHost + ''''
			SET @wherecount = 1
		End
		if @wherecount > 0
		Begin
			SET @SQLCatalogCmd = @SQLCatalogCmd + ' and DDHost = ''' + @DDHost + ''''
		End
	End
	if @DDStorageUnit is not null 
	Begin
		if @wherecount = 0
		Begin
			SET @SQLCatalogCmd = @SQLCatalogCmd + ' Where DDStorageUnit = ''' + @DDStorageUnit + ''''
			SET @wherecount = 1
		End
		if @wherecount > 0
		Begin
			SET @SQLCatalogCmd = @SQLCatalogCmd + ' and DDStorageUnit = ''' + @DDStorageUnit + ''''
		End
	End
	if @SQLDatabaseName is not null 
	Begin
		if @wherecount = 0
		Begin
			SET @SQLCatalogCmd = @SQLCatalogCmd + ' Where DatabaseName = ''' + @SQLDatabaseName + ''''
			SET @wherecount = 1
		End
		if @wherecount > 0
		Begin
			SET @SQLCatalogCmd = @SQLCatalogCmd + ' and DatabaseName = ''' + @SQLDatabaseName + ''''
		End
	End
	if @SQLInstanceName is not null 
	Begin
		if @wherecount = 0
		Begin
			SET @SQLCatalogCmd = @SQLCatalogCmd + ' Where SQLInstance = ''' + @SQLInstanceName + ''''
			SET @wherecount = 1
		End
		if @wherecount > 0
		Begin
			SET @SQLCatalogCmd = @SQLCatalogCmd + ' and SQLInstance = ''' + @SQLInstanceName + ''''
		End
	End
	if @BackupLevel is not null 
	Begin
		if @wherecount = 0
		Begin
			SET @SQLCatalogCmd = @SQLCatalogCmd + ' Where BackupLevel = ''' + @BackupLevel + ''''
			SET @wherecount = 1
		End
		if @wherecount > 0
		Begin
			SET @SQLCatalogCmd = @SQLCatalogCmd + ' and BackupLevel = ''' + @BackupLevel + ''''
		End
	End
	if (@BackupTimeStart is not null) and (@BackupTimeEnd is not null)
	Begin
		if @wherecount = 0
		Begin
			SET @SQLCatalogCmd = @SQLCatalogCmd + ' Where BackupDate Between ''' + @BackupTimeStart + ''' and ''' + @BackupTimeEnd + ''''
			SET @wherecount = 1
		End
		if @wherecount > 0
		Begin
			SET @SQLCatalogCmd = @SQLCatalogCmd + ' and BackupDate Between ''' + @BackupTimeStart + ''' and ''' + @BackupTimeEnd + ''''
		End
	End
	if (@BackupExpireStart is not null) and (@BackupExpireEnd is not null)
	Begin
		if @wherecount = 0
		Begin
			SET @SQLCatalogCmd = @SQLCatalogCmd + ' Where ExpDate Between ''' + @BackupExpireStart + ''' and ''' + @BackupExpireEnd + ''''
			SET @wherecount = 1
		End
		if @wherecount > 0
		Begin
			SET @SQLCatalogCmd = @SQLCatalogCmd + ' and ExpDate Between ''' + @BackupExpireStart + ''' and ''' + @BackupExpireEnd + ''''
		End
	End
	

	-- Order by clause on select
	if @DeleteEntries is null 
	Begin	
		SET @SQLCatalogCmd = @SQLCatalogCmd + ' Order By BackupDate Desc'
	End
	
	Exec sp_ExecuteSQL @SQLCatalogCmd
	
END
GO