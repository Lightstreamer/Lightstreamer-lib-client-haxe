package ls.haxe;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.test.platform.app.InstrumentationRegistry;

import com.lightstreamer.client.LSLightstreamerClient;
import com.lightstreamer.client.LightstreamerClient;
import com.lightstreamer.client.mpn.MpnBuilder;
import com.lightstreamer.client.mpn.MpnDevice;
import com.lightstreamer.client.mpn.MpnSubscription;
import com.lightstreamer.log.ConsoleLogLevel;
import com.lightstreamer.log.ConsoleLoggerProvider;

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

import java.util.Arrays;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;

import ls.haxe.util.SequencingMonitor;
import ls.haxe.util.SequencingMonitor.Condition;
import ls.haxe.util.StdoutMpnDeviceListener;
import ls.haxe.util.StdoutMpnSubscriptionListener;

@RunWith(Parameterized.class)
public class TestMpn {
    static final long TIMEOUT = 3000;
    final String host = "http://10.0.2.2:8080";
    MpnDevice device;
    MpnSubscription sub;
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

    public TestMpn(String transport) {
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
        Context ctx = InstrumentationRegistry.getInstrumentation().getTargetContext();
        /* create an Android device */
        device = new MpnDevice(ctx, "devtok" + System.nanoTime());
        /* create notification descriptor */
        String descriptor = new MpnBuilder()
                .priority("NORMAL")
                .title("my_title")
                .body("my_body")
                .icon("my_icon")
                .build();
        /* create MPN subscription */
        sub = new MpnSubscription("MERGE");
        sub.setDataAdapter("COUNT");
        //sub.setItems(new String[] {"count"});
        sub.setItemGroup("count");
        sub.setFieldSchema("count");
        sub.setNotificationFormat(descriptor);
    }

    @After
    public void tearDown() throws Exception {
        // unsubscribe from all the MPN item to keep the tests isolated as much as possible
        client.unsubscribeMpnSubscriptions("ALL");
//        SequencingMonitor lsMonitor = new SequencingMonitor();
//        lsMonitor.awaitUntil(new Condition() {
//            public boolean test() {
//                return client.getMpnSubscriptions("ALL").size() == 0;
//            }
//        });
        Thread.sleep(500);
        client.disconnect();
    }

    @Test(timeout=7000)
    public void testEarlyDeletion() throws Throwable {
        final SequencingMonitor lsMonitor = new SequencingMonitor();

        client.connect();
        client.registerForMpn(device);

        /*
         * NB the following trigger conditions are always false because
         * the counter value is always bigger than zero.
         */

        String descriptor= new MpnBuilder()
                .priority("NORMAL")
                .title("my_title")
                .body("my_body")
                .icon("my_icon")
                .build();

        MpnSubscription sub1 = new MpnSubscription("MERGE");
        sub1.setDataAdapter("COUNT");
        sub1.setItems(new String[] {"count"});
        sub1.setFieldSchema("count");
        sub1.setNotificationFormat(descriptor);
        sub1.setTriggerExpression("Integer.parseInt(${count}) < -1");

        MpnSubscription sub2 = new MpnSubscription("MERGE");
        sub2.setDataAdapter("COUNT");
        sub2.setItems(new String[] {"count"});
        sub2.setFieldSchema("count");
        sub2.setNotificationFormat(descriptor);
        sub2.setTriggerExpression("Integer.parseInt(${count}) < -2");

        client.subscribe(sub1, false);
        client.subscribe(sub2, false);

        lsMonitor.awaitUntil(new Condition() {
            public boolean test() {
                return client.getMpnSubscriptions("SUBSCRIBED").size() == 2;
            }
        });

        /* disconnect */

        client.disconnect();

        device.addListener(new StdoutMpnDeviceListener() {
            @Override
            public void onSubscriptionsUpdated() {
                lsMonitor.signal("SIGNAL => onSubscriptionsUpdated");
            }
        });

        /* reconnect */

        client.connect();
        client.unsubscribeMpnSubscriptions(null);

        while (true) {
            lsMonitor.await("SIGNAL => onSubscriptionsUpdated");
            if (client.getMpnSubscriptions(null).size() == 0) {
                break;
            }
        }
    }

    /**
     * Verifies that the client registers to the MPN module.
     */
    @Test(timeout=7000)
    public void registerTest() throws Throwable {
        final SequencingMonitor lsMonitor = new SequencingMonitor();
        device.addListener(new StdoutMpnDeviceListener() {
            @Override
            public void onRegistered() {
                super.onRegistered();
                lsMonitor.signal("SIGNAL => onRegistered");
            }

            @Override
            public void onStatusChanged(String status, long timestamp) {
                super.onStatusChanged(status, timestamp);
                lsMonitor.signal("SIGNAL => onStatusChanged " + status);
            }
        });

        client.connect();
        client.registerForMpn(device);
        lsMonitor.await("SIGNAL => onStatusChanged REGISTERED");
        lsMonitor.await("SIGNAL => onRegistered");
        assertEquals("REGISTERED", device.getStatus());
        assertTrue(device.isRegistered());
        assertFalse(device.isSuspended());
        assertTrue(device.getStatusTimestamp() >= 0);
        assertEquals("Google", device.getPlatform());
        assertEquals("com.lightstreamer.demo.android.stocklistdemo", device.getApplicationId());
        assertNotNull(device.getDeviceId());
    }

    /**
     * Verifies that when the registration fails the device listener is notified.
     */
    @Test(timeout=7000)
    public void registerTest_error() throws Throwable {
        Context ctx = InstrumentationRegistry.getInstrumentation().getContext();
        device = new MpnDevice(ctx, "123");

        final SequencingMonitor lsMonitor = new SequencingMonitor();
        device.addListener(new StdoutMpnDeviceListener() {
            @Override
            public void onRegistrationFailed(int code, String message) {
                super.onRegistrationFailed(code, message);
                lsMonitor.signal("SIGNAL => onRegistrationFailed " + code + " " + message);
            }
        });

        client.connect();
        client.registerForMpn(device);
        lsMonitor.await("SIGNAL => onRegistrationFailed 43 MPN invalid application ID");
    }

