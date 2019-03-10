using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MaintenanceItemChecker
{
    public static class Db
    {
        private static readonly log4net.ILog log = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        public static string ConnectionString { get; private set; }
        public static SqlAdapter SqlAdapter;

        public static void Connect()
        {
            log.Info("Create SQL Adapter");
            SqlAdapter = new SqlAdapter(ConnectionString);
        }

        public static void SetConnectionString()
        {
            log.Info("Set Connection String");
            ConnectionString = System.Configuration.ConfigurationManager.ConnectionStrings["Sql"].ConnectionString;
        }
        public static void SetConnectionString(string connectionString)
        {
            log.Info("Set Connection String");
            ConnectionString = connectionString;
        }
    }
}
