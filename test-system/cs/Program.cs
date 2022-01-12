using com.lightstreamer.client;

namespace myapp
{
    class Program
    {
        static void Main(string[] args)
        {
            Subscription sub = new Subscription("MERGE", new string[] { "item1", "item2", "item3" }, new string[] { "stock_name", "last_price" });
            sub.setDataAdapter("QUOTE_ADAPTER");
            sub.setRequestedSnapshot("yes");
            sub.addListener(new QuoteListener());
            //LightstreamerClient client = new LightstreamerClient("http://push.lightstreamer.com","DEMO");  
            LightstreamerClient client = new LightstreamerClient("http://localhost:8080", "DEMO");
            client.connect();
            client.subscribe(sub);
        }
    }
}