    /**
     * Verifies that the client subscribes to an MPN item.
     */
    @Test(timeout=7000)
    public void subscribeTest() throws Throwable {
        final SequencingMonitor lsMonitor = new SequencingMonitor();
        final SequencingMonitor subMonitor = new SequencingMonitor();
        device.addListener(new StdoutMpnDeviceListener() {
            @Override
            public void onSubscriptionsUpdated() {
                super.onSubscriptionsUpdated();
                lsMonitor.signal("SIGNAL => onSubscriptionsUpdated");
            }
        });
        sub.addListener(new StdoutMpnSubscriptionListener() {
            @Override
            public void onStatusChanged(String status, long timestamp) {
                super.onStatusChanged(status, timestamp);
                subMonitor.signal("SIGNAL => onStatusChanged " + status);
            }

            @Override
            public void onSubscription() {
                super.onSubscription();
                subMonitor.signal("SIGNAL => onSubscription");
            }

            @Override
            public void onPropertyChanged(String propertyName) {
                super.onPropertyChanged(propertyName);
                subMonitor.signal("SIGNAL => onPropertyChanged " + propertyName);
            }
        });

        client.connect();
        client.registerForMpn(device);
        client.subscribe(sub, false);
        lsMonitor.await("SIGNAL => onSubscriptionsUpdated");
        subMonitor.await("SIGNAL => onStatusChanged SUBSCRIBED");
        subMonitor.await("SIGNAL => onSubscription");
        assertTrue(sub.isActive());
        assertTrue(sub.isSubscribed());
        assertFalse(sub.isTriggered());
        assertEquals("SUBSCRIBED", sub.getStatus());
        assertTrue(sub.getStatusTimestamp() >= 0);
        String descriptor = new MpnBuilder()
                .priority("NORMAL")
                .title("my_title")
                .body("my_body")
                .icon("my_icon")
                .build();
        String expectedFormat = descriptor;
        String actualFormat = sub.getNotificationFormat();
        assertEquals(expectedFormat, actualFormat);
        assertNull(sub.getTriggerExpression());
        assertEquals("COUNT", sub.getDataAdapter());
        assertNull(sub.getRequestedBufferSize());
        assertNull(sub.getRequestedMaxFrequency());
        assertEquals("MERGE", sub.getMode());
        assertEquals("count", sub.getItemGroup());
        assertEquals("count", sub.getFieldSchema());
        assertNotNull(sub.getSubscriptionId());
    }

    /**
     * Verifies that, when the client modifies an active subscription, the changes
     * are propagated back to the subscription.
     * <p>
     * The following scenario is exercised:
     * <ul>
     * <li>the client subscribes to an item</li>
     * <li>the client creates a copy of the subscription</li>
     * <li>the client modifies a few parameters of the copy</li>
     * <li>the client subscribes using the copy</li>
     * <li>the changes are propagated back to the original subscription</li>
     * </ul>
     */
    @Test(timeout=7000)
    public void subscribeTest_modify() throws Throwable {
        final SequencingMonitor lsMonitor = new SequencingMonitor();
        final SequencingMonitor subMonitor = new SequencingMonitor();
        device.addListener(new StdoutMpnDeviceListener() {
            @Override
            public void onSubscriptionsUpdated() {
                super.onSubscriptionsUpdated();
                lsMonitor.signal("SIGNAL => onSubscriptionsUpdated");
            }
        });
        sub.addListener(new StdoutMpnSubscriptionListener() {
            @Override
            public void onStatusChanged(String status, long timestamp) {
                super.onStatusChanged(status, timestamp);
                subMonitor.signal("SIGNAL => onStatusChanged " + status);
            }

            @Override
            public void onSubscription() {
                super.onSubscription();
                subMonitor.signal("SIGNAL => onSubscription");
            }

            @Override
            public void onPropertyChanged(String propertyName) {
                super.onPropertyChanged(propertyName);
                subMonitor.signal("SIGNAL => onPropertyChanged " + propertyName);
            }
        });

        client.connect();
        client.registerForMpn(device);
        client.subscribe(sub, false);
        subMonitor.await("SIGNAL => onSubscription");

        /* check cached subscriptions */
        lsMonitor.await("SIGNAL => onSubscriptionsUpdated");
        assertEquals(1, client.getMpnSubscriptions("ALL").size());
        assertTrue(sub == client.getMpnSubscriptions("ALL").get(0));

        /* modify the subscription */
        sub.setTriggerExpression("0<1");
        sub.setNotificationFormat(new MpnBuilder().title("my_title_2").build());

        /* check original subscription */
        lsMonitor.awaitUntil(new Condition() {
            public boolean test() {
                return "{\"android\":{\"notification\":{\"title\":\"my_title_2\"}}}".equals(sub.getActualNotificationFormat())
                        && "0<1".equals(sub.getActualTriggerExpression());
            }
        });

        /* check cached subscriptions */
        assertEquals(1, client.getMpnSubscriptions("ALL").size());
        assertTrue(sub == client.getMpnSubscriptions("ALL").get(0));
        assertTrue(sub == client.findMpnSubscription(sub.getSubscriptionId()));
    }

    /**
     * Verifies that, when the client modifies a TRIGGERED subscription,
     * the state changes to SUBSCRIBED.
     * <p>
     * The following scenario is exercised:
     * <ul>
     * <li>the client subscribes to an item</li>
     * <li>the server notifies the client that the item is TRIGGERED</li>
     * <li>the client creates a copy of the subscription</li>
     * <li>the client subscribes using the copy</li>
     * <li>the states of both subscriptions become SUBSCRIBED</li>
     * </ul>
     */
    @Test(timeout=10000)
    public void subscribeTest_modify_reactivate() throws Throwable {
        final SequencingMonitor subMonitor = new SequencingMonitor();
        sub.addListener(new StdoutMpnSubscriptionListener() {
            @Override
            public void onStatusChanged(String status, long timestamp) {
                super.onStatusChanged(status, timestamp);
                subMonitor.signal("SIGNAL => onStatusChanged " + status);
            }

            @Override
            public void onTriggered() {
                super.onTriggered();
                subMonitor.signal("SIGNAL => onTriggered");
            }

            @Override
            public void onPropertyChanged(@NonNull String s) {
                super.onPropertyChanged(s);
                subMonitor.signal("SIGNAL => onPropertyChanged " + s);
            }
        });

        client.connect();
        client.registerForMpn(device);
        sub.setTriggerExpression("true"); // so we are sure that the item becomes triggered
        client.subscribe(sub, false);
        subMonitor.await("SIGNAL => onTriggered");

        /* modify the subscription */
        sub.setTriggerExpression("false");

        /* check original subscription */
        subMonitor.await("SIGNAL => onStatusChanged SUBSCRIBED");
        assertEquals("SUBSCRIBED", sub.getStatus());
        subMonitor.awaitUntil(new Condition() {
            public boolean test() {
                return "false".equals(sub.getActualTriggerExpression());
            }
        });
        assertEquals(1, client.getMpnSubscriptions(null).size());
    }

