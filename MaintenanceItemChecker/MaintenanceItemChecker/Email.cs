using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Threading.Tasks;

namespace MaintenanceItemChecker
{

    public class Email
    {
        private static readonly log4net.ILog log = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        private Dictionary<string, string> config = new Dictionary<string, string>();
        public string SMTPMailServer { get; private set; }
        public string SMTPMailLogin { get; private set; }
        public string SMTPMailPassword { get; private set; }
        public string SupportMailAddress { get; private set; }
        public bool CanSendMail
        {
            get
            {
                if (SMTPMailServer != string.Empty && SMTPMailLogin != string.Empty && SMTPMailPassword != string.Empty && SupportMailAddress != string.Empty)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
        }

        public Email()
        {
            log.Info("Load Email Config");
            this.config = Db.SqlAdapter.GetEmailConfig();
            foreach (KeyValuePair<string, string> value in config)
            {
                switch (value.Key)
                {
                    case "SMTPMailServer":
                        SMTPMailServer = value.Value;
                        break;
                    case "SMTPMailLogin":
                        SMTPMailLogin = value.Value;
                        break;
                    case "SMTPMailPassword":
                        SMTPMailPassword = value.Value;
                        break;
                    case "SupportMailAddress":
                        SupportMailAddress = value.Value;
                        break;
                }
            }
        }

        internal void SendStatus(string path, List<string> aircraftList)
        {
            log.Info("Try to send email");
            if(CanSendMail)
            {
                log.Info("Email Config Exists");

                IEnumerable<string> recipientAddresses = ConfigurationManager.AppSettings["SendEmailToAddress"].Split(',').ToList<string>();
                List<MailAddress> mailAddresses = new List<MailAddress>();

                foreach(string stringAddress in recipientAddresses)
                {
                    mailAddresses.Add(new MailAddress(stringAddress));
                }
                MailMessage message = new MailMessage();
                message.From = new MailAddress(SupportMailAddress);
                foreach(MailAddress mailAddress in mailAddresses)
                {
                    message.To.Add(mailAddress);
                }
                SmtpClient client = new SmtpClient();
                client.Port = 25;
                client.DeliveryMethod = SmtpDeliveryMethod.Network;
                client.Credentials = new NetworkCredential() { UserName = SMTPMailLogin, Password = SMTPMailPassword };
                client.Host = SMTPMailServer;
                message.IsBodyHtml = true;
                message.Subject = "Automated Maintenance Item Error Checker";
                message.Body = "Results File Attached for Aircraft<br />";
                foreach(string aircraft in aircraftList)
                {
                    message.Body += aircraft + "<br />";
                }
                message.Attachments.Add(new Attachment(path));
                try
                {
                    client.Send(message);
                } 
                catch (Exception ex) 
                {
                    log.Error($"Error: {ex.Message} - {ex.InnerException}");
                }
            } else
            {
                log.Info("Can't Send Mail - Not Configured");
            }
        }
    }
}
