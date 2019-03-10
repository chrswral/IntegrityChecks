using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MaintenanceItemChecker
{
    public class SqlAdapter
    {
        private string connectionString;
        private static readonly log4net.ILog log = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        public SqlAdapter(string connectionString)
        {
            log.Info("Create SQL Adapter");
            this.connectionString = connectionString;
        }

        public DataTable GetData(int tReg_ID)
        {
            log.Info($"Get Maint Item Data for tReg_ID: {tReg_ID}");
            var dt = new DataTable();
            using(SqlConnection dbConnection = new SqlConnection(connectionString))
            {
                var cmd = new SqlCommand() { CommandType = CommandType.StoredProcedure, Connection = dbConnection, CommandText = "sptCheckLogicalMaintenanceItemConfiguration", CommandTimeout = 600 };
                cmd.Parameters.Add(new SqlParameter() { ParameterName = "tReg_ID", Value = tReg_ID });
                dbConnection.Open();
                try
                {
                    var res = cmd.ExecuteReader();

                    dt.Load(res);
                    log.Info($"Database Returned {dt.Rows.Count} Rows");
                } catch(SqlException ex)
                {
                    throw ex;
                }
            }
            return dt;
        }
        public DataTable GetAircraft()
        {
            log.Info("Get Reg Details");
            var dt = new DataTable();
            using (SqlConnection dbConnection = new SqlConnection(connectionString))
            {
                int limit;
                int.TryParse(ConfigurationManager.AppSettings["aircraftLimit"], out limit);
                string TopString = string.Empty;
                if(limit > 0)
                {
                    TopString = $"TOP {limit} ";
                }
                
                string sql = $"SELECT {TopString}tReg.ID, Reg FROM tReg JOIN tRegStatus ON tReg.tRegStatus_ID = tRegStatus.ID AND tRegStatus.Active = 1";
                var cmd = new SqlCommand() { CommandType = CommandType.Text, Connection = dbConnection, CommandText = sql };
                dbConnection.Open();
                var res = cmd.ExecuteReader();
                dt.Load(res);
            }
            return dt;
        }
        public Dictionary<string,string> GetEmailConfig()
        {
            log.Info("Get Email Config");
            Dictionary<string, string> dictionary = new Dictionary<string, string>();
            using (SqlConnection dbConnection = new SqlConnection(connectionString))
            {
                string sql = "SELECT ConfigName, ConfigValue FROM uRALConfig WHERE ConfigName IN ('SMTPMailServer', 'SMTPMailLogin', 'SMTPMailPassword', 'SupportMailAddress')";
                var cmd = new SqlCommand() { CommandType = CommandType.Text, Connection = dbConnection, CommandText = sql };
                dbConnection.Open();
                var res = cmd.ExecuteReader();
                while(res.Read())
                {
                    dictionary.Add(res.GetString(0), res.GetString(1));
                }
            }

            return dictionary;
        }
    }
}