    /**
     * Verifies that, when the client overrides an active subscription using the coalescing option, the changes
     * are propagated back to the subscription.
     * <p>
     * The following scenario is exercised:
     * <ul>
     * <li>the client subscribes to an item</li>
     * <li>the client creates a copy of the subscription</li>
     * <li>the client modifies a few parameters of the copy</li>
     * <li>the client subscribes using the copy specifying the coalescing option</li>
     * <li>the changes are propagated back to the original subscription</li>
     * </ul>
     */
    @Test(timeout=7000)
    public void subscribeTest_coalesce() throws Throwable {
        final SequencingMonitor lsMonitor = new SequencingMonitor();
        final SequencingMonitor subMonitor = new SequencingMonitor();
        final SequencingMonitor subCopyMonitor = new SequencingMonitor();
        device.addListener(new StdoutMpnDeviceListener() {
            @Override
            public void onSubscriptionsUpdated() {
                super.onSubscriptionsUpdated();
                lsMonitor.signal("SIGNAL => onSubscriptionsUpdated");
            }
        });
        sub.addListener(new StdoutMpnSubscriptionListener() {
            @Override
            public void onStatusChanged(String status, long timestamp) {
                super.onStatusChanged(status, timestamp);
                subMonitor.signal("SIGNAL => onStatusChanged " + status);
            }

            @Override
            public void onSubscription() {
                super.onSubscription();
                subMonitor.signal("SIGNAL => onSubscription");
            }

            @Override
            public void onPropertyChanged(String propertyName) {
                super.onPropertyChanged(propertyName);
                subMonitor.signal("SIGNAL => onPropertyChanged " + propertyName);
            }
        });

        client.connect();
        client.registerForMpn(device);
        client.subscribe(sub, false);
        subMonitor.await("SIGNAL => onSubscription");

        /* check cached subscriptions */
        lsMonitor.await("SIGNAL => onSubscriptionsUpdated");
        assertEquals(1, client.getMpnSubscriptions("ALL").size());
        assertTrue(sub == client.getMpnSubscriptions("ALL").get(0));

        /* modify the subscription */
        MpnSubscription subCopy = new MpnSubscription("MERGE");
        subCopy.setDataAdapter("COUNT");
        subCopy.setItems(new String[] {"count"});
        subCopy.setFieldSchema("count");
        subCopy.setNotificationFormat(new MpnBuilder().title("my_title_2").build());
        subCopy.addListener(new StdoutMpnSubscriptionListener() {
            @Override
            public void onStatusChanged(String status, long timestamp) {
                super.onStatusChanged(status, timestamp);
                subCopyMonitor.signal("SIGNAL => (copy) onStatusChanged " + status);
            }

            @Override
            public void onSubscription() {
                super.onSubscription();
                subCopyMonitor.signal("SIGNAL => (copy) onSubscription");
            }

            @Override
            public void onPropertyChanged(String propertyName) {
                super.onPropertyChanged(propertyName);
                subCopyMonitor.signal("SIGNAL => (copy) onPropertyChanged " + propertyName);
            }
        });
        client.subscribe(subCopy, true);
        subCopyMonitor.await("SIGNAL => (copy) onSubscription");
        assertEquals("SUBSCRIBED", subCopy.getStatus());

        /* check original subscription */
        lsMonitor.awaitUntil(new Condition() {
            public boolean test() {
                return "{\"android\":{\"notification\":{\"title\":\"my_title_2\"}}}".equals(sub.getActualNotificationFormat());
            }
        });
        assertEquals("{\"android\":{\"notification\":{\"icon\":\"my_icon\",\"title\":\"my_title\",\"body\":\"my_body\"},\"priority\":\"NORMAL\"}}", sub.getNotificationFormat());

        /* check cached subscriptions */
        lsMonitor.await("SIGNAL => onSubscriptionsUpdated");
        assertEquals(1, client.getMpnSubscriptions("ALL").size());
        assertTrue(sub == client.getMpnSubscriptions("ALL").get(0));
        assertTrue(sub == client.findMpnSubscription(sub.getSubscriptionId()));
        assertTrue(sub != subCopy);
    }

    /**
     * Verifies that, when the subscription fails, the subscription listener is notified.
     */
    @Test(timeout=7000)
    public void subscribeTest_error() throws Throwable {
        final SequencingMonitor lsMonitor = new SequencingMonitor();
        sub = new MpnSubscription("MERGE");
        sub.setDataAdapter("unknown.adapter"); // cause a subscription error
        sub.setItems(new String[] {"count"});
        sub.setFieldSchema("count");
        sub.setNotificationFormat("");
        sub.addListener(new StdoutMpnSubscriptionListener() {
            @Override
            public void onSubscriptionError(int code, String message) {
                super.onSubscriptionError(code, message);
                lsMonitor.signal("SIGNAL => onSubscriptionError " + code + " " + message);
            }
        });

        client.connect();
        client.registerForMpn(device);
        client.subscribe(sub, false);
        lsMonitor.await("SIGNAL => onSubscriptionError 17 Data Adapter not found");
    }

    @Test(timeout=7000)
    public void getServerSubscriptionsTest() throws Throwable {
        final SequencingMonitor lsMonitor = new SequencingMonitor();
        final SequencingMonitor subMonitor = new SequencingMonitor();

        LightstreamerClient client2 = new LightstreamerClient(host, "TEST");
        Context ctx = InstrumentationRegistry.getInstrumentation().getTargetContext();
        MpnDevice dev2 = new MpnDevice(ctx, device.getDeviceToken());
        client2.connect();
        client2.registerForMpn(dev2);
        sub.setTriggerExpression("0==0");
        sub.addListener(new StdoutMpnSubscriptionListener() {
            @Override
            public void onStatusChanged(@NonNull String status, long timestamp) {
                subMonitor.signal("SIGNAL => onStatusChanged " + status);
            }
        });
        client2.subscribe(sub, false);
        subMonitor.await("SIGNAL => onStatusChanged ACTIVE");
        subMonitor.await("SIGNAL => onStatusChanged SUBSCRIBED");
        client2.disconnect();

        device.addListener(new StdoutMpnDeviceListener() {
            @Override
            public void onSubscriptionsUpdated() {
                lsMonitor.signal("SIGNAL => onSubscriptionsUpdated");
            }
        });
        client.connect();
        client.registerForMpn(device);

        lsMonitor.await("SIGNAL => onSubscriptionsUpdated");
        assertEquals(1, client.getMpnSubscriptions(null).size());
    }

