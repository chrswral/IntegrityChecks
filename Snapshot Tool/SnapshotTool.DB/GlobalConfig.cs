using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using SnapshotTool.DB.DataAccess;

namespace SnapshotTool.DB
{
    public static class GlobalConfig
    {
        private static string connectionStringCustom;

        public static SqlConnector Connection { get; private set; }
        private static readonly log4net.ILog log = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        public static void Connect()
        {
            SqlConnector sql = new SqlConnector();
            Connection = sql;
        }

        public static string CnnString(string name)
        {
            if (connectionStringCustom == null)
            {
                return ConfigurationManager.ConnectionStrings[name].ConnectionString;
            }
            else
            {
                return connectionStringCustom;
            }
        }
        public static bool SetCustomCnnString(string connectionString)
        {
            log.Debug($"Entering Method {System.Reflection.MethodBase.GetCurrentMethod().Name}");
            try
            {
                SqlConnectionStringBuilder sqlConnectionString = new SqlConnectionStringBuilder(connectionString);
            } catch (ArgumentException e)
            {
                return false;
            }
            connectionStringCustom = connectionString;
            log.Debug($"Leaving Method {System.Reflection.MethodBase.GetCurrentMethod().Name}");
            return true;
        }

    }
}
