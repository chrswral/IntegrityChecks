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
            try
            {
                SqlConnectionStringBuilder sqlConnectionString = new SqlConnectionStringBuilder(connectionString);
            } catch (ArgumentException e)
            {
                return false;
            }
            connectionStringCustom = connectionString;
            return true;
        }

    }
}
