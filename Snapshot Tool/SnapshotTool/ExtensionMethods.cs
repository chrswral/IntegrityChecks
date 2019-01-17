using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SnapshotTool
{
    public static class ExtensionMethods
    {
        public static bool IsNullOrEmpty(this object obj)
        {
            bool result = true;
        
            if((object)obj?.GetType() == typeof(object))
            {
                result = false;
            }

            return result;
        }
    }
}
