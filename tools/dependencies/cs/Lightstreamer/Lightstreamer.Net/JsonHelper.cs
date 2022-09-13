using System;
using System.Collections.Generic;

namespace com.lightstreamer.cs
{
    // see https://stackoverflow.com/questions/63889672/how-to-apply-json-patch-to-plain-json-in-net-core
    public class JsonHelper
    {
        private JsonHelper() { }

        public static object ParseJson(string json)
        {
            return Newtonsoft.Json.JsonConvert.DeserializeObject(json);
        }

        public static object ParseJsonPatch(string patch)
        {
            var ops = Newtonsoft.Json.JsonConvert.DeserializeObject<List<Microsoft.AspNetCore.JsonPatch.Operations.Operation>>(patch);
            return new Microsoft.AspNetCore.JsonPatch.JsonPatchDocument(ops, new Newtonsoft.Json.Serialization.DefaultContractResolver());
        }

        public static string Stringify(object obj)
        {
            return Newtonsoft.Json.JsonConvert.SerializeObject(obj);
        }

        public static object ApplyPatch(object doc, object patch)
        {
            Microsoft.AspNetCore.JsonPatch.JsonPatchDocument ops = (Microsoft.AspNetCore.JsonPatch.JsonPatchDocument)patch;
            var newDoc = Copy(doc);
            ops.ApplyTo(newDoc);
            return newDoc;
        }

        // see https://stackoverflow.com/questions/78536/deep-cloning-objects
        static object Copy(object source)
        {
            return Newtonsoft.Json.JsonConvert.DeserializeObject(Newtonsoft.Json.JsonConvert.SerializeObject(source));

        }
    }
}
