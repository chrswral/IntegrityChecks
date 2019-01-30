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
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle();
            this.labelServerName = new System.Windows.Forms.Label();
            this.valueServerName = new System.Windows.Forms.Label();
            this.valueSqlVersionNo = new System.Windows.Forms.Label();
            this.labelSqlVersionNo = new System.Windows.Forms.Label();
            this.valueCurrentDatabase = new System.Windows.Forms.Label();
            this.labelCurrentDatabase = new System.Windows.Forms.Label();
            this.cbDatabases = new System.Windows.Forms.ComboBox();
            this.labelDatabaseName = new System.Windows.Forms.Label();
            this.btnCreateSnapshot = new System.Windows.Forms.Button();
            this.CreatedDate = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.DatabaseName = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.dgvSnapshotInfo = new System.Windows.Forms.DataGridView();
            this.btnRestoreSnapshot = new System.Windows.Forms.Button();
            this.btnDeleteSnapshot = new System.Windows.Forms.Button();
            this.labelActive = new System.Windows.Forms.Label();
            this.pnlYesNoCancel = new System.Windows.Forms.Panel();
            this.labelConfirmMessage = new System.Windows.Forms.Label();
            this.btnCancel = new System.Windows.Forms.Button();
            this.btnNo = new System.Windows.Forms.Button();
            this.btnYes = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.dgvSnapshotInfo)).BeginInit();
            this.pnlYesNoCancel.SuspendLayout();
            this.SuspendLayout();
            // 
            // labelServerName
            // 
            this.labelServerName.AutoSize = true;
            this.labelServerName.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.labelServerName.Location = new System.Drawing.Point(3, 4);
            this.labelServerName.Name = "labelServerName";
            this.labelServerName.Size = new System.Drawing.Size(76, 13);
            this.labelServerName.TabIndex = 0;
            this.labelServerName.Text = "Server Name:";
            this.labelServerName.Click += new System.EventHandler(this.labelServerName_Click);
            this.labelServerName.MouseEnter += new System.EventHandler(this.labelServerName_MouseEnter);
            this.labelServerName.MouseLeave += new System.EventHandler(this.labelServerName_MouseLeave);
            // 
            // valueServerName
            // 
            this.valueServerName.AutoSize = true;
            this.valueServerName.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.valueServerName.Location = new System.Drawing.Point(79, 4);
            this.valueServerName.Name = "valueServerName";
            this.valueServerName.Size = new System.Drawing.Size(77, 13);
            this.valueServerName.TabIndex = 1;
            this.valueServerName.Text = "_ServerName_";
            // 
            // valueSqlVersionNo
            // 
            this.valueSqlVersionNo.AutoSize = true;
            this.valueSqlVersionNo.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.valueSqlVersionNo.Location = new System.Drawing.Point(262, 4);
            this.valueSqlVersionNo.Name = "valueSqlVersionNo";
            this.valueSqlVersionNo.Size = new System.Drawing.Size(86, 13);
            this.valueSqlVersionNo.TabIndex = 3;
            this.valueSqlVersionNo.Text = "_SqlVersionNo_";
            // 
            // labelSqlVersionNo
            // 
            this.labelSqlVersionNo.AutoSize = true;
            this.labelSqlVersionNo.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.labelSqlVersionNo.Location = new System.Drawing.Point(174, 4);
            this.labelSqlVersionNo.Name = "labelSqlVersionNo";
            this.labelSqlVersionNo.Size = new System.Drawing.Size(90, 13);
            this.labelSqlVersionNo.TabIndex = 2;
            this.labelSqlVersionNo.Text = "SQL Version No:";
            // 
            // valueCurrentDatabase
            // 
            this.valueCurrentDatabase.AutoSize = true;
            this.valueCurrentDatabase.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.valueCurrentDatabase.Location = new System.Drawing.Point(474, 4);
            this.valueCurrentDatabase.Name = "valueCurrentDatabase";
            this.valueCurrentDatabase.Size = new System.Drawing.Size(104, 13);
            this.valueCurrentDatabase.TabIndex = 5;
            this.valueCurrentDatabase.Text = "_CurrentDatabase_";
            // 
            // labelCurrentDatabase
            // 
            this.labelCurrentDatabase.AutoSize = true;
            this.labelCurrentDatabase.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.labelCurrentDatabase.Location = new System.Drawing.Point(368, 4);
            this.labelCurrentDatabase.Name = "labelCurrentDatabase";
            this.labelCurrentDatabase.Size = new System.Drawing.Size(100, 13);
            this.labelCurrentDatabase.TabIndex = 4;
            this.labelCurrentDatabase.Text = "Current Database:";
            // 
            // cbDatabases
            // 
            this.cbDatabases.Font = new System.Drawing.Font("Segoe UI", 10F);
            this.cbDatabases.FormattingEnabled = true;
            this.cbDatabases.Location = new System.Drawing.Point(123, 30);
            this.cbDatabases.Name = "cbDatabases";
            this.cbDatabases.Size = new System.Drawing.Size(209, 25);
            this.cbDatabases.TabIndex = 6;
            this.cbDatabases.SelectionChangeCommitted += new System.EventHandler(this.cbDatabases_SelectionChangeCommitted);
            // 
            // labelDatabaseName
            // 
            this.labelDatabaseName.AutoSize = true;
            this.labelDatabaseName.Font = new System.Drawing.Font("Segoe UI", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.labelDatabaseName.Location = new System.Drawing.Point(12, 33);
            this.labelDatabaseName.Name = "labelDatabaseName";
            this.labelDatabaseName.Size = new System.Drawing.Size(105, 17);
            this.labelDatabaseName.TabIndex = 7;
            this.labelDatabaseName.Text = "Database Name:";
            // 
            // btnCreateSnapshot
            // 
            this.btnCreateSnapshot.Enabled = false;
            this.btnCreateSnapshot.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnCreateSnapshot.Location = new System.Drawing.Point(11, 125);
            this.btnCreateSnapshot.Name = "btnCreateSnapshot";
            this.btnCreateSnapshot.Size = new System.Drawing.Size(166, 31);
            this.btnCreateSnapshot.TabIndex = 9;
            this.btnCreateSnapshot.Text = "Create Snapshot";
            this.btnCreateSnapshot.UseVisualStyleBackColor = true;
            this.btnCreateSnapshot.Click += new System.EventHandler(this.btnCreateSnapshot_Click);
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
            dataGridViewCellStyle1.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle1.BackColor = System.Drawing.SystemColors.Control;
            dataGridViewCellStyle1.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            dataGridViewCellStyle1.ForeColor = System.Drawing.SystemColors.WindowText;
            dataGridViewCellStyle1.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle1.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle1.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.dgvSnapshotInfo.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle1;
            this.dgvSnapshotInfo.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvSnapshotInfo.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.DatabaseName,
            this.CreatedDate});
            this.dgvSnapshotInfo.GridColor = System.Drawing.SystemColors.Control;
            this.dgvSnapshotInfo.Location = new System.Drawing.Point(11, 66);
            this.dgvSnapshotInfo.Name = "dgvSnapshotInfo";
            dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle2.BackColor = System.Drawing.SystemColors.Control;
            dataGridViewCellStyle2.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            dataGridViewCellStyle2.ForeColor = System.Drawing.SystemColors.WindowText;
            dataGridViewCellStyle2.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle2.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle2.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.dgvSnapshotInfo.RowHeadersDefaultCellStyle = dataGridViewCellStyle2;
            this.dgvSnapshotInfo.RowHeadersVisible = false;
            this.dgvSnapshotInfo.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvSnapshotInfo.Size = new System.Drawing.Size(567, 53);
            this.dgvSnapshotInfo.TabIndex = 8;
            // 
            // btnRestoreSnapshot
            // 
            this.btnRestoreSnapshot.Enabled = false;
            this.btnRestoreSnapshot.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnRestoreSnapshot.Location = new System.Drawing.Point(211, 125);
            this.btnRestoreSnapshot.Name = "btnRestoreSnapshot";
            this.btnRestoreSnapshot.Size = new System.Drawing.Size(166, 31);
            this.btnRestoreSnapshot.TabIndex = 11;
            this.btnRestoreSnapshot.Text = "Restore Snapshot";
            this.btnRestoreSnapshot.UseVisualStyleBackColor = true;
            this.btnRestoreSnapshot.Click += new System.EventHandler(this.btnRestoreSnapshot_Click);
            // 
            // btnDeleteSnapshot
            // 
            this.btnDeleteSnapshot.Enabled = false;
            this.btnDeleteSnapshot.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnDeleteSnapshot.Location = new System.Drawing.Point(412, 125);
            this.btnDeleteSnapshot.Name = "btnDeleteSnapshot";
            this.btnDeleteSnapshot.Size = new System.Drawing.Size(166, 31);
            this.btnDeleteSnapshot.TabIndex = 12;
            this.btnDeleteSnapshot.Text = "Delete Snapshot";
            this.btnDeleteSnapshot.UseVisualStyleBackColor = true;
            this.btnDeleteSnapshot.Click += new System.EventHandler(this.btnDeleteSnapshot_Click);
            // 
            // labelActive
            // 
            this.labelActive.AutoSize = true;
            this.labelActive.Font = new System.Drawing.Font("Segoe UI", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.labelActive.Location = new System.Drawing.Point(372, 33);
            this.labelActive.Name = "labelActive";
            this.labelActive.Size = new System.Drawing.Size(107, 17);
            this.labelActive.TabIndex = 13;
            this.labelActive.Text = "_activeMessage_";
            this.labelActive.Visible = false;
            // 
            // pnlYesNoCancel
            // 
            this.pnlYesNoCancel.Controls.Add(this.labelConfirmMessage);
            this.pnlYesNoCancel.Controls.Add(this.labelActive);
            this.pnlYesNoCancel.Controls.Add(this.btnCancel);
            this.pnlYesNoCancel.Controls.Add(this.btnNo);
            this.pnlYesNoCancel.Controls.Add(this.btnYes);
            this.pnlYesNoCancel.Location = new System.Drawing.Point(11, 170);
            this.pnlYesNoCancel.Name = "pnlYesNoCancel";
            this.pnlYesNoCancel.Size = new System.Drawing.Size(567, 61);
            this.pnlYesNoCancel.TabIndex = 14;
            this.pnlYesNoCancel.Visible = false;
            // 
            // labelConfirmMessage
            // 
            this.labelConfirmMessage.AutoSize = true;
            this.labelConfirmMessage.Font = new System.Drawing.Font("Segoe UI", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.labelConfirmMessage.Location = new System.Drawing.Point(3, 5);
            this.labelConfirmMessage.Name = "labelConfirmMessage";
            this.labelConfirmMessage.Size = new System.Drawing.Size(115, 17);
            this.labelConfirmMessage.TabIndex = 15;
            this.labelConfirmMessage.Text = "_confirmMessage_";
            // 
            // btnCancel
            // 
            this.btnCancel.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnCancel.Location = new System.Drawing.Point(249, 29);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(117, 26);
            this.btnCancel.TabIndex = 17;
            this.btnCancel.Text = "Cancel";
            this.btnCancel.UseVisualStyleBackColor = true;
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // btnNo
            // 
            this.btnNo.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnNo.Location = new System.Drawing.Point(126, 29);
            this.btnNo.Name = "btnNo";
            this.btnNo.Size = new System.Drawing.Size(117, 26);
            this.btnNo.TabIndex = 16;
            this.btnNo.Text = "No";
            this.btnNo.UseVisualStyleBackColor = true;
            this.btnNo.Click += new System.EventHandler(this.btnNo_Click);
            // 
            // btnYes
            // 
            this.btnYes.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnYes.Location = new System.Drawing.Point(3, 29);
            this.btnYes.Name = "btnYes";
            this.btnYes.Size = new System.Drawing.Size(117, 26);
            this.btnYes.TabIndex = 15;
            this.btnYes.Text = "Yes";
            this.btnYes.UseVisualStyleBackColor = true;
            this.btnYes.Click += new System.EventHandler(this.btnYes_Click);
            // 
            // SnapshotTool
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(588, 234);
            this.Controls.Add(this.pnlYesNoCancel);
            this.Controls.Add(this.btnDeleteSnapshot);
            this.Controls.Add(this.btnRestoreSnapshot);
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
            this.SizeGripStyle = System.Windows.Forms.SizeGripStyle.Hide;
            this.Text = "Snapshot Tool";
            ((System.ComponentModel.ISupportInitialize)(this.dgvSnapshotInfo)).EndInit();
            this.pnlYesNoCancel.ResumeLayout(false);
            this.pnlYesNoCancel.PerformLayout();
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
        private System.Windows.Forms.Button btnCreateSnapshot;
        private System.Windows.Forms.DataGridViewTextBoxColumn CreatedDate;
        private System.Windows.Forms.DataGridViewTextBoxColumn DatabaseName;
        private System.Windows.Forms.DataGridView dgvSnapshotInfo;
        private System.Windows.Forms.Button btnRestoreSnapshot;
        private System.Windows.Forms.Button btnDeleteSnapshot;
        private System.Windows.Forms.Label labelActive;
        private System.Windows.Forms.Panel pnlYesNoCancel;
        private System.Windows.Forms.Label labelConfirmMessage;
        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.Button btnNo;
        private System.Windows.Forms.Button btnYes;
    }
}