    @Test(timeout=7000)
    public void findServerSubscriptionTest() throws Throwable {
        final SequencingMonitor lsMonitor = new SequencingMonitor();
        final SequencingMonitor subMonitor = new SequencingMonitor();

        LightstreamerClient client2 = new LightstreamerClient(host, "TEST");
        Context ctx = InstrumentationRegistry.getInstrumentation().getTargetContext();
        MpnDevice dev2 = new MpnDevice(ctx, device.getDeviceToken());
        client2.connect();
        client2.registerForMpn(dev2);
        sub.setTriggerExpression("0==0");
        sub.addListener(new StdoutMpnSubscriptionListener() {
            @Override
            public void onStatusChanged(@NonNull String status, long timestamp) {
                subMonitor.signal("SIGNAL => onStatusChanged " + status);
            }
        });
        client2.subscribe(sub, false);
        subMonitor.await("SIGNAL => onStatusChanged ACTIVE");
        subMonitor.await("SIGNAL => onStatusChanged SUBSCRIBED");
        client2.disconnect();

        device.addListener(new StdoutMpnDeviceListener() {
            @Override
            public void onSubscriptionsUpdated() {
                lsMonitor.signal("SIGNAL => onSubscriptionsUpdated");
            }
        });
        client.connect();
        client.registerForMpn(device);

        lsMonitor.await("SIGNAL => onSubscriptionsUpdated");
        assertNotNull(client.findMpnSubscription(sub.getSubscriptionId()));
    }

    /**
     * Verifies that the client unsubscribes from an MPN item.
     */
    @Test(timeout=7000)
    public void unsubscribeTest() throws Throwable {
        final SequencingMonitor lsMonitor = new SequencingMonitor();
        final SequencingMonitor subMonitor = new SequencingMonitor();
        device.addListener(new StdoutMpnDeviceListener() {
            @Override
            public void onSubscriptionsUpdated() {
                super.onSubscriptionsUpdated();
                lsMonitor.signal("SIGNAL => onSubscriptionsUpdated");
            }
        });
        sub.addListener(new StdoutMpnSubscriptionListener() {
            @Override
            public void onStatusChanged(String status, long timestamp) {
                super.onStatusChanged(status, timestamp);
                subMonitor.signal("SIGNAL => onStatusChanged " + status);
            }

            @Override
            public void onSubscription() {
                super.onSubscription();
                subMonitor.signal("SIGNAL => onSubscription");
            }

            @Override
            public void onUnsubscription() {
                super.onUnsubscription();
                subMonitor.signal("SIGNAL => onUnsubscription");
            }
        });

        client.connect();
        client.registerForMpn(device);
        client.subscribe(sub, false);
        subMonitor.await("SIGNAL => onSubscription");
        assertEquals("SUBSCRIBED", sub.getStatus());
        lsMonitor.await("SIGNAL => onSubscriptionsUpdated");
        assertTrue(sub == client.getMpnSubscriptions("SUBSCRIBED").get(0));

        client.unsubscribe(sub);
        subMonitor.await("SIGNAL => onStatusChanged UNKNOWN");
        assertEquals("UNKNOWN", sub.getStatus());
        subMonitor.await("SIGNAL => onUnsubscription");
        lsMonitor.await("SIGNAL => onSubscriptionsUpdated");
        assertEquals(0, client.getMpnSubscriptions("ALL").size());
    }

    /**
     * Verifies that the client doesn't send a subscription request if an unsubscription request follows immediately.
     */
    @Test(timeout=7000)
    public void unsubscribeTest_fastUnsubscription() throws Throwable {
        final SequencingMonitor lsMonitor = new SequencingMonitor();
        sub.addListener(new StdoutMpnSubscriptionListener() {
            @Override
            public void onSubscription() {
                super.onSubscription();
                lsMonitor.signal("SIGNAL => onSubscription");
            }

            @Override
            public void onUnsubscription() {
                super.onUnsubscription();
                lsMonitor.signal("SIGNAL => onUnsubscription");
            }
        });

        client.connect();
        client.registerForMpn(device);
        client.subscribe(sub, false);
        client.unsubscribe(sub);
        // must not fire any listeners
    }

    /**
     * Verifies that the client unsubscribes from all the subscribed items.
     */
    @Test(timeout=7000)
    public void unsubscribeTest_filter_subscribed() throws Throwable {
        final SequencingMonitor lsMonitor = new SequencingMonitor();
        final SequencingMonitor sub1Monitor = new SequencingMonitor();
        final SequencingMonitor sub2Monitor = new SequencingMonitor();
        device.addListener(new StdoutMpnDeviceListener() {
            @Override
            public void onSubscriptionsUpdated() {
                super.onSubscriptionsUpdated();
                lsMonitor.signal("SIGNAL => onSubscriptionsUpdated");
            }
        });

        String descriptor= new MpnBuilder()
                .priority("NORMAL")
                .title("my_title")
                .body("my_body")
                .icon("my_icon")
                .build();

        MpnSubscription sub1 = new MpnSubscription("MERGE");
        sub1.setDataAdapter("COUNT");
        sub1.setItems(new String[] {"count"});
        sub1.setFieldSchema("count");
        sub1.setNotificationFormat(descriptor);
        sub1.addListener(new StdoutMpnSubscriptionListener() {
            @Override
            public void onSubscription() {
                super.onSubscription();
                sub1Monitor.signal("SIGNAL => onSubscription sub1");
            }

            @Override
            public void onUnsubscription() {
                super.onUnsubscription();
                sub1Monitor.signal("SIGNAL => onUnsubscription sub1");
            }
        });

        MpnSubscription sub2 = new MpnSubscription("MERGE");
        sub2.setDataAdapter("COUNT");
        sub2.setItemGroup("count");
        sub2.setFieldSchema("count");
        sub2.setNotificationFormat(descriptor);
        // this expression is always true because the counter is >= 0
        sub2.setTriggerExpression("Integer.parseInt(${count}) > -1");
        sub2.addListener(new StdoutMpnSubscriptionListener() {
            @Override
            public void onTriggered() {
                super.onSubscription();
                sub2Monitor.signal("SIGNAL => onTriggered sub2");
            }

            @Override
            public void onUnsubscription() {
                super.onUnsubscription();
                sub2Monitor.signal("SIGNAL => onUnsubscription sub2");
            }
        });

        client.registerForMpn(device);
        client.subscribe(sub1, false);
        client.subscribe(sub2, false);
        client.connect();
        sub1Monitor.await("SIGNAL => onSubscription sub1");
        sub2Monitor.await("SIGNAL => onTriggered sub2");

        {
            List<MpnSubscription> subscribedLs = client.getMpnSubscriptions("SUBSCRIBED");
            assertEquals(1, subscribedLs.size());
            assertEquals(sub1, subscribedLs.get(0));

            List<MpnSubscription> triggeredLs = client.getMpnSubscriptions("TRIGGERED");
            assertEquals(1, triggeredLs.size());
            assertEquals(sub2, triggeredLs.get(0));

            List<MpnSubscription> allLs = client.getMpnSubscriptions("ALL");
            assertEquals(2, allLs.size());
            assertEquals(new HashSet<>(Arrays.asList(sub1, sub2)), new HashSet<>(allLs));
        }

        client.unsubscribeMpnSubscriptions("SUBSCRIBED");
        sub1Monitor.await("SIGNAL => onUnsubscription sub1");

        {
            List<MpnSubscription> subscribedLs = client.getMpnSubscriptions("SUBSCRIBED");
            assertEquals(0, subscribedLs.size());

            List<MpnSubscription> triggeredLs = client.getMpnSubscriptions("TRIGGERED");
            assertEquals(1, triggeredLs.size());
            assertEquals(sub2, triggeredLs.get(0));

            List<MpnSubscription> allLs = client.getMpnSubscriptions("ALL");
            assertEquals(1, allLs.size());
            assertEquals(sub2, allLs.get(0));
        }

        client.unsubscribeMpnSubscriptions(null);

        sub2Monitor.await("SIGNAL => onUnsubscription sub2");

        assertEquals(0, client.getMpnSubscriptions("ALL").size());
    }

