package myapp;

import com.lightstreamer.client.LightstreamerClient;
import com.lightstreamer.client.Subscription;

public class Main {

	public static void main(String[] args) {
		 Subscription sub = new Subscription("MERGE", new String[] { "item1", "item2", "item3" }, new String[] { "stock_name", "last_price" });
         sub.setDataAdapter("QUOTE_ADAPTER");
         sub.setRequestedSnapshot("yes");
         sub.addListener(new QuoteListener());
         //LightstreamerClient client = new LightstreamerClient("http://push.lightstreamer.com","DEMO");  
         LightstreamerClient client = new LightstreamerClient("http://localhost:8080", "DEMO");
         client.connect();
         client.subscribe(sub);
	}
}
