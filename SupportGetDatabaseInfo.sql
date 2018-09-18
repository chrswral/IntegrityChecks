--CREATE VIEW
--sup.GetDatabaseInfo
--AS

SELECT  name as Name,
        (CAST(SUM(cast(size as float)) / 1024 / 1024 AS DECIMAL(10,2))) as SizeGB
        , max_size
        ,(SELECT Left(@@Version,55)) as SQLVersion
        ,(SELECT cores_per_socket FROM sys.dm_os_sys_info) as CoresPerSocket
        ,(SELECT cpu_count FROM sys.dm_os_sys_info) as CPUCount
        ,(SELECT physical_memory_kb FROM sys.dm_os_sys_info) as PhysicalMemoryKB


-------------------Last Backup-------------------
SELECT sdb.Name AS DatabaseName,
COALESCE(CONVERT(VARCHAR(12), MAX(bus.backup_finish_date), 101),'-') AS LastBackUpTime
FROM sys.sysdatabases sdb
LEFT OUTER JOIN msdb.dbo.backupset bus ON bus.database_name = sdb.name
GROUP BY sdb.Name


-------------------Maintainence Plans-------------------
select 
	p.name as 'Maintenance Plan'
	,p.[description] as 'Description'
	,p.[owner] as 'Plan Owner'
	,sp.subplan_name as 'Subplan Name'
	,sp.subplan_description as 'Subplan Description'
	,j.name as 'Job Name'
	,j.[description] as 'Job Description'  
from msdb..sysmaintplan_plans p
	inner join msdb..sysmaintplan_subplans sp
	on p.id = sp.plan_id
	inner join msdb..sysjobs j
	on sp.job_id = j.job_id
where j.[enabled] = 1


-------------------Envision Version-------------------
select top 1 DatabaseVersion,LastUpdated from uRALDatabaseInfo order by ID desc



