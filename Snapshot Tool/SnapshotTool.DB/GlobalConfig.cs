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

        public static SqlConnector Connection { get; private set; }
        
        public static void Connect()
        {
            SqlConnector sql = new SqlConnector();
            Connection = sql;
        }

        public static string CnnString(string name)
        {
            return ConfigurationManager.ConnectionStrings[name].ConnectionString; 
        }
    }
}
