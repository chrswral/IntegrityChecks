using OfficeOpenXml;
using System;
using System.IO;

namespace MaintenanceItemChecker
{
    public  class Excel
    {
        ExcelPackage package;
        private static readonly log4net.ILog log = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        public Excel(string path)
        {
            log.Info($"Create Excel File: {path}");
            FileInfo fileInfo = new FileInfo(path);
            package = new ExcelPackage(fileInfo);
        }

        public void AddWorkSheetData(System.Data.DataTable dt, string Reg)
        {
            log.Info($"Add Work Sheet for {Reg}");
            var workSheet = package.Workbook.Worksheets.Add(Reg);
            for(int i = 0; i < dt.Columns.Count; i++)
            {
                workSheet.Cells[1, i + 1].Value = dt.Columns[i].ColumnName;
                workSheet.Cells[1, i + 1].Style.Font.Bold = true;
            }
            int deletes = 0;
            for(int i = 0; i < dt.Rows.Count; i++)
            {
                if(dt.DefaultView[i]["HasError"] != DBNull.Value)
                {
                    for (int j = 0; j < dt.Columns.Count; j++)
                    {
                        workSheet.Cells[i + 2 - deletes, j + 1].Value = dt.DefaultView[i][j];

                        if (dt.DefaultView[i][j].GetType() == typeof(DateTime))
                        {
                            workSheet.Cells[i + 2 - deletes, j + 1].Style.Numberformat.Format = "dd-MMM-yyyy";
                        } else
                        {
                            workSheet.Cells[i + 2 - deletes, j + 1].Value = dt.DefaultView[i][j];
                        }
                    }
                } else
                {
                    deletes++;
                }
            }
            log.Info("Save File");
            try
            {
                package.Save();
            } 
            catch(Exception ex)
            {
                log.Error($"Error: {ex.Message} - {ex.InnerException}");
            }
        }
    }

}