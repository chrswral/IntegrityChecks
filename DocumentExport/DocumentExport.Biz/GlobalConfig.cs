using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DocumentExport.Biz.Models;
using log4net;

namespace DocumentExport.Biz
{
    public static class GlobalConfig
    {
        private static readonly ILog _log = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        public static string envisionServerConnectionString { get; private set; }
        public static string documentServerConnectionString { get; private set; }
        public static string documentExportDirectory { get; private set; }
        public static bool AddConnectionString(string connectionString, EnumModel.ServerTypes serverType)
        {
            try
            {
                SqlConnectionStringBuilder sqlConnectionString = new SqlConnectionStringBuilder(connectionString);

                switch (serverType)
                {
                    case EnumModel.ServerTypes.EnvisionServer:
                        envisionServerConnectionString = sqlConnectionString.ConnectionString;
                        break;
                    case EnumModel.ServerTypes.DocumentServer:
                        documentServerConnectionString = sqlConnectionString.ConnectionString;
                        break;
                }
            }
            catch (ArgumentException e)
            {
                return false;
            }
            return true;
        }

        public static bool SetDocumentExportDir(string exportDir)
        {
            //Does the directory exist?
            if (!Directory.Exists(exportDir))
            {
                //try to create it
                try
                {
                    Directory.CreateDirectory(exportDir);
                }
                catch (Exception e)
                {
                    _log.Error($"There has been an error: {e.Message}");
                    return false;
                }
            }
            documentExportDirectory = exportDir;
            return true;
        }
    }
}