    /**
     * Verifies that the client unsubscribes from all the triggered items.
     */
    @Test(timeout=7000)
    public void unsubscribeTest_filter_triggered() throws Throwable {
        final SequencingMonitor lsMonitor = new SequencingMonitor();
        final SequencingMonitor sub1Monitor = new SequencingMonitor();
        final SequencingMonitor sub2Monitor = new SequencingMonitor();
        device.addListener(new StdoutMpnDeviceListener() {
            @Override
            public void onSubscriptionsUpdated() {
                super.onSubscriptionsUpdated();
                lsMonitor.signal("SIGNAL => onSubscriptionsUpdated");
            }
        });

        String descriptor= new MpnBuilder()
                .priority("NORMAL")
                .title("my_title")
                .body("my_body")
                .icon("my_icon")
                .build();

        MpnSubscription sub1 = new MpnSubscription("MERGE");
        sub1.setDataAdapter("COUNT");
        sub1.setItems(new String[] {"count"});
        sub1.setFieldSchema("count");
        sub1.setNotificationFormat(descriptor);
        sub1.addListener(new StdoutMpnSubscriptionListener() {
            @Override
            public void onSubscription() {
                super.onSubscription();
                sub1Monitor.signal("SIGNAL => onSubscription sub1");
            }

            @Override
            public void onUnsubscription() {
                super.onUnsubscription();
                sub1Monitor.signal("SIGNAL => onUnsubscription sub1");
            }
        });

        MpnSubscription sub2 = new MpnSubscription("MERGE");
        sub2.setDataAdapter("COUNT");
        sub2.setItemGroup("count");
        sub2.setFieldSchema("count");
        sub2.setNotificationFormat(descriptor);
        // this expression is always true because the counter is >= 0
        sub2.setTriggerExpression("Integer.parseInt(${count}) > -1");
        sub2.addListener(new StdoutMpnSubscriptionListener() {
            @Override
            public void onTriggered() {
                super.onSubscription();
                sub2Monitor.signal("SIGNAL => onTriggered sub2");
            }

            @Override
            public void onUnsubscription() {
                super.onUnsubscription();
                sub2Monitor.signal("SIGNAL => onUnsubscription sub2");
            }
        });

        client.registerForMpn(device);
        client.subscribe(sub1, false);
        client.subscribe(sub2, false);
        client.connect();
        sub1Monitor.await("SIGNAL => onSubscription sub1");
        sub2Monitor.await("SIGNAL => onTriggered sub2");

        {
            List<MpnSubscription> subscribedLs = client.getMpnSubscriptions("SUBSCRIBED");
            assertEquals(1, subscribedLs.size());
            assertEquals(sub1, subscribedLs.get(0));

            List<MpnSubscription> triggeredLs = client.getMpnSubscriptions("TRIGGERED");
            assertEquals(1, triggeredLs.size());
            assertEquals(sub2, triggeredLs.get(0));

            List<MpnSubscription> allLs = client.getMpnSubscriptions("ALL");
            assertEquals(2, allLs.size());
            assertEquals(new HashSet<>(Arrays.asList(sub1, sub2)), new HashSet<>(allLs));
        }

        client.unsubscribeMpnSubscriptions("TRIGGERED");
        sub2Monitor.await("SIGNAL => onUnsubscription sub2");

        {
            List<MpnSubscription> subscribedLs = client.getMpnSubscriptions("SUBSCRIBED");
            assertEquals(1, subscribedLs.size());
            assertEquals(sub1, subscribedLs.get(0));

            List<MpnSubscription> triggeredLs = client.getMpnSubscriptions("TRIGGERED");
            assertEquals(0, triggeredLs.size());

            List<MpnSubscription> allLs = client.getMpnSubscriptions("ALL");
            assertEquals(1, allLs.size());
            assertEquals(sub1, allLs.get(0));
        }

        client.unsubscribeMpnSubscriptions(null);

        sub1Monitor.await("SIGNAL => onUnsubscription sub1");

        assertEquals(0, client.getMpnSubscriptions("ALL").size());
    }

