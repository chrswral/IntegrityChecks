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
        private enum dialogueActions { Idle, Create, Restore, Delete }
        private enum confirmActions { Yes, No, Cancel };
        private confirmActions? confirmAction;
        private dialogueActions dialogueAction;

        private enum databaseAction
        {
            create, restore, delete
        }
        public SnapshotTool()
        {
            InitializeComponent();

            WireUpDialoge();
        }

        private void WireUpDialoge()
        {
            this.serverModel = new ServerModel();
            this.databaseModel = new DatabaseModel();
            valueServerName.Text = null;
            valueSqlVersionNo.Text = null;
            cbDatabases.DataSource = null;
            labelConfirmMessage.Text = null;

            btnCreateSnapshot.Enabled = false;

            cbDatabases_SelectionChangeCommitted(null, null);
            try
            {
                serverModel = GlobalConfig.Connection.GetServerModel(serverModel);
            } catch (System.Data.SqlClient.SqlException e )
            {
                labelConfirmMessage.Text = $"Cannot Connect to Sql: {e.Message}";
                return;
            }

            if (serverModel.CurrentDatabase != "master")
            {
                throw new ArgumentException("Must Be Connected To [master] Database");
            }

            if (!GlobalConfig.Connection.CheckStoredProcsExist(serverModel))
            {
                GlobalConfig.Connection.CreateDatabaseSnapshotProcedure(serverModel);
            }

            valueServerName.Text = serverModel.ServerName;
            valueSqlVersionNo.Text = serverModel.SqlVersionNumber;

            serverModel.Databases = GlobalConfig.Connection.GetDatabase_All(serverModel.Databases).OrderBy(x => x.DatabaseName).ToList();
            cbDatabases.DataSource = serverModel.Databases;
            cbDatabases.DisplayMember = "DatabaseName";
            cbDatabases.ValueMember = "ID";
            cbDatabases.SelectedItem = null;

        }

        private void cbDatabases_SelectionChangeCommitted(object sender, EventArgs e)
        {
            if((DatabaseModel)cbDatabases.SelectedItem != null)
            {
                this.databaseModel = (DatabaseModel)cbDatabases.SelectedItem;
            

                databaseModel.Snapshots = GlobalConfig.Connection.GetSnapshot_All(databaseModel.Snapshots, databaseModel);
        
                dgvSnapshotInfo.AutoGenerateColumns = false;
                var bindingList = new BindingList<DatabaseModel>(databaseModel.Snapshots);
                var source = new BindingSource(bindingList,null);
                dgvSnapshotInfo.DataSource = source;

                if(databaseModel.Snapshots.Count() > 0)
                {
                    btnCreateSnapshot.Enabled = false;
                    btnRestoreSnapshot.Enabled = true;
                    btnDeleteSnapshot.Enabled = true;
                } else
                {
                    btnCreateSnapshot.Enabled = true;
                    btnRestoreSnapshot.Enabled = false;
                    btnDeleteSnapshot.Enabled = false;
                }
            } else
            {
                dgvSnapshotInfo.Rows.Clear();
                dgvSnapshotInfo.Refresh();
                btnCreateSnapshot.Enabled = false;
                btnRestoreSnapshot.Enabled = false;
                btnDeleteSnapshot.Enabled = false;
            }
        }

        private async void btnCreateSnapshot_Click(object sender, EventArgs e)
        {
            dialogueAction = dialogueActions.Create;

            wireupDialogueActionButtons();

        }

        private void btnRebuildSP_Click(object sender, EventArgs e)
        {
            var box = MessageBox.Show("Are You Sure?", "Rebuild Database Stored Procedures", MessageBoxButtons.YesNo);

            if (box == DialogResult.Yes)
            {
                GlobalConfig.Connection.CreateDatabaseSnapshotProcedure(serverModel);
                confirmFinishedAction();
            }
        }
        private void wireupDialogueActionButtons()
        {
            pnlYesNoCancel.Visible = true;
            btnYes.Enabled = false;
            btnNo.Enabled = false;
            btnCancel.Enabled = false;

            switch (dialogueAction)
            {
                case dialogueActions.Idle:
                    break;
                case dialogueActions.Create:
                    btnYes.Enabled = true;
                    btnNo.Enabled = false;
                    btnCancel.Enabled = true;
                    labelConfirmMessage.Text = "Confirm Create Snapshot?";
                    break;
                case dialogueActions.Restore:
                    btnYes.Enabled = true;
                    btnNo.Enabled = false;
                    btnCancel.Enabled = true;
                    labelConfirmMessage.Text = "Confirm Snapshot Restore?";
                    break;
                case dialogueActions.Delete:
                    btnYes.Enabled = true;
                    btnNo.Enabled = true;
                    btnCancel.Enabled = true;
                    labelConfirmMessage.Text = "Restore Snapshot before deletion?";
                    break;
                default:
                    break;
            }
        }
        private bool? confirmDialogueAction(string text)
        {
            return null;
        }


        private void confirmFinishedAction()
        {
            MessageBox.Show("Finished!");
        }

        private async void btnRestoreSnapshot_Click(object sender, EventArgs e)
        {
            dialogueAction = dialogueActions.Restore;
            wireupDialogueActionButtons();
        }


        private void btnDeleteSnapshot_Click(object sender, EventArgs e)
        {
            dialogueAction = dialogueActions.Delete;
            wireupDialogueActionButtons();
        }

        private async void btnYes_Click(object sender, EventArgs e)
        {
            switch (dialogueAction)
            {
                case dialogueActions.Create:

                    labelActive.Visible = true;
                    labelActive.Text = "Creating Snapshot";
                    await Task.Run(() => { GlobalConfig.Connection.CreateDatabaseSnapshot(serverModel, databaseModel); });
                    labelActive.Visible = false;
                    labelConfirmMessage.Text = null;

                    break;
                case dialogueActions.Restore:
                    labelActive.Visible = true;
                    labelActive.Text = "Restoring Snapshot";
                    await Task.Run(() => { GlobalConfig.Connection.RestoreSnapshot(databaseModel); });
                    labelActive.Visible = false;
                    labelConfirmMessage.Text = null;
                    break;
                case dialogueActions.Delete:

                    labelActive.Visible = true;
                    labelActive.Text = "Deleting Snapshot";
                    await Task.Run(() => { GlobalConfig.Connection.RemoveDatabaseSnapshots(databaseModel, true); });
                    labelActive.Visible = false;
                    labelConfirmMessage.Text = null;
                    break;
            }
            pnlYesNoCancel.Visible = false;
            cbDatabases_SelectionChangeCommitted(null, null);

        }

        private async void btnNo_Click(object sender, EventArgs e)
        {
            switch (dialogueAction)
            {
                case dialogueActions.Delete:
                    labelActive.Visible = true;
                    labelActive.Text = "Deleting Snapshot";
                    await Task.Run(() => { GlobalConfig.Connection.RemoveDatabaseSnapshots(databaseModel, true); });
                    labelActive.Visible = false;

                    break;
            }
            pnlYesNoCancel.Visible = false;
            cbDatabases_SelectionChangeCommitted(null, null);

        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            pnlYesNoCancel.Visible = false;
        }

        private void preferencesToolStripMenuItem_Click(object sender, EventArgs e)
        {
            using (ChangeServer changeServer = new ChangeServer())
            {
                changeServer.ShowDialog();
                if(changeServer.saveClicked)
                {
                    WireUpDialoge();
                }
            }
        }
    }
}
