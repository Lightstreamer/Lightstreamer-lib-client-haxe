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

import java.io.InputStream;
import java.net.HttpCookie;
import java.net.URI;
import java.security.KeyStore;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;

import javax.net.ssl.TrustManagerFactory;

import org.junit.After;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TestRule;
import org.junit.rules.TestWatcher;
import org.junit.runner.Description;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;

import com.lightstreamer.client.LightstreamerClient;
import com.lightstreamer.client.Proxy;
import com.lightstreamer.log.ConsoleLogLevel;
import com.lightstreamer.log.ConsoleLoggerProvider;

import haxe.Exception;
import ls.haxe.util.BaseClientListener;
import net.jodah.concurrentunit.ConcurrentTestCase;

@RunWith(Parameterized.class)
public class TestExtra extends ConcurrentTestCase {
	static final long TIMEOUT = 3000;
	final String host = "http://localtest.me:8080";
	LightstreamerClient client;
	final String transport;
	@Rule
	public TestRule watcher;
	
	@BeforeClass
	public static void setUpClass() throws Exception {
		System.out.println(LightstreamerClient.LIB_NAME + " " + LightstreamerClient.LIB_VERSION);
		LightstreamerClient.setLoggerProvider(new ConsoleLoggerProvider(ConsoleLogLevel.ERROR));
	}
	
	@Parameters
    public static Collection<Object> data() {
        return Arrays.asList(new Object[] {
                "WS-STREAMING", "HTTP-STREAMING", "WS-POLLING", "HTTP-POLLING"
        });
    }
    
    public TestExtra(String transport) {
    	this.transport = transport;
    	client = new LightstreamerClient(host, "TEST");
    	client.connectionOptions.setForcedTransport(transport);
		if (transport.endsWith("POLLING")) {
			client.connectionOptions.setIdleTimeout(0);
			client.connectionOptions.setPollingInterval(100);
		}
		watcher = new TestWatcher() {
			protected void starting(Description description) {
				System.out.println(">>>>> Starting test: " + description.getMethodName() + " " + transport);
			}
		};
    }

	@Before
	public void setUp() throws Exception {
	}

	@After
	public void tearDown() throws Exception {
		client.disconnect();
		com.lightstreamer.internal.CookieHelper.instance.clearCookies();
		com.lightstreamer.internal.Globals.instance.clearTrustManager();
	}

	@Test
	public void testCookies() throws Throwable {
		URI uri = new URI(host);
		List<HttpCookie> cookies0 = LightstreamerClient.getCookies(uri);
	    threadAssertEquals(0, cookies0.size());
	    
	    HttpCookie cookie = new HttpCookie("X-Client", "client");
	    cookie.setPath("/");
	    LightstreamerClient.addCookies(uri, Arrays.asList(cookie));
	      
		client.addListener(new BaseClientListener() {
			@Override
			public void onStatusChange(String status) {
				if (("CONNECTED:" + transport).equals(status)) {
					threadAssertEquals(("CONNECTED:" + transport), client.getStatus());
					resume();
				}
			}
		});
		client.connect();
		await(TIMEOUT);
		
		List<String> cookies = LightstreamerClient.getCookies(uri).stream().map(c -> c.getName() + "=" + c.getValue())
				.collect(Collectors.toList());
		threadAssertEquals(2, cookies.size());
		threadAssertTrue(cookies.contains("X-Client=client"));
		threadAssertTrue(cookies.contains("X-Server=server"));
	}
	
	@Test
	public void testProxy() throws Throwable {
		client.connectionOptions.setProxy(new Proxy("HTTP", "localtest.me", 8079, "myuser", "mypassword"));

		client.addListener(new BaseClientListener() {
			@Override
			public void onStatusChange(String status) {
				if (("CONNECTED:" + transport).equals(status)) {
					threadAssertEquals(("CONNECTED:" + transport), client.getStatus());
					resume();
				}
			}
		});
		client.connect();
		await(TIMEOUT);
	}
	
	@Test
	public void testProxyEquals() throws Throwable {
		Proxy p1 = new Proxy("HTTP", "localtest.me", 8079, "myuser", "mypassword");
		Proxy p2 = new Proxy("HTTP", "localtest.me", 8079, "myuser", "mypassword2");
		Proxy p3 = new Proxy("HTTP", "localtest.me", 8079, "myuser", "mypassword");
		    
		threadAssertTrue(p1.equals(p3));
		threadAssertFalse(p1.equals(p2));
		threadAssertFalse(p1.equals("hello"));
		threadAssertTrue(p1.hashCode() == p3.hashCode());
		threadAssertFalse(p1.hashCode() == p2.hashCode());
	}
	
	@Test
	public void testTrustManager() throws Throwable {
		client = new LightstreamerClient("https://localtest.me:8443", "TEST");
		client.connectionOptions.setForcedTransport(transport);
		if (transport.endsWith("POLLING")) {
			client.connectionOptions.setIdleTimeout(0);
			client.connectionOptions.setPollingInterval(100);
		}
		
		InputStream ksIn = ClassLoader.getSystemResourceAsStream("localtest.me.pfx");
		assert ksIn != null;
	    KeyStore keyStore = java.security.KeyStore.getInstance("PKCS12");
	    keyStore.load(ksIn, "secret".toCharArray());
	    TrustManagerFactory tmf = javax.net.ssl.TrustManagerFactory.getInstance(javax.net.ssl.TrustManagerFactory.getDefaultAlgorithm());
	    tmf.init(keyStore);
	    LightstreamerClient.setTrustManagerFactory(tmf);
		
		client.addListener(new BaseClientListener() {
			@Override
			public void onStatusChange(String status) {
				if (("CONNECTED:" + transport).equals(status)) {
					threadAssertEquals(("CONNECTED:" + transport), client.getStatus());
					resume();
				}
			}
		});
		client.connect();
		await(TIMEOUT);
	}
}
