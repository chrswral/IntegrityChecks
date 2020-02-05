DECLARE @SearchPattern NVARCHAR(128), @incjob BIT;
SET @SearchPattern = '%%';
SET @incjob = 0; --Set to 0 to ignore jobs

/*Creates list of all tables and associated columns

to do easy multi-column comparisons with a like.*/

DECLARE @tabletbl TABLE
(objectid     INT, 
 tablename    VARCHAR(MAX), 
 tabletype    VARCHAR(5), 
 tablecolumns VARCHAR(MAX)
);
INSERT INTO @tabletbl
       SELECT o.[object_id], 
              o.name, 
              o.[type], 
              STUFF(
       (
           SELECT ',' + c.Name AS [text()]
           FROM sys.columns c
           WHERE c.[object_id] = o.[object_id] FOR XML PATH('')
       ), 1, 1, '') AS TableColumns
       FROM sys.objects o
       WHERE o.[type] IN
       ('S' --System Tables

       , 'U' --User Tables

       , 'V'
       );  --Views

/*****************Table column creation end*****************/

DECLARE @jobtbl TABLE
([schema] VARCHAR(20), 
 name     VARCHAR(MAX), 
 [type]   VARCHAR(5), 
 FullName VARCHAR(MAX), 
 [Source] NVARCHAR(MAX)
);
IF @incjob = 1
    BEGIN
        INSERT INTO @jobtbl
               SELECT 'job' AS [Schema], 
                      name AS Name, 
                      'J' 'Type', 
                      name 'FullName', 
                      sjs.command 'Source'
               FROM msdb.dbo.sysjobs s
                    INNER JOIN msdb.dbo.sysjobsteps sjs ON sjs.job_id = s.job_id
               WHERE sjs.command LIKE LOWER(@SearchPattern)
                     OR s.[name] LIKE LOWER(@SearchPattern);
END;
SELECT SCHEMA_NAME(o.schema_id) AS [schema], 
       o.[name] COLLATE DATABASE_DEFAULT AS Name, 
       o.[type] COLLATE DATABASE_DEFAULT AS [Type], 
       '[' + SCHEMA_NAME(o.schema_id) + '].[' + o.[name] + ']' AS FullName,
       CASE
           WHEN o.[type] IN('U', 'S')
           THEN t.tablecolumns
           ELSE OBJECT_DEFINITION(o.object_id)
       END AS [Source], 
       @SearchPattern AS [SearchPattern]
FROM sys.objects AS o
     LEFT JOIN @tabletbl AS t ON t.[objectid] = o.[object_id]
WHERE(LOWER(OBJECT_DEFINITION(o.object_id)) LIKE LOWER(@SearchPattern)
      OR (t.tablecolumns LIKE LOWER(@SearchPattern)
          OR t.tablename LIKE LOWER(@Searchpattern)))
     AND o.[type] IN
('C', --- = Check constraint

     'D', --- = Default (constraint or stand-alone)

     'P', --- = SQL stored procedure

     'FN', --- = SQL scalar function

     'R', --- = Rule

     'RF', --- = Replication filter procedure

     'TR', --- = SQL trigger

     'IF', --- = SQL inline table-valued function

     'TF', --- = SQL table-valued function

     'U', --- = User Table

     'S', --- = System Table

     'V'
) --- = View

UNION ALL
SELECT *, 
       @SearchPattern
FROM @jobtbl
ORDER BY 3;