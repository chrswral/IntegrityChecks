using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using SnapshotTool.DB;
using SnapshotTool.DB.Model;

namespace SnapshotTool
{
    public partial class SnapshotTool : Form
    {
        private ServerModel serverModel;
        private DatabaseModel databaseModel;

        public SnapshotTool()
        {
            InitializeComponent();

            this.serverModel = new ServerModel();
            serverModel = GlobalConfig.Connection.GetServerModel(serverModel);

            if(serverModel.CurrentDatabase != "master")
            {
                throw new ArgumentException("Must Be Connected To [master] Database");
            }

            if(!GlobalConfig.Connection.CheckStoredProcsExist(serverModel))
            {
                GlobalConfig.Connection.CreateDatabaseSnapshotProcedure(serverModel);
            }

            WireUpDialoge();
        }

        private void WireUpDialoge()
        {
            valueServerName.Text = serverModel.ServerName;
            valueSqlVersionNo.Text = serverModel.SqlVersionNumber;
            valueCurrentDatabase.Text = serverModel.CurrentDatabase;

            serverModel.Databases = GlobalConfig.Connection.GetDatabase_All(serverModel.Databases).OrderBy(x => x.DatabaseName).ToList();
            cbDatabases.DataSource = serverModel.Databases;
            cbDatabases.DisplayMember = "DatabaseName";
            cbDatabases.ValueMember = "ID";
            cbDatabases.SelectedItem = null;

        }

        private void cbDatabases_SelectionChangeCommitted(object sender, EventArgs e)
        {
            this.databaseModel = (DatabaseModel)cbDatabases.SelectedItem;

            databaseModel.Snapshots = GlobalConfig.Connection.GetSnapshot_All(databaseModel.Snapshots, databaseModel);
        
            dgvSnapshotInfo.AutoGenerateColumns = false;
            var bindingList = new BindingList<DatabaseModel>(databaseModel.Snapshots);
            var source = new BindingSource(bindingList,null);
            dgvSnapshotInfo.DataSource = source;

            btnCreateSnapshot.Enabled = true;
            if(databaseModel.Snapshots.Count() > 0)
            {
                btnRestoreSnapshot.Enabled = true;
                btnDeleteSnapshot.Enabled = true;
            } else
            {
                btnRestoreSnapshot.Enabled = false;
                btnDeleteSnapshot.Enabled = false;
            }
        }

        private void btnCreateSnapshot_Click(object sender, EventArgs e)
        {
            bool restoreFirst = false;

            if(databaseModel.Snapshots.Count() > 0)
            {
                restoreFirst = confirmRestoreSnapshot("Restore To Recent Snapshot First", "Create New Snapshot");
            }

            GlobalConfig.Connection.CreateDatabaseSnapshot(serverModel, databaseModel, restoreFirst);
            cbDatabases_SelectionChangeCommitted(null, null);

        }

        private void btnRebuildSP_Click(object sender, EventArgs e)
        {
            var box = MessageBox.Show("Are You Sure?", "Rebuild Database Stored Procedures", MessageBoxButtons.YesNo);

            if (box == DialogResult.Yes)
            {
                GlobalConfig.Connection.CreateDatabaseSnapshotProcedure(serverModel);
            }
        }

        private bool confirmRestoreSnapshot(string text, string caption)
        {
            bool result = false;
            var box = MessageBox.Show(text, caption, MessageBoxButtons.YesNo);
            if (box == DialogResult.Yes)
            {
                result = true;
            }
            return result;
        }

        private void btnRestoreSnapshot_Click(object sender, EventArgs e)
        {
            if(confirmRestoreSnapshot("Restore to Recent Snapshot","Restore Snapshot"))
            {
                GlobalConfig.Connection.RestoreSnapshot(databaseModel);
            }
            cbDatabases_SelectionChangeCommitted(null, null);
        }

        private void btnDeleteSnapshot_Click(object sender, EventArgs e)
        {
            bool restoreFirst = false;

            if (databaseModel.Snapshots.Count() > 0)
            {
                restoreFirst = confirmRestoreSnapshot("Restore To Recent Snapshot First", "Create New Snapshot");
            }

            GlobalConfig.Connection.RemoveDatabaseSnapshots(databaseModel, restoreFirst);
            cbDatabases_SelectionChangeCommitted(null, null);

        }
    }
}
