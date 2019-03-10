using System;
using System.Configuration;
using System.IO;
using System.Net;

namespace MaintenanceItemChecker
{
    public class SendFtp
    {
        private static readonly log4net.ILog log = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        private string ftpAddress
        {
            get
            {
                return ConfigurationManager.AppSettings["ftpAddress"];
            }
        }
        private int ftpPort
        {
            get
            {
                return int.Parse(ConfigurationManager.AppSettings["ftpPort"]);
            }
        }
        private string ftpUser
        {
            get
            {
                return ConfigurationManager.AppSettings["ftpUser"];
            }
        }
        private string ftpPassword
        {
            get
            {
                return ConfigurationManager.AppSettings["ftpPassword"];
            }
        }
        private string ftpDirectory
        {
            get
            {
                return ConfigurationManager.AppSettings["ftpDirectory"];
            }
        }

        private FileInfo fileInfo;
        private FtpWebRequest ftpWebRequest;

        public SendFtp(string path)
        {
            this.fileInfo = new FileInfo(path);

            UploadToFtp();

        }

        private void UploadToFtp()
        {
            log.Info("Upload by FTP");

            UriBuilder uri = new UriBuilder() { Port = ftpPort, Host = ftpAddress, Path = ftpDirectory+fileInfo.Name, Scheme = Uri.UriSchemeFtp };
            ftpWebRequest = (FtpWebRequest)WebRequest.Create(uri.Uri);
            ftpWebRequest.Method = WebRequestMethods.Ftp.UploadFile;
            ftpWebRequest.Credentials = new NetworkCredential() { UserName = ftpUser, Password = ftpPassword };
            log.Info("Set Destination & Credentials");
            try
            {
                Stream stream = ftpWebRequest.GetRequestStream();
                FileStream fs = File.OpenRead(fileInfo.FullName);
                byte[] buffer = new byte[1024];
                double total = (double)fs.Length;
                double read = 0;
                int byteRead = 0;

                do
                {
                    byteRead = fs.Read(buffer, 0, 1024);
                    stream.Write(buffer, 0, byteRead);
                    read += (double)byteRead;
                    double percent = read / total;
                    log.InfoFormat($"Uploaded {percent:p0}");
                }
                while (byteRead != 0);
                fs.Close();
                stream.Close();

            } catch(Exception ex)
            {
                log.Error($"Error Uploading to FTP: {ex.Message} - {ex.InnerException}");
            }
            log.Info("FTP Upload Complete");
        }
    }
}