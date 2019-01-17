namespace SnapshotTool
{
    partial class SnapshotTool
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle3 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle4 = new System.Windows.Forms.DataGridViewCellStyle();
            this.labelServerName = new System.Windows.Forms.Label();
            this.valueServerName = new System.Windows.Forms.Label();
            this.valueSqlVersionNo = new System.Windows.Forms.Label();
            this.labelSqlVersionNo = new System.Windows.Forms.Label();
            this.valueCurrentDatabase = new System.Windows.Forms.Label();
            this.labelCurrentDatabase = new System.Windows.Forms.Label();
            this.cbDatabases = new System.Windows.Forms.ComboBox();
            this.labelDatabaseName = new System.Windows.Forms.Label();
            this.backgroundWorker1 = new System.ComponentModel.BackgroundWorker();
            this.btnCreateSnapshot = new System.Windows.Forms.Button();
            this.btnRebuildSP = new System.Windows.Forms.Button();
            this.CreatedDate = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.DatabaseName = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.dgvSnapshotInfo = new System.Windows.Forms.DataGridView();
            this.btnRestoreSnapshot = new System.Windows.Forms.Button();
            this.btnDeleteSnapshot = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.dgvSnapshotInfo)).BeginInit();
            this.SuspendLayout();
            // 
            // labelServerName
            // 
            this.labelServerName.AutoSize = true;
            this.labelServerName.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.labelServerName.Location = new System.Drawing.Point(8, 10);
            this.labelServerName.Name = "labelServerName";
            this.labelServerName.Size = new System.Drawing.Size(76, 13);
            this.labelServerName.TabIndex = 0;
            this.labelServerName.Text = "Server Name:";
            // 
            // valueServerName
            // 
            this.valueServerName.AutoSize = true;
            this.valueServerName.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.valueServerName.Location = new System.Drawing.Point(84, 10);
            this.valueServerName.Name = "valueServerName";
            this.valueServerName.Size = new System.Drawing.Size(77, 13);
            this.valueServerName.TabIndex = 1;
            this.valueServerName.Text = "_ServerName_";
            // 
            // valueSqlVersionNo
            // 
            this.valueSqlVersionNo.AutoSize = true;
            this.valueSqlVersionNo.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.valueSqlVersionNo.Location = new System.Drawing.Point(269, 10);
            this.valueSqlVersionNo.Name = "valueSqlVersionNo";
            this.valueSqlVersionNo.Size = new System.Drawing.Size(86, 13);
            this.valueSqlVersionNo.TabIndex = 3;
            this.valueSqlVersionNo.Text = "_SqlVersionNo_";
            // 
            // labelSqlVersionNo
            // 
            this.labelSqlVersionNo.AutoSize = true;
            this.labelSqlVersionNo.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.labelSqlVersionNo.Location = new System.Drawing.Point(179, 10);
            this.labelSqlVersionNo.Name = "labelSqlVersionNo";
            this.labelSqlVersionNo.Size = new System.Drawing.Size(90, 13);
            this.labelSqlVersionNo.TabIndex = 2;
            this.labelSqlVersionNo.Text = "SQL Version No:";
            // 
            // valueCurrentDatabase
            // 
            this.valueCurrentDatabase.AutoSize = true;
            this.valueCurrentDatabase.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.valueCurrentDatabase.Location = new System.Drawing.Point(479, 10);
            this.valueCurrentDatabase.Name = "valueCurrentDatabase";
            this.valueCurrentDatabase.Size = new System.Drawing.Size(104, 13);
            this.valueCurrentDatabase.TabIndex = 5;
            this.valueCurrentDatabase.Text = "_CurrentDatabase_";
            // 
            // labelCurrentDatabase
            // 
            this.labelCurrentDatabase.AutoSize = true;
            this.labelCurrentDatabase.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.labelCurrentDatabase.Location = new System.Drawing.Point(373, 10);
            this.labelCurrentDatabase.Name = "labelCurrentDatabase";
            this.labelCurrentDatabase.Size = new System.Drawing.Size(100, 13);
            this.labelCurrentDatabase.TabIndex = 4;
            this.labelCurrentDatabase.Text = "Current Database:";
            // 
            // cbDatabases
            // 
            this.cbDatabases.Font = new System.Drawing.Font("Segoe UI", 10F);
            this.cbDatabases.FormattingEnabled = true;
            this.cbDatabases.Location = new System.Drawing.Point(123, 35);
            this.cbDatabases.Name = "cbDatabases";
            this.cbDatabases.Size = new System.Drawing.Size(209, 25);
            this.cbDatabases.TabIndex = 6;
            this.cbDatabases.SelectionChangeCommitted += new System.EventHandler(this.cbDatabases_SelectionChangeCommitted);
            // 
            // labelDatabaseName
            // 
            this.labelDatabaseName.AutoSize = true;
            this.labelDatabaseName.Font = new System.Drawing.Font("Segoe UI", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.labelDatabaseName.Location = new System.Drawing.Point(12, 38);
            this.labelDatabaseName.Name = "labelDatabaseName";
            this.labelDatabaseName.Size = new System.Drawing.Size(105, 17);
            this.labelDatabaseName.TabIndex = 7;
            this.labelDatabaseName.Text = "Database Name:";
            // 
            // btnCreateSnapshot
            // 
            this.btnCreateSnapshot.Enabled = false;
            this.btnCreateSnapshot.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnCreateSnapshot.Location = new System.Drawing.Point(11, 184);
            this.btnCreateSnapshot.Name = "btnCreateSnapshot";
            this.btnCreateSnapshot.Size = new System.Drawing.Size(166, 46);
            this.btnCreateSnapshot.TabIndex = 9;
            this.btnCreateSnapshot.Text = "Create Snapshot";
            this.btnCreateSnapshot.UseVisualStyleBackColor = true;
            this.btnCreateSnapshot.Click += new System.EventHandler(this.btnCreateSnapshot_Click);
            // 
            // btnRebuildSP
            // 
            this.btnRebuildSP.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnRebuildSP.Location = new System.Drawing.Point(11, 412);
            this.btnRebuildSP.Name = "btnRebuildSP";
            this.btnRebuildSP.Size = new System.Drawing.Size(150, 26);
            this.btnRebuildSP.TabIndex = 10;
            this.btnRebuildSP.Text = "Rebuild Stored Proc";
            this.btnRebuildSP.UseVisualStyleBackColor = true;
            this.btnRebuildSP.Click += new System.EventHandler(this.btnRebuildSP_Click);
            // 
            // CreatedDate
            // 
            this.CreatedDate.DataPropertyName = "CreatedDate";
            this.CreatedDate.HeaderText = "Created Date";
            this.CreatedDate.Name = "CreatedDate";
            // 
            // DatabaseName
            // 
            this.DatabaseName.DataPropertyName = "DatabaseName";
            this.DatabaseName.HeaderText = "Snapshot Name";
            this.DatabaseName.Name = "DatabaseName";
            this.DatabaseName.ReadOnly = true;
            // 
            // dgvSnapshotInfo
            // 
            this.dgvSnapshotInfo.AllowUserToAddRows = false;
            this.dgvSnapshotInfo.AllowUserToDeleteRows = false;
            this.dgvSnapshotInfo.AllowUserToResizeRows = false;
            this.dgvSnapshotInfo.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.dgvSnapshotInfo.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.Fill;
            this.dgvSnapshotInfo.BackgroundColor = System.Drawing.SystemColors.Control;
            dataGridViewCellStyle3.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle3.BackColor = System.Drawing.SystemColors.Control;
            dataGridViewCellStyle3.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            dataGridViewCellStyle3.ForeColor = System.Drawing.SystemColors.WindowText;
            dataGridViewCellStyle3.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle3.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle3.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.dgvSnapshotInfo.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle3;
            this.dgvSnapshotInfo.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvSnapshotInfo.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.DatabaseName,
            this.CreatedDate});
            this.dgvSnapshotInfo.GridColor = System.Drawing.SystemColors.Control;
            this.dgvSnapshotInfo.Location = new System.Drawing.Point(11, 66);
            this.dgvSnapshotInfo.Name = "dgvSnapshotInfo";
            dataGridViewCellStyle4.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle4.BackColor = System.Drawing.SystemColors.Control;
            dataGridViewCellStyle4.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            dataGridViewCellStyle4.ForeColor = System.Drawing.SystemColors.WindowText;
            dataGridViewCellStyle4.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle4.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle4.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.dgvSnapshotInfo.RowHeadersDefaultCellStyle = dataGridViewCellStyle4;
            this.dgvSnapshotInfo.RowHeadersVisible = false;
            this.dgvSnapshotInfo.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvSnapshotInfo.Size = new System.Drawing.Size(777, 112);
            this.dgvSnapshotInfo.TabIndex = 8;
            // 
            // btnRestoreSnapshot
            // 
            this.btnRestoreSnapshot.Enabled = false;
            this.btnRestoreSnapshot.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnRestoreSnapshot.Location = new System.Drawing.Point(207, 184);
            this.btnRestoreSnapshot.Name = "btnRestoreSnapshot";
            this.btnRestoreSnapshot.Size = new System.Drawing.Size(166, 46);
            this.btnRestoreSnapshot.TabIndex = 11;
            this.btnRestoreSnapshot.Text = "Restore Snapshot";
            this.btnRestoreSnapshot.UseVisualStyleBackColor = true;
            this.btnRestoreSnapshot.Click += new System.EventHandler(this.btnRestoreSnapshot_Click);
            // 
            // btnDeleteSnapshot
            // 
            this.btnDeleteSnapshot.Enabled = false;
            this.btnDeleteSnapshot.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnDeleteSnapshot.Location = new System.Drawing.Point(403, 184);
            this.btnDeleteSnapshot.Name = "btnDeleteSnapshot";
            this.btnDeleteSnapshot.Size = new System.Drawing.Size(166, 46);
            this.btnDeleteSnapshot.TabIndex = 12;
            this.btnDeleteSnapshot.Text = "Delete Snapshot";
            this.btnDeleteSnapshot.UseVisualStyleBackColor = true;
            this.btnDeleteSnapshot.Click += new System.EventHandler(this.btnDeleteSnapshot_Click);
            // 
            // SnapshotTool
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(800, 450);
            this.Controls.Add(this.btnDeleteSnapshot);
            this.Controls.Add(this.btnRestoreSnapshot);
            this.Controls.Add(this.btnRebuildSP);
            this.Controls.Add(this.btnCreateSnapshot);
            this.Controls.Add(this.dgvSnapshotInfo);
            this.Controls.Add(this.labelDatabaseName);
            this.Controls.Add(this.cbDatabases);
            this.Controls.Add(this.valueCurrentDatabase);
            this.Controls.Add(this.labelCurrentDatabase);
            this.Controls.Add(this.valueSqlVersionNo);
            this.Controls.Add(this.labelSqlVersionNo);
            this.Controls.Add(this.valueServerName);
            this.Controls.Add(this.labelServerName);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.Name = "SnapshotTool";
            this.Text = "Snapshot Tool";
            ((System.ComponentModel.ISupportInitialize)(this.dgvSnapshotInfo)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label labelServerName;
        private System.Windows.Forms.Label valueServerName;
        private System.Windows.Forms.Label valueSqlVersionNo;
        private System.Windows.Forms.Label labelSqlVersionNo;
        private System.Windows.Forms.Label valueCurrentDatabase;
        private System.Windows.Forms.Label labelCurrentDatabase;
        private System.Windows.Forms.ComboBox cbDatabases;
        private System.Windows.Forms.Label labelDatabaseName;
        private System.ComponentModel.BackgroundWorker backgroundWorker1;
        private System.Windows.Forms.Button btnCreateSnapshot;
        private System.Windows.Forms.Button btnRebuildSP;
        private System.Windows.Forms.DataGridViewTextBoxColumn CreatedDate;
        private System.Windows.Forms.DataGridViewTextBoxColumn DatabaseName;
        private System.Windows.Forms.DataGridView dgvSnapshotInfo;
        private System.Windows.Forms.Button btnRestoreSnapshot;
        private System.Windows.Forms.Button btnDeleteSnapshot;
    }
}