    /**
     * Verifies that the client unsubscribes from all the triggered items.
     */
    @Test(timeout=7000)
    public void unsubscribeTest_filter_all() throws Throwable {
        final SequencingMonitor lsMonitor = new SequencingMonitor();
        final SequencingMonitor sub1Monitor = new SequencingMonitor();
        final SequencingMonitor sub2Monitor = new SequencingMonitor();
        device.addListener(new StdoutMpnDeviceListener() {
            @Override
            public void onSubscriptionsUpdated() {
                super.onSubscriptionsUpdated();
                lsMonitor.signal("SIGNAL => onSubscriptionsUpdated");
            }
        });

        String descriptor= new MpnBuilder()
                .priority("NORMAL")
                .title("my_title")
                .body("my_body")
                .icon("my_icon")
                .build();

        MpnSubscription sub1 = new MpnSubscription("MERGE");
        sub1.setDataAdapter("COUNT");
        sub1.setItems(new String[] {"count"});
        sub1.setFieldSchema("count");
        sub1.setNotificationFormat(descriptor);
        sub1.addListener(new StdoutMpnSubscriptionListener() {
            @Override
            public void onSubscription() {
                super.onSubscription();
                sub1Monitor.signal("SIGNAL => onSubscription sub1");
            }

            @Override
            public void onUnsubscription() {
                super.onUnsubscription();
                sub1Monitor.signal("SIGNAL => onUnsubscription sub1");
            }
        });

        MpnSubscription sub2 = new MpnSubscription("MERGE");
        sub2.setDataAdapter("COUNT");
        sub2.setItemGroup("count");
        sub2.setFieldSchema("count");
        sub2.setNotificationFormat(descriptor);
        // this expression is always true because the counter is >= 0
        sub2.setTriggerExpression("Integer.parseInt(${count}) > -1");
        sub2.addListener(new StdoutMpnSubscriptionListener() {
            @Override
            public void onTriggered() {
                super.onSubscription();
                sub2Monitor.signal("SIGNAL => onTriggered sub2");
            }

            @Override
            public void onUnsubscription() {
                super.onUnsubscription();
                sub2Monitor.signal("SIGNAL => onUnsubscription sub2");
            }
        });

        client.registerForMpn(device);
        client.subscribe(sub1, false);
        client.subscribe(sub2, false);
        client.connect();
        sub1Monitor.await("SIGNAL => onSubscription sub1");
        sub2Monitor.await("SIGNAL => onTriggered sub2");

        {
            List<MpnSubscription> subscribedLs = client.getMpnSubscriptions("SUBSCRIBED");
            assertEquals(1, subscribedLs.size());
            assertEquals(sub1, subscribedLs.get(0));

            List<MpnSubscription> triggeredLs = client.getMpnSubscriptions("TRIGGERED");
            assertEquals(1, triggeredLs.size());
            assertEquals(sub2, triggeredLs.get(0));

            List<MpnSubscription> allLs = client.getMpnSubscriptions("ALL");
            assertEquals(2, allLs.size());
            assertEquals(new HashSet<>(Arrays.asList(sub1, sub2)), new HashSet<>(allLs));
        }

        client.unsubscribeMpnSubscriptions("ALL");
        sub1Monitor.await("SIGNAL => onUnsubscription sub1");
        sub2Monitor.await("SIGNAL => onUnsubscription sub2");

        {
            List<MpnSubscription> subscribedLs = client.getMpnSubscriptions("SUBSCRIBED");
            assertEquals(0, subscribedLs.size());

            List<MpnSubscription> triggeredLs = client.getMpnSubscriptions("TRIGGERED");
            assertEquals(0, triggeredLs.size());

            List<MpnSubscription> allLs = client.getMpnSubscriptions("ALL");
            assertEquals(0, allLs.size());
        }
    }

    /**
     * Verifies that a subscription can start in state TRIGGERED.
     */
    @Test(timeout=7000)
    public void triggerTest_1() throws Throwable {
        final SequencingMonitor lsMonitor = new SequencingMonitor();
        sub.addListener(new StdoutMpnSubscriptionListener() {
            @Override
            public void onStatusChanged(String status, long timestamp) {
                super.onStatusChanged(status, timestamp);
                lsMonitor.signal("SIGNAL => onStatusChanged " + status);
            }

            @Override
            public void onTriggered() {
                super.onTriggered();
                lsMonitor.signal("SIGNAL => onTriggered");
            }
        });

        // this expression is always true because the counter is >= 0
        sub.setTriggerExpression("Integer.parseInt(${count}) > -1");
        client.connect();
        client.registerForMpn(device);
        client.subscribe(sub, false);
        lsMonitor.await("SIGNAL => onStatusChanged TRIGGERED");
        lsMonitor.await("SIGNAL => onTriggered");
        assertTrue(sub.isTriggered());
        assertEquals("TRIGGERED", sub.getStatus());
        assertTrue(sub.getStatusTimestamp() > 0);
    }

    /**
     * Verifies that, when the triggering condition holds, the subscription becomes TRIGGERED.
     * <p>
     * The following scenario is exercised:
     * <ul>
     * <li>the client subscribes to an item</li>
     * <li>the client modifies the subscription adding a trigger</li>
     * <li>the trigger fires on the server</li>
     * <li>the client method onTriggered is notified</li>
     * </ul>
     */
    @Test(timeout=7000)
    public void triggerTest_2() throws Throwable {
        final SequencingMonitor lsMonitor = new SequencingMonitor();
        sub.addListener(new StdoutMpnSubscriptionListener() {
            @Override
            public void onSubscription() {
                super.onSubscription();
                lsMonitor.signal("SIGNAL => onSubscription");
            }

            @Override
            public void onStatusChanged(String status, long timestamp) {
                super.onStatusChanged(status, timestamp);
                lsMonitor.signal("SIGNAL => onStatusChanged " + status);
            }

            @Override
            public void onTriggered() {
                super.onTriggered();
                lsMonitor.signal("SIGNAL => onTriggered");
            }
        });

        client.connect();
        client.registerForMpn(device);
        client.subscribe(sub, false);
        lsMonitor.await("SIGNAL => onSubscription");

        /* set a trigger on the item */
        // this expression is always true because the counter is >= 0
        sub.setTriggerExpression("Integer.parseInt(${count}) > -1");

        lsMonitor.await("SIGNAL => onStatusChanged TRIGGERED");
        lsMonitor.await("SIGNAL => onTriggered");
        assertTrue(sub.isTriggered());
        assertEquals("TRIGGERED", sub.getStatus());
        assertTrue(sub.getStatusTimestamp() > 0);
    }

