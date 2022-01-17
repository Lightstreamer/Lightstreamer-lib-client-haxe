using com.lightstreamer.client;
using com.lightstreamer.log;

namespace myapp
{
    class Program
    {
        static void Main(string[] args)
        {
            LightstreamerClient.setLoggerProvider(new ConsoleLoggerProvider(ConsoleLogLevel.DEBUG));

            Subscription sub = new Subscription("MERGE", new string[] { "item1", "item2", "item3" }, new string[] { "stock_name", "last_price" });
            sub.setDataAdapter("QUOTE_ADAPTER");
            sub.setRequestedSnapshot("yes");
            sub.addListener(new QuoteListener());
            //LightstreamerClient client = new LightstreamerClient("http://push.lightstreamer.com","DEMO");  
            LightstreamerClient client = new LightstreamerClient("http://localhost:8080", "DEMO");
            client.connect();
            client.subscribe(sub);

            var headers = new 
System.Collections.Generic.Dictionary<string, string>();
            headers.Add("Foo", "bar");
            System.Console.WriteLine(headers);
            client.connectionOptions.setHttpExtraHeaders(headers);
        }
    }
}