using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DocumentExport.Biz.Models
{
    public class DocumentModel
    {
        public int ID;
        public int FileSize;
        public int ZipSize;
        public byte[] FileContents;
        public string FileName;
        public string LocalPath;
        public bool Saved;

    }
}
