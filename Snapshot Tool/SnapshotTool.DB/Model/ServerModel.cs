using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SnapshotTool.DB.Model
{
    public class ServerModel
    {
        public string ServerName { get; set; }
        public string SqlVersionNumber { get; set; }
        public string CurrentDatabase { get; set; }
        public List<DatabaseModel> Databases { get; set; } = new List<DatabaseModel>();

       
    }
}
