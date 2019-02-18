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
        public List<DatabaseModel> Snapshots
        {
            get
            {
                if(_snapshots == null)
                {
                    return new List<DatabaseModel>();
                } else
                {
                    return _snapshots;
                }
            }

            set
            {
                _snapshots = value;
            }

        }
        private List<DatabaseModel> _snapshots;
        public int count { get; set; }

    }
}
