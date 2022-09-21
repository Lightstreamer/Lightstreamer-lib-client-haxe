using System;
using com.lightstreamer.client;
using com.lightstreamer.log;

namespace myapp
{
  class Program
  {
    static Logger logger = LogManager.getLogger("test");

    static void Log(string s) {
      logger.info(s, null);
    }

    static void Assert(bool c) {
      if (!c) {
        throw new InvalidOperationException();
      }
    }

    static void Main(string[] args)
    {
      LightstreamerClient.setLoggerProvider(new ConsoleLoggerProvider(ConsoleLogLevel.DEBUG));

      Subscription sub = new Subscription("MERGE", new string[] { "item1", "item2", "item3" }, new string[] { "stock_name", "last_price" });
      sub.setDataAdapter("QUOTE_ADAPTER");
      sub.setRequestedSnapshot("yes");
      Assert(sub.getDataAdapter() == "QUOTE_ADAPTER");
      Assert(sub.getRequestedSnapshot() == "yes");
      sub.addListener(new QuoteListener());

      LightstreamerClient client = new LightstreamerClient("http://push.lightstreamer.com","DEMO");  
      // LightstreamerClient client = new LightstreamerClient("http://localhost:8080", "DEMO");
      client.addListener(new CListener());

      client.connectionDetails.setUser("user");
      Assert(client.connectionDetails.getUser() == "user");

      var headers = new 
      System.Collections.Generic.Dictionary<string, string>();
      headers.Add("Foo", "bar");
      client.connectionOptions.setHttpExtraHeaders(headers);

      client.subscribe(sub);
      client.connect();

      System.Threading.Thread.Sleep (5000);
    }

    class CListener: ClientListener {
      public void onListenStart(LightstreamerClient client) {
        Log("ClientListener.onListenStart");
      }
      public void onListenEnd(LightstreamerClient client) {}
      public void onServerError(int errorCode, String errorMessage) {}
      public void onStatusChange(String status) {}
      public void onPropertyChange(String property) {}
    }

    class QuoteListener : SubscriptionListener {
      void SubscriptionListener.onClearSnapshot(string itemName, int itemPos) {
          Log("Clear Snapshot for " + itemName + ".");
      }
      void SubscriptionListener.onCommandSecondLevelItemLostUpdates(int lostUpdates, string key) {
          Log("Lost Updates for " + key + " (" + lostUpdates + ").");
      }
      void SubscriptionListener.onCommandSecondLevelSubscriptionError(int code, string message, string key) {
          Log("Subscription Error for " + key + ": " + message);
      }
      void SubscriptionListener.onEndOfSnapshot(string itemName, int itemPos) {
          Log("End of Snapshot for " + itemName + ".");
      }
      void SubscriptionListener.onItemLostUpdates(string itemName, int itemPos, int lostUpdates) {
          Log("Lost Updates for " + itemName + " (" + lostUpdates + ").");
      }
      void SubscriptionListener.onItemUpdate(ItemUpdate itemUpdate) {
          //Log("New update for " + itemUpdate.ItemName);

          //IDictionary<string, string> listc = itemUpdate.ChangedFields;
          //foreach (string value in listc.Values)
          //{
          //    Log(" >>>>>>>>>>>>> " + value);
          //}
      }
      void SubscriptionListener.onListenEnd(Subscription subscription) {
          // throw new System.NotImplementedException();
      }
      void SubscriptionListener.onListenStart(Subscription subscription) {
        Log("SubscriptionListener.onListenStart");
      }
      void SubscriptionListener.onRealMaxFrequency(string frequency) {
          Log("Real frequency: " + frequency + ".");
      }
      void SubscriptionListener.onSubscription() {
          Log("Start subscription.");
      }
      void SubscriptionListener.onSubscriptionError(int code, string message) {
          Log("Subscription error: " + message);
      }
      void SubscriptionListener.onUnsubscription() {
          Log("Stop subscription.");
      }
    }
  }
}