    /**
     * Verifies that the two subscription objects become subscribed.
     */
    @Test(timeout=7000)
    public void doubleSubscriptionTest() throws Throwable {
        final SequencingMonitor lsMonitor = new SequencingMonitor();

        client.connect();
        client.registerForMpn(device);

        String descriptor= new MpnBuilder()
                .priority("NORMAL")
                .title("my_title")
                .body("my_body")
                .icon("my_icon")
                .build();

        MpnSubscription sub1 = new MpnSubscription("MERGE");
        sub1.setDataAdapter("COUNT");
        sub1.setItems(new String[] {"count"});
        sub1.setFieldSchema("count");
        sub1.setNotificationFormat(descriptor);

        MpnSubscription sub2 = new MpnSubscription("MERGE");
        sub2.setDataAdapter("COUNT");
        sub2.setItems(new String[] {"count"});
        sub2.setFieldSchema("count");
        sub2.setNotificationFormat(descriptor);

        client.subscribe(sub1, false);
        client.subscribe(sub2, false);

        lsMonitor.awaitUntil(new Condition() {
            public boolean test() {
                return client.getMpnSubscriptions("SUBSCRIBED").size() == 2;
            }
        });
        assertNotEquals(sub1.getSubscriptionId(), sub2.getSubscriptionId());
    }

    /**
     * Verifies that the MPN subscriptions are preserved upon disconnection.
     * <p>
     * The scenario exercised is the following:
     * <ul>
     * <li>the client subscribes to two items</li>
     * <li>the client disconnects</li>
     * <li>the client reconnects</li>
     * <li>the server sends to the client the data about the two subscriptions</li>
     * </ul>
     */
    @Test(timeout=7000)
    public void doubleSubscriptionTest_disconnect() throws Throwable {
        final SequencingMonitor lsMonitor = new SequencingMonitor();

        client.connect();
        client.registerForMpn(device);

        /*
         * NB the following trigger conditions are always false because
         * the counter value is always bigger than zero.
         */

        String descriptor= new MpnBuilder()
                .priority("NORMAL")
                .title("my_title")
                .body("my_body")
                .icon("my_icon")
                .build();

        MpnSubscription sub1 = new MpnSubscription("MERGE");
        sub1.setDataAdapter("COUNT");
        sub1.setItems(new String[] {"count"});
        sub1.setFieldSchema("count");
        sub1.setNotificationFormat(descriptor);
        sub1.setTriggerExpression("Integer.parseInt(${count}) < -1");

        MpnSubscription sub2 = new MpnSubscription("MERGE");
        sub2.setDataAdapter("COUNT");
        sub2.setItems(new String[] {"count"});
        sub2.setFieldSchema("count");
        sub2.setNotificationFormat(descriptor);
        sub2.setTriggerExpression("Integer.parseInt(${count}) < -2");

        client.subscribe(sub1, false);
        client.subscribe(sub2, false);

        lsMonitor.awaitUntil(new Condition() {
            public boolean test() {
                return client.getMpnSubscriptions("SUBSCRIBED").size() == 2;
            }
        });

        /* disconnect */

        client.disconnect();

        /* reconnect */

        client.connect();

        lsMonitor.awaitUntil(new Condition() {
            public boolean test() {
                return client.getMpnSubscriptions("SUBSCRIBED").size() == 2;
            }
        });

        List<MpnSubscription> subs = client.getMpnSubscriptions("SUBSCRIBED");
        assertNotEquals(sub1.getSubscriptionId(), sub2.getSubscriptionId());
    }

    /**
     * Verifies that the subscription status changes according to this diagram
     * <img src="{@docRoot}/../docs/mpn/mpn-subscription-statuses.png">.
     */
    @Test(timeout=7000)
    public void statusChangeTest() throws Throwable {
        final SequencingMonitor lsMonitor = new SequencingMonitor();
        final SequencingMonitor subMonitor = new SequencingMonitor();
        device.addListener(new StdoutMpnDeviceListener() {
            @Override
            public void onSubscriptionsUpdated() {
                super.onSubscriptionsUpdated();
                lsMonitor.signal("SIGNAL => onSubscriptionsUpdated");
            }
        });
        sub.addListener(new StdoutMpnSubscriptionListener() {
            @Override
            public void onStatusChanged(String status, long timestamp) {
                super.onStatusChanged(status, timestamp);
                subMonitor.signal("SIGNAL => onStatusChanged " + status);
            }

            @Override
            public void onSubscription() {
                super.onSubscription();
                subMonitor.signal("SIGNAL => onSubscription");
            }

            @Override
            public void onUnsubscription() {
                super.onUnsubscription();
                subMonitor.signal("SIGNAL => onUnsubscription");
            }
        });


        client.connect();
        client.registerForMpn(device);

        assertEquals("UNKNOWN", sub.getStatus());

        client.subscribe(sub, false);

        assertEquals("ACTIVE", sub.getStatus());

        subMonitor.await("SIGNAL => onSubscription");
        assertEquals("SUBSCRIBED", sub.getStatus());

        client.unsubscribe(sub);
        subMonitor.await("SIGNAL => onStatusChanged UNKNOWN");
        assertEquals("UNKNOWN", sub.getStatus());
    }

    /**
     * Verifies that {@code onSubscriptionsUpdated} is notified even if the snapshot doesn't contain any subscriptions.
     * <p>
     * The following scenario is exercised:
     * <ul>
     * <li>the client registers to MPN module</li>
     * <li>SUBS adapter publishes an empty snapshot</li>
     * <li>{@code onSubscriptionsUpdated} is fired</li>
     * </ul>
     */
    @Test(timeout=7000)
    public void onSubscriptionsUpdatedTest_empty() throws Throwable {
        final SequencingMonitor lsMonitor = new SequencingMonitor();
        device.addListener(new StdoutMpnDeviceListener() {
            @Override
            public void onSubscriptionsUpdated() {
                super.onSubscriptionsUpdated();
                lsMonitor.signal("onSubscriptionsUpdated");
            }
        });

        client.connect();
        client.registerForMpn(device);
        lsMonitor.await("onSubscriptionsUpdated");
        assertEquals(0, client.getMpnSubscriptions("ALL").size());
        assertEquals(0, client.getSubscriptions().size());

        java.lang.reflect.Field f = client.getClass().getDeclaredField("delegate");
        f.setAccessible(true);
        LSLightstreamerClient lsclient = (LSLightstreamerClient) f.get(client);
        assertEquals(0, lsclient.getSubscriptions().size());
    }

