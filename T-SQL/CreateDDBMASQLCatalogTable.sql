-- ==============================================================================================
-- Table:		DDBMASQLCatalog
-- Author:		David Muegge
-- Purpose:		SQL Server Data Domain Boost Scripting Toolkit
--
-- Create date: 20141108
-- Description:	Create DDBMASQLCatalog table to store backup information.
--				
--
-- History:		20150101 - added license information	 
--
--
-- Notes:		Backup information is added to this table by DDBMABackup procedure
--				Use the DDBMACatalog procedure to query and manage this table
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
/****** Object:  Table [dbo].[DDBMASQLCatalog]    Script Date: 11/11/2014 8:27:19 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[DDBMASQLCatalog](
	[ClientHostName] [varchar](50) NULL,
	[BackupLevel] [varchar](10) NULL,
	[BackupSetName] [varchar](100) NULL,
	[BackupSetDescription] [varchar](255) NULL,
	[BackupDate] [datetime] NULL,
	[ExpDate] [datetime] NULL,
	[DDHost] [varchar](50) NULL,
	[DDStorageUnit] [varchar](50) NULL,
	[DatabaseName] [varchar](100) NULL,
	[SQLInstance] [varchar](50) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


