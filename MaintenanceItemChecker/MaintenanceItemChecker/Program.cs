using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MaintenanceItemChecker
{
    class Program
    {
        private static string path
        {
            get
            {
                if(_path == null)
                {
                    if (ConfigurationManager.AppSettings["ExportFolderLocation"].ToString() == string.Empty)
                    {
                        _path = AppDomain.CurrentDomain.BaseDirectory + $"MaintenanceItemReport_{DateTime.UtcNow.ToFileTime()}.xlsx";
                    }
                    else
                    {
                        _path = ConfigurationManager.AppSettings["ExportFolderLocation"].ToString() + $"MaintenanceItemReport_{DateTime.UtcNow.ToFileTime()}.xlsx";
                    }
                }
                return _path;
            }
        }
        private static string _path;
        private static readonly log4net.ILog log = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
    
        static void Main(string[] args)
        {
            try
            {

                log.Info("Starting Process");
                Db.SetConnectionString();
                Db.Connect();

                var workbook = new Excel(path);

                List<string> aircraftList = new List<string>();

                using (DataTable dt = Db.SqlAdapter.GetAircraft())
                {

                    for (int i = 0; i < dt.DefaultView.Count; i++)
                    {
                        int ID = int.Parse(dt.DefaultView[i]["ID"].ToString());
                        string Reg = dt.DefaultView[i]["Reg"].ToString();
                        aircraftList.Add(Reg);
                        try
                        {
                            using (DataTable miData = Db.SqlAdapter.GetData(ID))
                            {
                                workbook.AddWorkSheetData(miData, Reg);
                            }
                        } catch (Exception ex)
                        {
                            log.Error($"Error: {ex.Message} - {ex.InnerException}");
                        }
                    }
                }
                if (ConfigurationManager.AppSettings["SendEmail"] == "true")
                {
                    Email email = new Email();
                    email.SendStatus(path, aircraftList);
                }
                //To Do
                if (ConfigurationManager.AppSettings["SendFtp"] == "true")
                {
                    SendFtp ftp = new SendFtp(path);
                }

                log.Info("Completed");
            }
            catch (Exception ex)
            {
                log.Error($"Error: {ex.Message} - {ex.InnerException}");
            }
        }
    }
}