    /**
     * Verifies that {@code onSubscriptionsUpdated} is notified when the cached subscriptions change.
     * <p>
     * The following scenario is exercised:
     * <ul>
     * <li>the client subscribes to two MPN items</li>
     * <li>when MPNOK is received, {@code onSubscriptionsUpdated} is fired</li>
     * <li>the client disconnects</li>
     * <li>the client reconnects</li>
     * <li>when SUBS adapter publishes the two previous MPN items, {@code onSubscriptionsUpdated} is fired</li>
     * <li>the client unsubscribes from the two items</li>
     * <li>when DELETE is received, {@code onSubscriptionsUpdated} is fired</li>
     * </ul>
     */
    @Test(timeout=7000)
    public void onSubscriptionsUpdatedTest() throws Throwable {
        final SequencingMonitor lsMonitor = new SequencingMonitor();

        device.addListener(new StdoutMpnDeviceListener() {
            @Override
            public void onSubscriptionsUpdated() {
                super.onSubscriptionsUpdated();
                lsMonitor.signal("onSubscriptionsUpdated");
            }
        });

        client.connect();
        lsMonitor.signal("first connection");
        client.registerForMpn(device);

        /*
         * NB the following trigger conditions are always false because
         * the counter value is always bigger than zero.
         */

        String descriptor= new MpnBuilder()
                .priority("NORMAL")
                .title("my_title")
                .body("my_body")
                .icon("my_icon")
                .build();

        MpnSubscription sub1 = new MpnSubscription("MERGE");
        sub1.setDataAdapter("COUNT");
        sub1.setItems(new String[] {"count"});
        sub1.setFieldSchema("count");
        sub1.setNotificationFormat(descriptor);
        sub1.setTriggerExpression("Integer.parseInt(${count}) < -1");

        MpnSubscription sub2 = new MpnSubscription("MERGE");
        sub2.setDataAdapter("COUNT");
        sub2.setItems(new String[] {"count"});
        sub2.setFieldSchema("count");
        sub2.setNotificationFormat(descriptor);
        sub2.setTriggerExpression("Integer.parseInt(${count}) < -2");

        client.subscribe(sub1, false);
        client.subscribe(sub2, false);

        lsMonitor.await("onSubscriptionsUpdated"); // MPNOK
        lsMonitor.await("onSubscriptionsUpdated"); // MPNOK
        lsMonitor.awaitUntil(new Condition() {
            @Override
            public boolean test() {
                return client.getMpnSubscriptions("ALL").size() == 2;
            }
        });

        /* disconnect */

        client.disconnect();
        lsMonitor.signal("disconnection");

        /* reconnect */

        client.connect();
        lsMonitor.signal("second connection");

        lsMonitor.await("onSubscriptionsUpdated"); // end-of-snapshot
        lsMonitor.awaitUntil(new Condition() {
            @Override
            public boolean test() {
                return client.getMpnSubscriptions("ALL").size() == 2;
            }
        });

        client.unsubscribe(sub1);
        client.unsubscribe(sub2);

        lsMonitor.await("onSubscriptionsUpdated"); // MPNDEL
        lsMonitor.await("onSubscriptionsUpdated"); // MPNDEL
        lsMonitor.awaitUntil(new Condition() {
            @Override
            public boolean test() {
                return client.getMpnSubscriptions("ALL").size() == 0;
            }
        });
    }

    @Test(timeout=7000)
    public void unsubscribeTest_error() throws Throwable {
        final SequencingMonitor lsMonitor = new SequencingMonitor();
        sub.addListener(new StdoutMpnSubscriptionListener() {
            @Override
            public void onSubscriptionError(int i, @Nullable String s) {
                super.onSubscriptionError(i, s);
                lsMonitor.signal("SIGNAL => onSubscriptionError " + i + " " + s);
            }
        });

        client.connect();
        client.registerForMpn(device);
        client.subscribe(sub, false);
        client.unsubscribe(sub);
        lsMonitor.await("SIGNAL => onSubscriptionError 55 The request was discarded because the operation could not be completed");
    }

    @Test(timeout=7000)
    public void setTriggerTest_error() throws Throwable {
        final SequencingMonitor lsMonitor = new SequencingMonitor();
        device.addListener(new StdoutMpnDeviceListener() {
            @Override
            public void onStatusChanged(@NonNull String s, long l) {
                super.onStatusChanged(s, l);
                lsMonitor.signal("SIGNAL => onStatusChanged " + s);
            }
        });
        sub.addListener(new StdoutMpnSubscriptionListener() {
            @Override
            public void onSubscription() {
                super.onSubscription();
                lsMonitor.signal("SIGNAL => onSubscription");
            }

            @Override
            public void onModificationError(int i, String s, String s1) {
                super.onModificationError(i, s, s1);
                lsMonitor.signal("SIGNAL => onModificationError " + i + " " + s + " (" + s1 + ")");
            }
        });

        client.connect();
        client.registerForMpn(device);
        client.subscribe(sub, false);
        lsMonitor.await("SIGNAL => onSubscription");
        sub.setTriggerExpression("1==2");
        client.disconnect();
        lsMonitor.await("SIGNAL => onStatusChanged UNKNOWN");
        lsMonitor.await("SIGNAL => onModificationError 54 The request was aborted because the operation could not be completed (trigger)");

        client.connect();
        lsMonitor.await("SIGNAL => onStatusChanged REGISTERED");
    }

    @Test(timeout=7000)
    public void setNotificationTest_error() throws Throwable {
        final SequencingMonitor lsMonitor = new SequencingMonitor();
        device.addListener(new StdoutMpnDeviceListener() {
            @Override
            public void onStatusChanged(@NonNull String s, long l) {
                super.onStatusChanged(s, l);
                lsMonitor.signal("SIGNAL => onStatusChanged " + s);
            }
        });
        sub.addListener(new StdoutMpnSubscriptionListener() {
            @Override
            public void onSubscription() {
                super.onSubscription();
                lsMonitor.signal("SIGNAL => onSubscription");
            }

            @Override
            public void onModificationError(int i, String s, String s1) {
                super.onModificationError(i, s, s1);
                lsMonitor.signal("SIGNAL => onModificationError " + i + " " + s + " (" + s1 + ")");
            }
        });

        client.connect();
        client.registerForMpn(device);
        client.subscribe(sub, false);
        lsMonitor.await("SIGNAL => onSubscription");
        sub.setNotificationFormat("{}");
        client.disconnect();
        lsMonitor.await("SIGNAL => onStatusChanged UNKNOWN");
        lsMonitor.await("SIGNAL => onModificationError 54 The request was aborted because the operation could not be completed (notification_format)");

        client.connect();
        lsMonitor.await("SIGNAL => onStatusChanged REGISTERED");
    }
}