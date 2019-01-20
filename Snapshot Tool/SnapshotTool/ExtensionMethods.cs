using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SnapshotTool
{
    public static class ExtensionMethods
    {
        public static bool IsNotNull(this bool? obj)
        {
            bool result = false;
        
            if(obj != null)
            {
                result = true;
            }

            return result;
        }
    }
}
