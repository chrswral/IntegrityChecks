namespace SnapshotTool
{
    partial class ChangeServer
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
            this.boxServer = new System.Windows.Forms.TextBox();
            this.btnValidate = new System.Windows.Forms.Button();
            this.boxAuthMethod = new System.Windows.Forms.ComboBox();
            this.boxUsername = new System.Windows.Forms.TextBox();
            this.boxPassword = new System.Windows.Forms.TextBox();
            this.labelServer = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.SuspendLayout();
            // 
            // boxServer
            // 
            this.boxServer.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.boxServer.Location = new System.Drawing.Point(9, 24);
            this.boxServer.Name = "boxServer";
            this.boxServer.Size = new System.Drawing.Size(196, 22);
            this.boxServer.TabIndex = 0;
            // 
            // btnValidate
            // 
            this.btnValidate.Location = new System.Drawing.Point(9, 173);
            this.btnValidate.Name = "btnValidate";
            this.btnValidate.Size = new System.Drawing.Size(75, 23);
            this.btnValidate.TabIndex = 1;
            this.btnValidate.Text = "Save";
            this.btnValidate.UseVisualStyleBackColor = true;
            this.btnValidate.Click += new System.EventHandler(this.btnValidate_Click);
            // 
            // boxAuthMethod
            // 
            this.boxAuthMethod.FormattingEnabled = true;
            this.boxAuthMethod.Items.AddRange(new object[] {
            "Windows Authentication",
            "SQL Server Authentication"});
            this.boxAuthMethod.Location = new System.Drawing.Point(9, 65);
            this.boxAuthMethod.Name = "boxAuthMethod";
            this.boxAuthMethod.Size = new System.Drawing.Size(196, 21);
            this.boxAuthMethod.TabIndex = 3;
            this.boxAuthMethod.SelectedIndexChanged += new System.EventHandler(this.comboBox1_SelectedIndexChanged);
            // 
            // boxUsername
            // 
            this.boxUsername.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.boxUsername.Location = new System.Drawing.Point(9, 105);
            this.boxUsername.Name = "boxUsername";
            this.boxUsername.Size = new System.Drawing.Size(196, 22);
            this.boxUsername.TabIndex = 4;
            // 
            // boxPassword
            // 
            this.boxPassword.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.boxPassword.Location = new System.Drawing.Point(9, 145);
            this.boxPassword.Name = "boxPassword";
            this.boxPassword.PasswordChar = 'X';
            this.boxPassword.Size = new System.Drawing.Size(196, 22);
            this.boxPassword.TabIndex = 5;
            // 
            // labelServer
            // 
            this.labelServer.AutoSize = true;
            this.labelServer.Location = new System.Drawing.Point(12, 9);
            this.labelServer.Name = "labelServer";
            this.labelServer.Size = new System.Drawing.Size(62, 13);
            this.labelServer.TabIndex = 6;
            this.labelServer.Text = "SQL Server";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(12, 49);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(114, 13);
            this.label2.TabIndex = 7;
            this.label2.Text = "Authentication Method";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(12, 89);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(55, 13);
            this.label3.TabIndex = 8;
            this.label3.Text = "Username";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(12, 130);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(53, 13);
            this.label4.TabIndex = 9;
            this.label4.Text = "Password";
            // 
            // ChangeServer
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(217, 208);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.labelServer);
            this.Controls.Add(this.boxPassword);
            this.Controls.Add(this.boxUsername);
            this.Controls.Add(this.boxAuthMethod);
            this.Controls.Add(this.btnValidate);
            this.Controls.Add(this.boxServer);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.Name = "ChangeServer";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "ChangeServer";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TextBox boxServer;
        private System.Windows.Forms.Button btnValidate;
        private System.Windows.Forms.ComboBox boxAuthMethod;
        private System.Windows.Forms.TextBox boxUsername;
        private System.Windows.Forms.TextBox boxPassword;
        private System.Windows.Forms.Label labelServer;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label4;
    }
}