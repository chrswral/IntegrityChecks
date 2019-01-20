using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Dapper;
using SnapshotTool.DB.Model;

namespace SnapshotTool.DB.DataAccess
{
     public class SqlConnector 
    {
        /// <summary>
        /// Gets the Server Information
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public ServerModel GetServerModel(ServerModel model)
        {
            using (IDbConnection connection = new System.Data.SqlClient.SqlConnection(GlobalConfig.CnnString("SnapshotToolSql")))
            {
                model = connection.Query<ServerModel>("SELECT @@SERVERNAME AS ServerName, SERVERPROPERTY('productversion') AS SqlVersionNumber, DB_NAME() AS CurrentDatabase").FirstOrDefault();
            }

            return model;
        }
        /// <summary>
        /// Gets all databases on a server
        /// </summary>
        /// <param name="databases"></param>
        /// <returns></returns>
        public List<DatabaseModel> GetDatabase_All(List<DatabaseModel> databases)
        {
            using (IDbConnection connection = new System.Data.SqlClient.SqlConnection(GlobalConfig.CnnString("SnapshotToolSql")))
            {
                databases = connection.Query<DatabaseModel>(@"
                                                                SELECT
                                                                       databases.name AS databaseName
                                                                     , databases.database_id ID
                                                                     , create_date AS createdDate
                                                                     , backups.last_db_backup_date AS LastBackup
                                                                     , snapshots.count
                                                                FROM       sys.databases
                                                                LEFT JOIN
                                                                     (
                                                                     SELECT
                                                                            CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server
                                                                          , msdb.dbo.backupset.database_name
                                                                          , MAX(msdb.dbo.backupset.backup_finish_date) AS last_db_backup_date
                                                                     FROM   msdb.dbo.backupmediafamily
                                                                     INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id
                                                                     WHERE  msdb..backupset.type = 'D'
                                                                     GROUP BY
                                                                              msdb.dbo.backupset.database_name
                                                                     ) AS backups ON backups.database_name = databases.name
                                                                LEFT JOIN
                                                                     (
                                                                     SELECT
                                                                            source_database_id
                                                                          , COUNT(database_id) AS count
                                                                     FROM   sys.databases
                                                                     WHERE  database_id > 6
                                                                            AND
                                                                            source_database_id IS NOT NULL
                                                                     GROUP BY
                                                                              source_database_id
                                                                     ) AS snapshots ON snapshots.source_database_id = databases.database_id
                                                                WHERE database_id > 6
                                                                      AND
                                                                      databases.source_database_id IS NULL;
                ").ToList();

            }

            return databases;
        }
        /// <summary>
        /// Creates a snapshot of a Database
        /// </summary>
        /// <param name="serverModel"></param>
        /// <param name="databaseModel"></param>
        /// <param name="restoreFirst"></param>
        public void CreateDatabaseSnapshot(ServerModel serverModel, DatabaseModel databaseModel)
        {
            string sql = "usp_createsnapshot";
            
            using (IDbConnection connection = new System.Data.SqlClient.SqlConnection(GlobalConfig.CnnString("SnapshotToolSql")))
            {
                var res = connection.Execute(sql, new { dbname = databaseModel.DatabaseName }, commandType: CommandType.StoredProcedure);
            }

            serverModel.Databases = this.GetDatabase_All(serverModel.Databases);
        }
        /// <summary>
        /// Removes a Database Snapshot
        /// </summary>
        /// <param name="databaseModel"></param>
        /// <param name="restoreFirst"></param>
        public void RemoveDatabaseSnapshots(DatabaseModel databaseModel, bool? restoreFirst)
        {

            using (IDbConnection connection = new System.Data.SqlClient.SqlConnection(GlobalConfig.CnnString("SnapshotToolSql")))
            {
                string sql = @"SELECT name DatabaseName, create_date CreatedDate FROM sys.databases WHERE source_database_id = @ID";
                databaseModel.Snapshots = connection.Query<DatabaseModel>(sql, new { databaseModel.ID }, commandType: CommandType.Text).ToList();
            }

            bool drop = true;

            if(restoreFirst == true)
            {
                this.RestoreSnapshot(databaseModel);
            }

            if(drop)
            {
                using (IDbConnection connection = new System.Data.SqlClient.SqlConnection(GlobalConfig.CnnString("SnapshotToolSql")))
                {
                    foreach (DatabaseModel dbm in databaseModel.Snapshots)
                    {
                        string sql = String.Format("DROP DATABASE [{0}]", dbm.DatabaseName);
                        var res = connection.Execute(sql, commandType: CommandType.Text);

                    }
                }
            }
        }
        /// <summary>
        /// Restores a Database to a Snapshot
        /// </summary>
        /// <param name="databaseModel"></param>
        public void RestoreSnapshot(DatabaseModel databaseModel)
        {
            bool result = false;
            using (IDbConnection connection = new System.Data.SqlClient.SqlConnection(GlobalConfig.CnnString("SnapshotToolSql")))
            {
                string sql1 = String.Format("ALTER DATABASE [{0}] SET SINGLE_USER WITH ROLLBACK IMMEDIATE", databaseModel.DatabaseName);
                string sql2 = String.Format("RESTORE DATABASE [{0}] FROM DATABASE_SNAPSHOT = '{1}'", databaseModel.DatabaseName, databaseModel.Snapshots.FirstOrDefault().DatabaseName);
                string sql3 = String.Format("ALTER DATABASE [{0}] SET MULTI_USER", databaseModel.DatabaseName);

                try
                {
                    var res1 = connection.Execute(sql1, commandType: CommandType.Text);
                    var res2 = connection.Execute(sql2, commandType: CommandType.Text);
                    var res3 = connection.Execute(sql3, commandType: CommandType.Text);
                    result = true;
                }
                catch (Exception ex)
                {

                }
                finally
                {
                    var res3 = connection.Execute(sql3, commandType: CommandType.Text);
                }
            }
        }
        /// <summary>
        /// Creates the Procedure for Creating a Snapshot on master
        /// </summary>
        /// <param name="serverModel"></param>
        public void CreateDatabaseSnapshotProcedure(ServerModel serverModel)
        {
            
            //Check if SP Exists, and drop it if it does.
            if(CheckStoredProcsExist(serverModel))
            {
                string sql = "DROP PROCEDURE usp_createsnapshot";
                using (IDbConnection connection = new System.Data.SqlClient.SqlConnection(GlobalConfig.CnnString("SnapshotToolSql")))
                {
                    connection.Execute(sql);
                }
            }


            using (IDbConnection connection = new System.Data.SqlClient.SqlConnection(GlobalConfig.CnnString("SnapshotToolSql")))
            {
                string sql = @"
                              CREATE PROC [dbo].[usp_createsnapshot] 
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

                              ";
                connection.Execute(sql);
            }
        }
        /// <summary>
        /// Checks if the Create Snapshot Proc Exists
        /// </summary>
        /// <param name="serverModel"></param>
        /// <returns></returns>
        public bool CheckStoredProcsExist(ServerModel serverModel)
        {
            bool res = false;

            using (IDbConnection connection = new System.Data.SqlClient.SqlConnection(GlobalConfig.CnnString("SnapshotToolSql")))
            {
                var query = connection.ExecuteScalar("SELECT name FROM sys.procedures WHERE name = 'usp_createsnapshot'");
                if((string)query == "usp_createsnapshot")
                {
                    res = true;
                }
            }
            return res;
        }
        /// <summary>
        /// Gets a list of Snapshots linked to a Database
        /// </summary>
        /// <param name="snapshots"></param>
        /// <param name="databaseModel"></param>
        /// <returns></returns>
        public List<DatabaseModel> GetSnapshot_All (List<DatabaseModel> snapshots, DatabaseModel databaseModel)
        {
            using (IDbConnection connection = new System.Data.SqlClient.SqlConnection(GlobalConfig.CnnString("SnapshotToolSql")))
            {
                snapshots = connection.Query<DatabaseModel>(@"SELECT
                                                                       databases.name AS DatabaseName
                                                                     , databases.database_id ID
                                                                     , create_date AS CreatedDate
                                                                     , snapshots.count
                                                                FROM       sys.databases
                                                                LEFT JOIN
                                                                     (
                                                                     SELECT
                                                                            CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server
                                                                          , msdb.dbo.backupset.database_name
                                                                          , MAX(msdb.dbo.backupset.backup_finish_date) AS last_db_backup_date
                                                                     FROM   msdb.dbo.backupmediafamily
                                                                     INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id
                                                                     WHERE  msdb..backupset.type = 'D'
                                                                     GROUP BY
                                                                              msdb.dbo.backupset.database_name
                                                                     ) AS backups ON backups.database_name = databases.name
                                                                LEFT JOIN
                                                                     (
                                                                     SELECT
                                                                            source_database_id
                                                                          , COUNT(database_id) AS count
                                                                     FROM   sys.databases
                                                                     WHERE  database_id > 6
                                                                            AND
                                                                            source_database_id IS NOT NULL
                                                                     GROUP BY
                                                                              source_database_id
                                                                     ) AS snapshots ON snapshots.source_database_id = databases.database_id
                                                                WHERE database_id > 6
                                                                      AND
                                                                      databases.source_database_id = @source_database_id", new { source_database_id = databaseModel.ID })?.OrderByDescending(x => x.CreatedDate).ToList();
            }

            return snapshots;
        }
    }
}
