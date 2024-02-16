package ls.haxe;

import java.util.concurrent.Future;

import org.junit.BeforeClass;
import org.junit.Test;

import com.lightstreamer.client.ItemUpdate;
import com.lightstreamer.client.LightstreamerClient;
import com.lightstreamer.client.Subscription;
import com.lightstreamer.log.ConsoleLogLevel;
import com.lightstreamer.log.ConsoleLoggerProvider;

import haxe.Exception;
import ls.haxe.util.BaseSubscriptionListener;
import net.jodah.concurrentunit.ConcurrentTestCase;

public class TestDisconnectFuture extends ConcurrentTestCase {

	@BeforeClass
	public static void setUpClass() throws Exception {
		System.out.println(LightstreamerClient.LIB_NAME + " " + LightstreamerClient.LIB_VERSION);
		LightstreamerClient.setLoggerProvider(new ConsoleLoggerProvider(ConsoleLogLevel.ERROR));
	}
	
	@Test
	public void testDisconnectFuture() throws Throwable {
		LightstreamerClient client = new LightstreamerClient("http://localtest.me:8080", "TEST");
		Subscription sub = new Subscription("MERGE", new String[]{"count"}, new String[]{"count"});
		sub.setRequestedSnapshot("no");
		sub.setDataAdapter("COUNT");
		sub.addListener(new BaseSubscriptionListener() {
			@Override
			public void onItemUpdate(ItemUpdate arg0) {
				resume();
			}
		});
		client.subscribe(sub);
		client.connect();
		await(3000);
		Future<Void> future = client.disconnectFuture();
		future.get();
	}
}
