package myapp;

import com.lightstreamer.client.*;
import com.lightstreamer.log.*;

public class Main {

  static Logger logger = LogManager.getLogger("test");

  static void log(String s) {
    logger.info(s, null);
  }

	public static void main(String[] args) throws Exception {
    LightstreamerClient.setLoggerProvider(new ConsoleLoggerProvider(ConsoleLogLevel.INFO));
		
    Subscription sub = new Subscription("MERGE", new String[] { "item1", "item2", "item3" }, new String[] { "stock_name", "last_price" });
    sub.setDataAdapter("QUOTE_ADAPTER");
    sub.setRequestedSnapshot("yes");
    assert sub.getDataAdapter().equals("QUOTE_ADAPTER");
    assert sub.getRequestedSnapshot().equals("yes");
    sub.addListener(new QuoteListener());
    
    LightstreamerClient client = new LightstreamerClient("http://push.lightstreamer.com","DEMO");  
    // LightstreamerClient client = new LightstreamerClient("http://localhost:8080", "DEMO");
    client.addListener(new CListener());

    client.connectionDetails.setUser("user");
    assert client.connectionDetails.getUser().equals("user");

    client.connectionOptions.setHttpExtraHeaders(java.util.Map.of("Foo", "bar"));

    client.subscribe(sub);
    client.connect();

    Thread.sleep(5000);

    client.disconnect();
	}

  static class CListener implements ClientListener {
    public void onListenStart() {
      log("ClientListener.onListenStart");
    }
    public void onListenEnd() {}
    public void onServerError(int errorCode, String errorMessage) {}
    public void onStatusChange(String status) {}
    public void onPropertyChange(String property) {}
  }

  static class QuoteListener implements SubscriptionListener
{
    public void onClearSnapshot(String itemName, int itemPos)
    {
        System.out.println("Clear Snapshot for " + itemName + ".");
    }

    public void onCommandSecondLevelItemLostUpdates(int lostUpdates, String key)
    {
        System.out.println("Lost Updates for " + key + " (" + lostUpdates + ").");
    }

    public void onCommandSecondLevelSubscriptionError(int code, String message, String key)
    {
        System.out.println("Subscription Error for " + key + ": " + message);
    }

    public void onEndOfSnapshot(String itemName, int itemPos)
    {
        System.out.println("End of Snapshot for " + itemName + ".");
    }

    public void onItemLostUpdates(String itemName, int itemPos, int lostUpdates)
    {
        System.out.println("Lost Updates for " + itemName + " (" + lostUpdates + ").");
    }

    public void onItemUpdate(ItemUpdate itemUpdate)
    {
        System.out.println(itemUpdate.getValue("stock_name") + " " + itemUpdate.getValue("last_price"));
    }

    public void onListenEnd()
    {
        // throw new System.NotImplementedException();
    }

    public void onListenStart()
    {
      log("SubscriptionListener.onListenStart");
    }

    public void onRealMaxFrequency(String frequency)
    {
        System.out.println("Real frequency: " + frequency + ".");
    }

    public void onSubscription()
    {
        System.out.println("Start subscription.");
    }

    public void onSubscriptionError(int code, String message)
    {
        System.out.println("Subscription error: " + message);
    }

    public void onUnsubscription()
    {
        System.out.println("Stop subscription.");
    }
  }
}
