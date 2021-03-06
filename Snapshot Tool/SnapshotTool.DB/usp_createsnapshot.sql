

USE [master];
GO
/****** Object:  StoredProcedure [dbo].[usp_createsnapshot]    Script Date: 17/01/2019 09:19:52 ******/

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO
-- =============================================
-- Author:  Mark Broadbent, SQLCloud Limited
-- Twitter: https://twitter.com/retracement
-- Email: mark.broadbent@sqlcloud.co.uk
-- Create date: 13/02/2007
-- Last updated date: 27/04/2014
-- Description: Procedure usp_createsnapshot creates an automatic snapshot on specified database
-- Version: 0.92
-- Dependencies: NONE
-- Notes: Has been tested against all versions of SQL from 2005 up to 2014. Please be aware that Database Snapshot technology is an Enterprise only feature.
-- =============================================
CREATE OR ALTER PROC [dbo].[usp_createsnapshot] 
@dbname sysname='', --required option (database to create snapshot on)
    @pathoverride VARCHAR(255)='', --path to override snapshot files location (to be implemented)
    @noexecute bit=0, --optional option, when set to 1 snapshot script will not be executed and only output creation statements.
    @snapshotname sysname='' OUTPUT, --generated snapshot name, output parameter
    @help bit=0 --optional option (view help)
AS
SET NOCOUNT ON;

IF @help=1
BEGIN
PRINT 'Help Specified.';
GOTO printoptions;
END;

IF @dbname NOT IN(SELECT name FROM master.sys.databases) OR LEN(@dbname)=0
BEGIN
PRINT 'Warning! Database ['+@dbname+'] specified cannot be found.';
GOTO printoptions;
END;

IF @dbname IN('master', 'model', 'tempdb')
BEGIN
PRINT 'snapshot creation on database ['+@dbname+'] is not allowed.';
GOTO printoptions;
END;

DECLARE @now DATETIME;
DECLARE @ssname SYSNAME;
DECLARE @cmd VARCHAR(MAX);
DECLARE @uniqueid sysname;
SET @now=GETDATE();
 
--create a unique name that we will use in the snapshot name
--and within each datafile to avoid conflict with others
SET @uniqueid=REPLACE(STR(DATEPART(yyyy, @now), 4)+STR(DATEPART(mm, @now), 2)+STR(DATEPART(dd, @now), 2)+STR(DATEPART(hh, @now), 2)+STR(DATEPART(mi, @now), 2)+STR(DATEPART(ss, @now), 2), ' ', '0');
 
--dbname becomes __SX
SET @ssname=@dbname+'_'+@uniqueid+'_SX';

SET @cmd='CREATE DATABASE ['+@ssname+'] ON ';

--loop through datafiles and assign a unique name
SELECT @cmd=@cmd+CHAR(10)+'(NAME = '''+RTRIM(name)+''', FILENAME = '''+RTRIM(physical_name)+@uniqueid+'_sx''),' FROM sys.master_files WHERE type<>1 -- ignore logfile since snapshots do not create one
    AND database_id=db_id(@dbname);
SET @cmd=LEFT(@cmd, LEN(@cmd)-1); --take away extra trailing comma left from SELECT file assignment
SET @cmd=@cmd+CHAR(10)+' AS SNAPSHOT OF ['+@dbname+']'; --complete statement
PRINT @cmd;
IF @noexecute=0
BEGIN
PRINT '-- Script execution specified...';
BEGIN TRY
EXEC (@cmd);
PRINT 'Snapshot Database '+@ssname+' created from '+@dbname;
END TRY
BEGIN CATCH
PRINT 'Snapshot creation failed ('+ERROR_MESSAGE()+')';
END CATCH;
END;
ELSE
BEGIN
PRINT '-- Script execution overridden. Run this output to create.';
END;

SET @snapshotname=@ssname;
RETURN;
printoptions:
SET @snapshotname=NULL;
PRINT '    @dbname sysname = '''', --required option (database to create snapshot on)
    @pathoverride VARCHAR(255) = '''', --path to override snapshot files location (to be implemented)
    @noexecute bit = 0, --optional option, when set to 1 snapshot script will not be executed and only output creation statements.
    @snapshotname sysname = '''' OUTPUT, --generated snapshot name, output parameter
    @help bit = 0 --optional option (view help)
======================================================
';
