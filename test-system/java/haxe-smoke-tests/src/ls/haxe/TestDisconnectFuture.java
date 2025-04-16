/*
 * Copyright (C) 2023 Lightstreamer Srl
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
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
