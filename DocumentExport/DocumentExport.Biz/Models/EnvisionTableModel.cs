using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DocumentExport.Biz.Models
{
    public class EnvisionTableModel
    {
        public string TableName { get; set; }
        public string DatabaseName { get; set; }
        public List<DocumentModel> Documents { get; set; } = new List<DocumentModel>();
        public string path
        {
            get
            {
                return GlobalConfig.documentExportDirectory + @"\" + DatabaseName + @"_" + TableName;
            }
        }
    }
}
