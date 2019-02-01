using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SnapshotTool.DB.Model
{
    public class DatabaseModel
    {
        public string DatabaseName { get; set; }
        public int ID { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime LastBackup { get; set; }
        public List<DatabaseModel> Snapshots { get; set; }
        public int count { get; set; }
    }
}
