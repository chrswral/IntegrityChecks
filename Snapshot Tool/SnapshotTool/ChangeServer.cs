using SnapshotTool.DB;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace SnapshotTool
{
    public partial class ChangeServer : Form
    {
        private string connString { get; set; }

        private SqlConnectionStringBuilder sql;

        public bool saveClicked;
        public ChangeServer()
        {
            InitializeComponent();

            this.sql = new SqlConnectionStringBuilder(ConfigurationManager.ConnectionStrings["SnapshotToolSql"].ConnectionString);

            int selected;

            switch (sql.Authentication)
            {
                case SqlAuthenticationMethod.NotSpecified:
                    selected = 0;
                    break;
                case SqlAuthenticationMethod.SqlPassword:
                    selected = 1;
                    break;
                case SqlAuthenticationMethod.ActiveDirectoryPassword:
                    selected = 0;
                    break;
                case SqlAuthenticationMethod.ActiveDirectoryIntegrated:
                    selected = 0;
                    break;
                default:
                    selected = 0;
                    break;
            }

            boxAuthMethod.SelectedIndex = selected;

            boxUsername.Text = sql.UserID.ToString();
            boxPassword.Text = sql.Password.ToString();
            boxServer.Text = sql.DataSource;
            

        }

        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            if(boxAuthMethod.SelectedIndex == 0)
            {
                sql.IntegratedSecurity = true;
                boxUsername.Enabled = false;
                boxPassword.Enabled = false;
            }
            if(boxAuthMethod.SelectedIndex == 1)
            {
                sql.IntegratedSecurity = false;
                boxUsername.Enabled = true;
                boxPassword.Enabled = true;
            }
        }

        private void btnValidate_Click(object sender, EventArgs e)
        {
            this.sql.DataSource = boxServer.Text;
            this.sql.UserID = boxUsername.Text;
            this.sql.Password = boxPassword.Text;
            GlobalConfig.SetCustomCnnString(sql.ConnectionString);
            saveClicked = true;
            this.Close();
        }
    }
}
