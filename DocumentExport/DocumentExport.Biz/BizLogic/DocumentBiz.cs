using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DocumentExport.Biz.Models;
using Dapper;
using log4net;
using System.IO;
using ICSharpCode.SharpZipLib.Zip.Compression;
using ICSharpCode.SharpZipLib.Zip.Compression.Streams;

namespace DocumentExport.Biz.BizLogic
{
    public class DocumentBiz : IDisposable
    {
        private static readonly ILog _log = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        public DocumentBiz()
        {

        }
        private static void GetDocsByID(string IDList, string CS, string DCS)
        {

            //string idQuery = "SELECT tDocument.ID FROM tDocument WHERE tDocument.ID IN (" + IDList + ")";

            //var dataAdapter = new SqlDataAdapter(idQuery, CS);
            //var commandBuilder = new SqlCommandBuilder(dataAdapter);
            //var IDListDS = new DataSet();
            //dataAdapter.Fill(IDListDS);

            //foreach (DataRow row in IDListDS.Tables[0].Rows)
            //{
            //    string path = Globals.ExportDirectory;
            //    if (!Directory.Exists(path))
            //    {
            //        DirectoryInfo di = Directory.CreateDirectory(path);
            //    }

            //    string DocID = row.Field<int>("ID").ToString();


            //    Console.WriteLine("Getting Doc ID: " + DocID);
            //    Document myDoc = new Document(DCS, int.Parse(DocID));

            //    if (!File.Exists(path + @"\" + myDoc.ID.ToString() + " " + myDoc.FileName))
            //    {

            //        Console.WriteLine("Exporting: " + myDoc.FileName);
            //        myDoc.Export(path);

            //    }

            //}
        }
        public IEnumerable<EnvisionTableModel> GetDocumentListFromTables(string TableList)
        {
            _log.Info("Get List of Envision Tables containining a %Document% column");

            string tableQuery = "SELECT t.name TableName, DB_NAME() DatabaseName FROM sys.tables t JOIN sys.columns c ON c.object_id = t.object_id WHERE t.name LIKE '%Document%' AND c.name = 'tDocument_ID' ";

            if (TableList != "")
            {
                tableQuery += " AND t.name IN (" + TableList + ")";
            }

            var tableList = new List<EnvisionTableModel>();

            using (IDbConnection connection = new System.Data.SqlClient.SqlConnection(GlobalConfig.envisionServerConnectionString))
            {
                tableList = connection.Query<EnvisionTableModel>(tableQuery).ToList();
            }

            var documents = new List<DocumentModel>();
            _log.Info("Get a list of all tDocument_IDs from those tables");
            foreach(EnvisionTableModel table in tableList)
            {
                _log.Debug($"Table: {table.TableName}");
                string docQuery = "SELECT tDocument_ID ID FROM " + table.TableName + " WHERE tDocument_ID > 0";
                using (IDbConnection connection = new System.Data.SqlClient.SqlConnection(GlobalConfig.envisionServerConnectionString))
                {
                    table.Documents.AddRange(connection.Query<DocumentModel>(docQuery).ToList());
                }
            }

            return tableList;
        }

        public void SaveTableDocuments(EnvisionTableModel envisionTable)
        {
            _log.Debug("Create Folder for Table Documents");
            CreateTableDocumentFolder(envisionTable);

            _log.Debug("Save Documents From Each Table to Disk");
            foreach (DocumentModel document in envisionTable.Documents)
            {
                var doc = GetDocumentByID(document);

                document.FileName = doc.FileName;
                document.FileSize = doc.FileSize;
                document.ZipSize = doc.ZipSize;
                document.LocalPath = envisionTable.path + @"\" + doc.ID.ToString() + " " + doc.FileName;

                if (doc != null)
                {
                    try
                    {
                        Export(envisionTable, doc, document.LocalPath);
                    } catch
                    {
                        throw;
                    }

                    document.Saved = true;

                    _log.Info($"Exported Document: {doc.FileName}");
                }
            }
        }
        private bool CreateTableDocumentFolder(EnvisionTableModel envisionTable)
        {

            //Does the directory exist?
            if (!Directory.Exists(GlobalConfig.documentExportDirectory+@"\"+envisionTable.DatabaseName+@"_"+envisionTable.TableName))
            {
                //try to create it
                try
                {
                    Directory.CreateDirectory(GlobalConfig.documentExportDirectory + @"\" + envisionTable.DatabaseName + @"_" + envisionTable.TableName);
                }
                catch (Exception e)
                {
                    _log.Error($"There has been an error creating the Table Folder Directory: {e.Message}");
                    return false;
                }
            }
            return true;
        }
        private static DocumentModel GetDocumentByID(DocumentModel document)
        {
            if(document == null || document.ID == 0)
            {
                throw new ArgumentException("Document_ID is Null Or 0");
            }

            var doc = new DocumentModel();

            using (IDbConnection connection = new System.Data.SqlClient.SqlConnection(GlobalConfig.envisionServerConnectionString))
            {
                try
                {
                    doc = connection.QueryFirst<DocumentModel>($"SELECT ID, FileName, FileSize, ZipSize, FileContents FROM tDocument WHERE ID = {document.ID}");
                }
                catch
                {
                    _log.Warn($"Document ID {document.ID} does not exist");
                }
            }

            return doc;
        }
        private void Export(EnvisionTableModel envisionTable, DocumentModel document, string path)
        {
            try
            {
                var fi = new FileInfo(path);

                FileStream fs = fi.Open(FileMode.Create, FileAccess.Write);
                var ms = new MemoryStream(document.ZipSize);
                var inf = new Inflater();
                var s = new InflaterInputStream(ms, inf, document.ZipSize);
                // put the compressed file contents into a memory stream
                ms.Write(document.FileContents, 0, document.ZipSize);
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

                _log.InfoFormat(@"Exported " + fi);
            }
            catch (Exception e)
            {
                _log.Error(@"Unable to export document " + document.FileName + @"ERROR: " + e.Message);
            }
        }
        public void Dispose()
        {

        }

    }
}
