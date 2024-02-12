package ls.haxe;

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

import com.lightstreamer.client.ConnectionOptions;
import com.lightstreamer.client.ItemUpdate;
import com.lightstreamer.client.LightstreamerClient;
import com.lightstreamer.client.Subscription;
import com.lightstreamer.log.ConsoleLogLevel;
import com.lightstreamer.log.ConsoleLoggerProvider;

import net.jodah.concurrentunit.ConcurrentTestCase;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;

import ls.haxe.util.BaseClientListener;
import ls.haxe.util.BaseMessageListener;
import ls.haxe.util.BaseSubscriptionListener;

/**
 * Instrumented test, which will execute on an Android device.
 *
 * @see <a href="http://d.android.com/tools/testing">Testing documentation</a>
 */
@RunWith(Parameterized.class)
public class TestCore extends ConcurrentTestCase {
    static final long TIMEOUT = 3000;
    final String host = "http://10.0.2.2:8080";
    LightstreamerClient client;
    final String transport;
    @Rule
    public TestRule watcher;

    @BeforeClass
    public static void setUpClass() throws Exception {
        LightstreamerClient.setLoggerProvider(new ConsoleLoggerProvider(ConsoleLogLevel.ERROR));
    }

    @Parameterized.Parameters
    public static Collection<Object> data() {
        return Arrays.asList(new Object[] {
                "WS-STREAMING", "HTTP-STREAMING", "WS-POLLING", "HTTP-POLLING"
        });
    }

    public TestCore(String transport) {
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
    }

