using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using System.Data;
using System.IO;
using ICSharpCode.SharpZipLib.Zip.Compression;
using ICSharpCode.SharpZipLib.Zip.Compression.Streams;

namespace DocumentExport
{
    class Program
    {
        
        static void Main(string[] args)
        {

            string Server = @"support01\SQL2017";
            string Database = @"SOLOMON";
            string User = @"sa";
            string Password = @"Rusada123";
            string TableList = @"";
            string DocumentServer = @"";
            string DocumentDatabase = @"";
            string IDFileLocation = @"";
            string IDList = @"";


            Console.ForegroundColor = ConsoleColor.DarkGreen;

            if (args.Length < 5)
            {
                Console.WriteLine("Please specify startup parameters.");
                Console.WriteLine(@"");
                Console.WriteLine(@" -s SERVER");
                Console.WriteLine(@" -d DATABASE");
                Console.WriteLine(@" -l SQL LOGIN");
                Console.WriteLine(@" -p SQL PASSWORD");
                Console.WriteLine(@" -e EXPORT LOCATION");
                Console.WriteLine(@" -dd DOCUMENT DATABASE (Optional)");
                Console.WriteLine(@" -ds DOCUMENT SERVER (Optional)");
                Console.WriteLine(@" -t TABLE LIST (Optional)");
                Console.WriteLine(@" -f DOCUMENT ID LIST (Optional)");
                Console.WriteLine(@"");
                Console.WriteLine(@"E.g. DocumentExport.exe -s .\SQL2017 -d RALDAW -l RalWebClientAdmin -p ralwebclientadmin -t 'aJournalDocument','tCard' -e C:\ExportTest");
                Console.WriteLine(@"");
                Console.WriteLine(@"NOTE: Include spaces between command switch and parameter. E.g. -d RALDAW not -dRALDAW");

                Console.ReadKey();

                return;

            }


            for (int i = 0; i < args.Length; i++)
            {
                //Console.WriteLine("args[{0}] == {1}", i, args[i]);
                if (args[i].ToUpper() == "-S")
                {
                    Server = args[i + 1].ToString();
                }

                if (args[i].ToUpper() == "-D")
                {
                    Database = args[i + 1].ToString();
                }

                if (args[i].ToUpper() == "-L")
                {
                    User = args[i + 1].ToString();
                }

                if (args[i].ToUpper() == "-P")
                {
                    Password = args[i + 1].ToString();
                }

                if (args[i].ToUpper() == "-E")
                {
                    //ExportDirectory = args[i + 1].ToString();
                    Globals.ExportDirectory = args[i + 1].ToString();
                }

                if (args[i].ToUpper() == "-T")
                {
                    TableList = args[i + 1].ToString();
                }

                if (args[i].ToUpper() == "-DS")
                {
                    DocumentServer = args[i + 1].ToString();
                }

                if (args[i].ToUpper() == "-DD")
                {
                    DocumentDatabase = args[i + 1].ToString();
                }

                if (args[i].ToUpper() == "-F")
                {
                    IDFileLocation = args[i + 1].ToString();
                }

            }

            if (DocumentServer== "")
            {
                DocumentServer = Server;
            }

            if (DocumentDatabase == "") ;
            {
                DocumentDatabase = Database;
            }

           
            try
            {
                string CS = @"Data Source=" + Server + @";Initial Catalog=" + Database + @"; User ID=" + User + @"; Password=" + Password;
                string DCS = @"Data Source=" + DocumentServer + @";Initial Catalog=" + DocumentDatabase + @"; User ID=" + User + @"; Password=" + Password;

                if (IDList != "")
                {
                    GetDocsByID(IDList, CS, DCS);
                }
                else if (IDFileLocation != "")
                {

                    try
                    {

                        //Read the file and display it line by line.
                        StreamReader file = new StreamReader(IDFileLocation);

                        IDList = file.ReadLine();

                        file.Close();
                    }

                    catch (Exception e)
                    {
                        Console.WriteLine(e.Message);
                        Console.WriteLine(e.InnerException);
                        Console.ReadKey();
                    }

                    GetDocsByID(IDList, CS, DCS);

                }
                else  /* Get everything */
                {
                    GetAllDocs(TableList, CS, DCS);
                }

                //Console.ForegroundColor = ConsoleColor.Black;
                //Console.BackgroundColor= ConsoleColor.Green;
                Console.WriteLine("Completed");
                Console.ReadKey();

            }
            catch (Exception e)
            {

                Console.WriteLine(e.Message);
                Console.WriteLine(e.InnerException);
                Console.ReadKey();
            }
            
        }
        private static void GetDocsByID(string IDList, string CS, string DCS)
        {

            string idQuery = "SELECT tDocument.ID FROM tDocument WHERE tDocument.ID IN ("+ IDList +")";
            
            var dataAdapter = new SqlDataAdapter(idQuery, CS);
            var commandBuilder = new SqlCommandBuilder(dataAdapter);
            var IDListDS = new DataSet();
            dataAdapter.Fill(IDListDS);

            foreach (DataRow row in IDListDS.Tables[0].Rows)
            {
                string path = Globals.ExportDirectory;
                if (!Directory.Exists(path))
                {
                    DirectoryInfo di = Directory.CreateDirectory(path);
                }

                string DocID = row.Field<int>("ID").ToString();


                Console.WriteLine("Getting Doc ID: " + DocID);
                Document myDoc = new Document(DCS, int.Parse(DocID));

                if (!File.Exists(path + @"\" + myDoc.ID.ToString() + " " + myDoc.FileName))
                {

                    Console.WriteLine("Exporting: " + myDoc.FileName);
                    myDoc.Export(path);

                }

            }


        }
        private static void GetAllDocs(string TableList, string CS, string DCS)
        {
            string tableQuery = "SELECT t.name TableName FROM sys.tables t JOIN sys.columns c ON c.object_id = t.object_id WHERE t.name LIKE '%Document%' AND c.name = 'tDocument_ID' ";

            if (TableList != "")
            {
                tableQuery += " AND t.name IN (" + TableList + ")";
            }

            var dataAdapter = new SqlDataAdapter(tableQuery, CS);
            var commandBuilder = new SqlCommandBuilder(dataAdapter);
            var TableListDS = new DataSet();
            dataAdapter.Fill(TableListDS);


            foreach (DataRow tableRow in TableListDS.Tables[0].Rows)
            {
                string TableName = tableRow.Field<string>("TableName").ToString();

                string docQuery = "SELECT tDocument_ID FROM " + TableName + " WHERE tDocument_ID > 0";

                dataAdapter = new SqlDataAdapter(docQuery, CS);
                commandBuilder = new SqlCommandBuilder(dataAdapter);

                var DocListDS = new DataSet();
                dataAdapter.Fill(DocListDS);

                foreach (DataRow row in DocListDS.Tables[0].Rows)
                {
                    string path = Globals.ExportDirectory + @"\" + TableName;
                    if (!Directory.Exists(path))
                    {
                        DirectoryInfo di = Directory.CreateDirectory(path);
                    }

                    string DocID = row.Field<int>("tDocument_ID").ToString();


                    Console.WriteLine("Getting Doc ID: " + DocID);
                    Document myDoc = new Document(DCS, int.Parse(DocID));

                    if (!File.Exists(path + @"\" + myDoc.ID.ToString() + " " + myDoc.FileName))
                    {

                        Console.WriteLine("Exporting: " + myDoc.FileName);
                        myDoc.Export(path);

                    }

                }


            }
        }
    }

    public static class Globals
    {
        public static string ExportDirectory = @"C:\ExportTest";

    }
    public class Document
    {
        public int ID;
        public int FileSize;
        public int ZipSize;
        public byte[] FileContents;
        public string FileName;

        public Document(string cs, int ID)
        {
            try
            {
                string q = "SELECT * FROM tDocument WHERE ID = " + ID.ToString();

                var dataAdapter = new SqlDataAdapter(q, cs);

                var commandBuilder = new SqlCommandBuilder(dataAdapter);
                var ds = new DataSet();
                dataAdapter.Fill(ds);

                this.ID = Int32.Parse(ds.Tables[0].Rows[0]["ID"].ToString());
                this.FileSize = int.Parse(ds.Tables[0].Rows[0]["FileSize"].ToString());
                this.ZipSize = int.Parse(ds.Tables[0].Rows[0]["ZipSize"].ToString());

                this.FileContents = (byte[])ds.Tables[0].Rows[0]["FileContents"];

                this.FileName = ds.Tables[0].Rows[0]["FileName"].ToString();
            }
            catch
            {
                LogMessageToFile(@"Unable to export document ID" + ID.ToString());
            }

        }

        public static byte[] StringToByteArray(string stringToConvert)
        {
            System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();
            return encoding.GetBytes(stringToConvert);
        }

        public void Export(string path)
        {
            try
            {
                var fi = new FileInfo(path + @"\" + this.ID.ToString() + " " + this.FileName);
                FileStream fs = fi.Open(FileMode.Create, FileAccess.Write);
                var ms = new MemoryStream(this.ZipSize);
                var inf = new Inflater();
                var s = new InflaterInputStream(ms, inf, this.ZipSize);
                // put the compressed file contents into a memory stream
                ms.Write(this.FileContents, 0, this.ZipSize);
                ms.Position = 0;
                // decompress the stream into the file stream
                // using a 4KB buffer
                int bytes = 4096;
                var buffer = new Byte[bytes];
                while (true)
                {
                    bytes = s.Read(buffer, 0, buffer.Length);
                    if (bytes > 0)
                    {
                        fs.Write(buffer, 0, bytes);
                    }
                    else
                    {
                        break;
                    }
                }
                // close all streams
                ms.Close();
                s.Close();
                fs.Close();

                LogMessageToFile(@"Exported " + fi);
            }
            catch (Exception e)
            {
                LogMessageToFile(@"Unable to export document " + this.FileName +@"ERROR: "+e.Message);
            }
        }

        public void LogMessageToFile(string msg)
        {
            System.IO.StreamWriter sw = System.IO.File.AppendText(Globals.ExportDirectory+@"\" + "Log.txt");
            try
            {
                string logLine = System.String.Format(
                    "{0:G}: {1}.", System.DateTime.Now, msg);
                sw.WriteLine(logLine);
            }
            finally
            {
                sw.Close();
            }
        }

    }
}
