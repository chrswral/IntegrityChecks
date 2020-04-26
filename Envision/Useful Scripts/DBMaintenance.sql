  
ALTER  PROCEDURE sup.DBMaintenance  
(@DoIt int = 0
, @Database varchar(200) = '')
AS  
  
BEGIN  

SET NOCOUNT ON  
  
SELECT ROW_NUMBER() OVER (ORDER BY name) ID, name DB   
INTO #RusDatabases  
FROM sys.databases
WHERE (name = @Database OR  @Database= 'ALL')
AND (name LIKE 'RAL%' OR name LIKE 'ENV%')
 
  
DECLARE @dbCount int = (SELECT COUNT(*) FROM #RusDatabases)  
DECLARE @i int = 1  
DECLARE @sql nvarchar(max) = ''  
DECLARE @db varchar(100) = ''  
CREATE TABLE ##RusResults (DB varchar(100), Result varchar(max))  
  
IF @DoIt = 1
BEGIN  
	WHILE @i <= @dbCount  
	BEGIN  
  
	 BEGIN TRY  
  
	  SET @db = (SELECT DB FROM #RusDatabases WHERE ID = @i)  

	  SET @sql = N'USE ['+@db+']; 
	  
	  IF (SELECT COUNT(*) FROM uRALStatisticsQuery) > 0
	  BEGIN 
		TRUNCATE TABLE uRALStatisticsQuery 
		INSERT INTO ##RusResults SELECT '''+@db+''', ''TRUNCATED uRALStatisticsQuery ''
	  END
	  
	  ;'  
	  EXEC sp_sqlexec @sql  

	  SET @sql = N'USE ['+@db+']; 
	  
	  IF (SELECT COUNT(*) FROM tDocumentVersion) > 0
	  BEGIN 
		TRUNCATE TABLE tDocumentVersion 
		INSERT INTO ##RusResults SELECT '''+@db+''', ''TRUNCATED tDocumentVersion ''
	  END
	  
	  ;'   
	  EXEC sp_sqlexec @sql  
 
	  SET @sql = N'USE ['+@db+']; 
	  
	  IF (SELECT COUNT(*) FROM tDocument) > 0
	  BEGIN 
		USE [master];
		EXEC sup.DropFKs '+@db+', ''tDocument''

	    USE ['+@db+'];

		TRUNCATE TABLE tDocument 
		INSERT INTO ##RusResults SELECT '''+@db+''', ''TRUNCATED tDocument ''
	  END
	  
	  ;'  
	  EXEC sp_sqlexec @sql  

	  SET @sql = N'USE master; ALTER DATABASE ['+@db+'] SET RECOVERY SIMPLE WITH NO_WAIT ;'  
	  EXEC sp_sqlexec @sql  

	  SET @sql = N'USE ['+@db+']; 
	  
	  IF (SELECT COUNT(*) FROM ##RusResults WHERE DB = '''+@db+''') > 0
	  BEGIN 
		CHECKPOINT;
	    DBCC SHRINKDATABASE ('+@db+');
		INSERT INTO ##RusResults SELECT '''+@db+''', ''SHRINK DATABASE ''
	  END
	  
	  ;'  
	  EXEC sp_sqlexec @sql  
	  --PRINT @sql
 


	 END TRY  
	 BEGIN CATCH  

	
		SET @sql = N'INSERT INTO ##RusResults SELECT '''+@db+''', '''+REPLACE(ERROR_MESSAGE(),'''','') +''''
		EXEC sp_sqlexec @sql  
		PRINT @sql
    
	 END CATCH  
  
	 SET @i = @i+1  
  
	END  
END
  
SELECT * FROM ##RusResults  
  
DROP TABLE #RusDatabases  
DROP TABLE ##RusResults  
  
END;  

GO; 

ALTER PROCEDURE sup.DropFKs
(@db varchar(200),
@Table varchar(200))
AS
BEGIN

SET NOCOUNT ON

DECLARE @FKCount int = ''
, @i int = 1  
, @sql nvarchar(max) = ''  
, @FK varchar(200) = ''
, @TableName varchar(200) = ''


SET @sql = N'USE ['+@db+'];

SELECT 
   ROW_NUMBER() OVER (ORDER BY f.name) ID,
   OBJECT_NAME(f.parent_object_id) TableName,
   f.name
INTO ##FKs
FROM sys.foreign_keys AS f
INNER JOIN sys.foreign_key_columns AS fc ON f.OBJECT_ID = fc.constraint_object_id
INNER JOIN sys.tables t ON t.OBJECT_ID = fc.referenced_object_id
WHERE    OBJECT_NAME (f.referenced_object_id) = '''+@Table+''''


EXEC sp_sqlexec @sql 


SET @FKCount  = (SELECT COUNT(*) FROM ##FKs) 

WHILE @i <= @FKCount  
BEGIN  

	  SELECT  @FK = name , @TableName = TableName
	  FROM ##FKs WHERE ID = @i

	  SET @sql = N'USE ['+@db+']; 
	  
	  ALTER TABLE [dbo].['+@TableName+'] DROP CONSTRAINT ['+@FK+']
	  
	  ;'  
	  PRINT @sql
	  EXEC sp_sqlexec @sql  

	SET @i = @i+1  
END

DROP TABLE ##FKs

END