    @Test
    public void testConnect() throws Throwable {
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
    public void testOnlineServer() throws Throwable {
        client = new LightstreamerClient("https://push.lightstreamer.com", "DEMO");
        client.connectionOptions.setForcedTransport(transport);
        if (transport.endsWith("POLLING")) {
            client.connectionOptions.setIdleTimeout(0);
            client.connectionOptions.setPollingInterval(100);
        }
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
        await(5000);
    }

    @Test
    public void testError() throws Throwable {
        client = new LightstreamerClient(host, "XXX");
        client.connectionOptions.setForcedTransport(transport);
        if (transport.endsWith("POLLING")) {
            client.connectionOptions.setIdleTimeout(0);
            client.connectionOptions.setPollingInterval(100);
        }
        client.addListener(new BaseClientListener() {
            @Override
            public void onServerError(int code, String msg) {
                threadAssertEquals("2 Requested Adapter Set not available", code + " " + msg);
                resume();
            }
        });
        client.connect();
        await(TIMEOUT);
    }

    @Test
    public void testDisconnect() throws Throwable {
        client.addListener(new BaseClientListener() {
            @Override
            public void onStatusChange(String status) {
                if (("CONNECTED:" + transport).equals(status)) {
                    client.disconnect();
                } else if ("DISCONNECTED".equals(status)) {
                    threadAssertEquals("DISCONNECTED", client.getStatus());
                    resume();
                }
            }
        });
        client.connect();
        await(TIMEOUT);
    }

    @Test
    public void testSubscribe() throws Throwable {
        Subscription sub = new Subscription("MERGE", new String[]{"count"}, new String[]{"count"});
        sub.setDataAdapter("COUNT");
        sub.addListener(new BaseSubscriptionListener() {
            @Override
            public void onSubscription() {
                threadAssertTrue(sub.isSubscribed());
                resume();
            }
        });
        client.subscribe(sub);
        List<Subscription> subs = client.getSubscriptions();
        threadAssertEquals(1, subs.size());
        threadAssertTrue(sub == subs.get(0));
        client.connect();
        await(TIMEOUT);
    }

    @Test
    public void testSubscriptionError() throws Throwable {
        Subscription sub = new Subscription("RAW", new String[]{"count"}, new String[]{"count"});
        sub.setDataAdapter("COUNT");
        sub.addListener(new BaseSubscriptionListener() {
            @Override
            public void onSubscriptionError(int code, String msg) {
                threadAssertEquals("24 Invalid mode for these items", code + " " + msg);
                resume();
            }
        });
        client.subscribe(sub);
        client.connect();
        await(TIMEOUT);
    }

    @Test
    public void testSubscribeCommand() throws Throwable {
        Subscription sub = new Subscription("COMMAND", new String[]{"mult_table"}, new String[]{"key", "value1", "value2", "command"});
        sub.setDataAdapter("MULT_TABLE");
        sub.addListener(new BaseSubscriptionListener() {
            @Override
            public void onSubscription() {
                threadAssertTrue(sub.isSubscribed());
                threadAssertEquals(1, sub.getKeyPosition());
                threadAssertEquals(4, sub.getCommandPosition());
                resume();
            }
        });
        client.subscribe(sub);
        client.connect();
        await(TIMEOUT);
    }

    @Test
    public void testSubscribeCommand2Level() throws Throwable {
        Subscription sub = new Subscription("COMMAND", new String[]{"two_level_command_count"}, new String[]{"key", "command"});
        sub.setDataAdapter("TWO_LEVEL_COMMAND");
        sub.setCommandSecondLevelDataAdapter("COUNT");
        sub.setCommandSecondLevelFields(new String[]{"count"});
        sub.addListener(new BaseSubscriptionListener() {
            @Override
            public void onSubscription() {
                threadAssertTrue(sub.isSubscribed());
                threadAssertEquals(1, sub.getKeyPosition());
                threadAssertEquals(2, sub.getCommandPosition());
            }
            @Override
            public void onItemUpdate(ItemUpdate update) {
                String val = update.getValue("count") != null ? update.getValue("count") : "";
                String key = update.getValue("key") != null ? update.getValue("key") : "";
                String cmd = update.getValue("command") != null ? update.getValue("command") : "";
                if (val.matches("\\d+") && "count".equals(key) && "UPDATE".equals(cmd)) {
                    resume();
                }
            }
        });
        client.subscribe(sub);
        List<Subscription> subs = client.getSubscriptions();
        threadAssertEquals(1, subs.size());
        threadAssertTrue(sub == subs.get(0));
        client.connect();
        await(TIMEOUT);
    }

    @Test
    public void testUnsubscribe() throws Throwable {
        Subscription sub = new Subscription("MERGE", new String[]{"count"}, new String[]{"count"});
        sub.setDataAdapter("COUNT");
        sub.addListener(new BaseSubscriptionListener() {
            @Override
            public void onSubscription() {
                threadAssertTrue(sub.isSubscribed());
                client.unsubscribe(sub);
            }
            @Override
            public void onUnsubscription() {
                threadAssertFalse(sub.isSubscribed());
                threadAssertFalse(sub.isActive());
                resume();
            }
        });
        client.subscribe(sub);
        client.connect();
        await(TIMEOUT);
    }

    @Test
    public void testSubscribeNonAscii() throws Throwable {
        Subscription sub = new Subscription("MERGE", new String[]{"strange:àìùòlè"}, new String[]{"value🌐-", "value&+=\r\n%"});
        sub.setDataAdapter("STRANGE_NAMES");
        sub.addListener(new BaseSubscriptionListener() {
            @Override
            public void onSubscription() {
                threadAssertTrue(sub.isSubscribed());
                resume();
            }
        });
        client.subscribe(sub);
        client.connect();
        await(TIMEOUT);
    }

    @Test
    public void testBandwidth() throws Throwable {
        AtomicInteger cnt = new AtomicInteger(0);
        client.addListener(new BaseClientListener() {
            @Override
            public void onPropertyChange(String prop) {
                if ("realMaxBandwidth".equals(prop)) {
                    String bw = client.connectionOptions.getRealMaxBandwidth();
                    switch (cnt.incrementAndGet()) {
                        case 1:
                            // after the connection, the server sends the default bandwidth
                            threadAssertEquals("40", bw);
                            // request a bandwidth equal to 20.1: the request is accepted
                            client.connectionOptions.setRequestedMaxBandwidth("20.1");
                            break;
                        case 2:
                            threadAssertEquals("20.1", bw);
                            // request a bandwidth equal to 70.1: the meta-data adapter cuts it to 40 (which is the configured limit)
                            client.connectionOptions.setRequestedMaxBandwidth("70.1");
                            break;
                        case 3:
                            threadAssertEquals("40", bw);
                            // request a bandwidth equal to 39: the request is accepted
                            client.connectionOptions.setRequestedMaxBandwidth("39");
                            break;
                        case 4:
                            threadAssertEquals("39", bw);
                            // request an unlimited bandwidth: the meta-data adapter cuts it to 40 (which is the configured limit)
                            client.connectionOptions.setRequestedMaxBandwidth("unlimited");
                            break;
                        case 5:
                            threadAssertEquals("40", bw);
                            resume();
                            break;
                    }
                }
            }
        });
        threadAssertEquals("unlimited", client.connectionOptions.getRequestedMaxBandwidth());
        client.connect();
        await(TIMEOUT);
    }

    @Test
    public void testClearSnapshot() throws Throwable {
        Subscription sub = new Subscription("DISTINCT", new String[]{"clear_snapshot"}, new String[]{"dummy"});
        sub.setDataAdapter("CLEAR_SNAPSHOT");
        sub.addListener(new BaseSubscriptionListener() {
            @Override
            public void onClearSnapshot(String name, int pos) {
                threadAssertEquals("clear_snapshot", name);
                threadAssertEquals(1, pos);
                resume();
            }
        });
        client.subscribe(sub);
        client.connect();
        await(TIMEOUT);
    }

    @Test
    public void testRoundTrip() throws Throwable {
        AtomicBoolean sessionActive = new AtomicBoolean(true);
        threadAssertEquals("TEST", client.connectionDetails.getAdapterSet());
        threadAssertEquals("http://10.0.2.2:8080", client.connectionDetails.getServerAddress());
        threadAssertEquals(50000000L, client.connectionOptions.getContentLength());
        threadAssertEquals(4000L, client.connectionOptions.getRetryDelay());
        threadAssertEquals(15000L, client.connectionOptions.getSessionRecoveryTimeout());
        Subscription sub = new Subscription("MERGE", new String[] {"count"}, new String[]{"count"});
        sub.setDataAdapter("COUNT");
        threadAssertEquals("COUNT", sub.getDataAdapter());
        threadAssertEquals("MERGE", sub.getMode());
        sub.addListener(new BaseSubscriptionListener() {
            @Override
            public void onSubscription() {
                resume();
            }
            @Override
            public void onItemUpdate(ItemUpdate arg0) {
                client.disconnect();
                sessionActive.set(false);
                resume();
            }
            @Override
            public void onUnsubscription() {
                resume();
            }
            @Override
            public void onRealMaxFrequency(String freq) {
                threadAssertEquals("unlimited", freq);
                resume();
            }
        });
        client.addListener(new BaseClientListener() {
            @Override
            public void onPropertyChange(String prop) {
                switch (prop) {
                    case "clientIp":
                        threadAssertEquals(sessionActive.get() ? "127.0.0.1" : null, client.connectionDetails.getClientIp());
                        break;
                    case "serverSocketName":
                        threadAssertEquals(sessionActive.get() ? "Lightstreamer HTTP Server" : null, client.connectionDetails.getServerSocketName());
                        break;
                    case "sessionId":
                        if (sessionActive.get())
                            threadAssertNotNull(client.connectionDetails.getSessionId());
                        else
                            threadAssertNull(client.connectionDetails.getSessionId());
                        break;
                    case "keepaliveInterval":
                        threadAssertEquals(5000L, client.connectionOptions.getKeepaliveInterval());
                        break;
                    case "idleTimeout":
                        threadAssertEquals(0L, client.connectionOptions.getIdleTimeout());
                        break;
                    case "pollingInterval":
                        threadAssertEquals(100L, client.connectionOptions.getPollingInterval());
                        break;
                    case "realMaxBandwidth":
                        threadAssertEquals(sessionActive.get() ? "40" : null, client.connectionOptions.getRealMaxBandwidth());
                        break;
                }
            }
        });
        client.connect();
        client.subscribe(sub);
        await(TIMEOUT, 4);
    }

    @Test
    public void testMessage() throws Throwable {
        client.connect();
        client.sendMessage("test message ()", null, 0, null, true);
        // no outcome expected
        client.sendMessage("test message (sequence)", "test_seq", 0, null, true);
        // no outcome expected
        client.sendMessage("test message (listener)", null, -1,
                new BaseMessageListener() {
                    @Override
                    public void onProcessed(String msg, String resp) {
                        threadAssertEquals("onProcessed test message (listener)", "onProcessed " + msg);
                        resume();
                    }
                }, true);
        client.sendMessage("test message (sequence+listener)", "test_seq", -1,
                new BaseMessageListener() {
                    @Override
                    public void onProcessed(String msg, String resp) {
                        threadAssertEquals("onProcessed test message (sequence+listener)", "onProcessed " + msg);
                        resume();
                    }
                }, true);
        await(TIMEOUT, 2);
    }

    @Test
    public void testMessageWithReturnValue() throws Throwable {
        BaseMessageListener msgListener = new BaseMessageListener() {
            @Override
            public void onProcessed(String msg, String resp) {
                threadAssertEquals("give me a result", msg);
                threadAssertEquals("result:ok", resp);
                resume();
            }
        };
        client.connect();
        client.sendMessage("give me a result", null, -1, msgListener, false);
        await(TIMEOUT);
    }

    @Test
    public void testMessageWithSpecialChars() throws Throwable {
        BaseMessageListener msgListener = new BaseMessageListener() {
            @Override
            public void onProcessed(String msg, String resp) {
                threadAssertEquals("hello +&=%\r\n", msg);
                resume();
            }
        };
        client.connect();
        client.sendMessage("hello +&=%\r\n", null, -1, msgListener, false);
        await(TIMEOUT);
    }

    @Test
    public void testUnorderedMessage() throws Throwable {
        BaseMessageListener msgListener = new BaseMessageListener() {
            @Override
            public void onProcessed(String msg, String resp) {
                threadAssertEquals("test message", msg);
                resume();
            }
        };
        client.connect();
        client.sendMessage("test message", "UNORDERED_MESSAGES", -1, msgListener, false);
        await(TIMEOUT);
    }

    @Test
    public void testMessageError() throws Throwable {
        BaseMessageListener msgListener = new BaseMessageListener() {
            @Override
            public void onDeny(String msg, int code, String error) {
                threadAssertEquals("throw me an error", msg);
                threadAssertEquals(-123, code);
                threadAssertEquals("test error", error);
                resume();
            }
        };
        client.connect();
        client.sendMessage("throw me an error", "test_seq", -1, msgListener, false);
        await(TIMEOUT);
    }

    @Test
    public void testLongMessage() throws Throwable {
        String msg = "{\"n\":\"MESSAGE_SEND\",\"c\":{\"u\":\"GEiIxthxD-1gf5Tk5O1NTw\",\"s\":\"S29120e92e162c244T2004863\",\"p\":\"localhost:3000/html/widget-responsive.html\",\"t\":\"2017-08-08T10:20:05.665Z\"},\"d\":\"{\\\"p\\\":\\\"🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐\\\"}\"}";
        BaseMessageListener msgListener = new BaseMessageListener() {
            @Override
            public void onProcessed(String _msg, String resp) {
                threadAssertEquals(msg, _msg);
                resume();
            }
        };
        client.connect();
        client.sendMessage(msg, "test_seq", -1, msgListener, false);
        await(TIMEOUT);
    }

    @Test
    public void testEndOfSnapshot() throws Throwable {
        Subscription sub = new Subscription("DISTINCT", new String[] {"end_of_snapshot"}, new String[] {"value"});
        sub.setRequestedSnapshot("yes");
        sub.setDataAdapter("END_OF_SNAPSHOT");
        sub.addListener(new BaseSubscriptionListener() {
            @Override
            public void onEndOfSnapshot(String name, int pos) {
                threadAssertEquals("end_of_snapshot", name);
                threadAssertEquals(1, pos);
                resume();
            }
        });
        client.subscribe(sub);
        client.connect();
        await(TIMEOUT);
    }

    /**
     * Subscribes to an item and verifies the overflow event is notified to the client.
     * <br>To ease the overflow event, the test
     * <ul>
     * <li>limits the event buffer size (see max_buffer_size in Test_integration/conf/test_conf.xml)</li>
     * <li>limits the bandwidth (see {@link ConnectionOptions#setRequestedMaxBandwidth(String)})</li>
     * <li>requests "unfiltered" messages (see {@link Subscription#setRequestedMaxFrequency(String)}).</li>
     * </ul>
     */
    @Test
    public void testOverflow() throws Throwable {
        Subscription sub = new Subscription("MERGE", new String[] {"overflow"}, new String[] {"value"});
        sub.setRequestedSnapshot("yes");
        sub.setDataAdapter("OVERFLOW");
        sub.setRequestedMaxFrequency("unfiltered");
        sub.addListener(new BaseSubscriptionListener() {
            @Override
            public void onItemLostUpdates(String name, int pos, int lost) {
                threadAssertEquals("overflow", name);
                threadAssertEquals(1, pos);
                client.unsubscribe(sub);
            }
            @Override
            public void onUnsubscription() {
                resume();
            }
        });
        client.subscribe(sub);
        // NB the bandwidth must not be too low otherwise the server can't write the response
        client.connectionOptions.setRequestedMaxBandwidth("10");
        client.connect();
        await(TIMEOUT);
    }

    @Test
    public void testFrequency() throws Throwable {
        Subscription sub = new Subscription("MERGE", new String[] {"count"}, new String[] {"count"});
        sub.setDataAdapter("COUNT");
        sub.addListener(new BaseSubscriptionListener() {
            @Override
            public void onRealMaxFrequency(String freq) {
                threadAssertEquals("unlimited", freq);
                resume();
            }
        });
        client.subscribe(sub);
        client.connect();
        await(TIMEOUT);
    }

    @Test
    public void testChangeFrequency() throws Throwable {
        AtomicInteger cnt = new AtomicInteger(0);
        Subscription sub = new Subscription("MERGE", new String[]{"count"}, new String[]{"count"});
        sub.setDataAdapter("COUNT");
        sub.addListener(new BaseSubscriptionListener() {
            @Override
            public void onRealMaxFrequency(String freq) {
                switch (cnt.incrementAndGet()) {
                    case 1:
                        threadAssertEquals("unlimited", freq);
                        sub.setRequestedMaxFrequency("2.5");
                        break;
                    case 2:
                        threadAssertEquals("2.5", freq);
                        sub.setRequestedMaxFrequency("unlimited");
                        break;
                    case 3:
                        threadAssertEquals("unlimited", freq);
                        resume();
                        break;
                }
            }
        });
        sub.setRequestedMaxFrequency("unlimited");
        client.subscribe(sub);
        client.connect();
        await(TIMEOUT);
    }

    @Test
    public void testHeaders() throws Throwable {
        HashMap<String, String> h = new HashMap<String, String>();
        h.put("X-Header", "header");
        client.connectionOptions.setHttpExtraHeaders(h);
        client.addListener(new BaseClientListener() {
            @Override
            public void onStatusChange(String status) {
                if (("CONNECTED:" + transport).equals(status)) {
                    resume();
                }
            }
        });
        client.connect();
        await(TIMEOUT);
    }

    @Test
    public void testJsonPatch() throws Throwable {
        List<ItemUpdate> updates = new ArrayList<ItemUpdate>();
        Subscription sub = new Subscription("MERGE", new String[]{"count"}, new String[]{"count"});
        sub.setRequestedSnapshot("no");
        sub.setDataAdapter("JSON_COUNT");
        sub.addListener(new BaseSubscriptionListener() {
            @Override
            public void onItemUpdate(ItemUpdate update) {
                updates.add(update);
                resume();
            }
        });
        client.subscribe(sub);
        client.connect();
        await(TIMEOUT, 2);

        ItemUpdate u = updates.get(1);
        threadAssertTrue(u.getValueAsJSONPatchIfAvailable(1).matches("\\[\\{\"op\":\"replace\",\"path\":\"/value\",\"value\":\\d+\\}\\]"));
        threadAssertTrue(u.getValue(1).matches("\\{\"value\":\\d+\\}"));
    }

    @Test
    public void testDiffPatch() throws Throwable {
        List<ItemUpdate> updates = new ArrayList<ItemUpdate>();
        Subscription sub = new Subscription("MERGE", new String[]{"count"}, new String[]{"count"});
        sub.setRequestedSnapshot("no");
        sub.setDataAdapter("DIFF_COUNT");
        sub.addListener(new BaseSubscriptionListener() {
            @Override
            public void onItemUpdate(ItemUpdate update) {
                updates.add(update);
                resume();
            }
        });
        client.subscribe(sub);
        client.connect();
        await(TIMEOUT, 2);

        ItemUpdate u = updates.get(1);
        threadAssertTrue(u.getValue(1).matches("value=\\d+"));
    }
}