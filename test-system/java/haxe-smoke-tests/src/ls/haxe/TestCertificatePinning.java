package ls.haxe;

import static java.util.Arrays.asList;
import static org.junit.Assert.*;

import org.junit.After;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

import com.lightstreamer.client.LightstreamerClient;
import com.lightstreamer.log.ConsoleLogLevel;
import com.lightstreamer.log.ConsoleLoggerProvider;

import haxe.Exception;
import ls.haxe.util.BaseClientListener;
import net.jodah.concurrentunit.ConcurrentTestCase;

public class TestCertificatePinning extends ConcurrentTestCase {
	LightstreamerClient client;
	/*
	 * The certificate pins below are derived using the SSL Server Test tool:
	 * 
	 * https://www.ssllabs.com/ssltest/analyze.html?d=push.lightstreamer.com
	 */
	// Leaf certificate pin of push.lightstreamer.com
	final String leafCertificate = "sha256/j12gjVRVSgVtL8OCXyx2fpULjxJNIRIKpCrjWUxVdvw=";
	// Intermediate certificate pin of push.lightstreamer.com
	final String intermediateCertificate = "sha256/iFvwVyJSxnQdyaUvUERIf+8qk7gRze3612JMwoO3zdU=";
	// Other pins
	final String bogusCertificate = "sha256/mExQV1m8P3X5mz2EsY3ascQlMz1NAdjrKvfvR6FUMI0=";
	final String bogusCertificate2 = "sha256/vh78KSg1Ry4NaqGDV10w/cTb9VH3BQUZoCWNa93W/EY=";
	
	@BeforeClass
	public static void setUpClass() throws Exception {
		System.out.println(LightstreamerClient.LIB_NAME + " " + LightstreamerClient.LIB_VERSION);
		LightstreamerClient.setLoggerProvider(new ConsoleLoggerProvider(ConsoleLogLevel.ERROR));
	}
	
	@Before
	public void setUp() throws Exception {
	}

	@After
	public void tearDown() throws Exception {
		client.disconnect();
	}
	
	@Test
	public void testMalformedCertificate() throws Exception {
		client = new LightstreamerClient("https://push.lightstreamer.com", "DEMO");
		try {
			client.connectionDetails.setCertificatePins(asList(
					"malformed-pin"));
			fail("Expeceted excepiton");
		} catch(IllegalArgumentException e) {
			assertEquals("Pins must start with \"sha256/\" or \"sha1/\": malformed-pin", e.getMessage());
		}
		try {
			client.connectionDetails.setCertificatePins(asList(
					"sha256/malformed-pin!"));
			fail("Expeceted excepiton");
		} catch(IllegalArgumentException e) {
			assertEquals("Invalid pin hash: sha256/malformed-pin!", e.getMessage());
		}
	}
	
	@Test
	public void testOnPropertyChange() throws Throwable {
		client = new LightstreamerClient("https://push.lightstreamer.com", "DEMO");
		client.addListener(new BaseClientListener() {
			public void onPropertyChange(String prop) {
				if (prop.equals("certificatePins")) {
					resume();
				}
			}
		});
		client.connectionDetails.setCertificatePins(asList(
				leafCertificate));
		await(3000);
	}

	@Test
	public void testGoodCertificate() throws Throwable {
		client = new LightstreamerClient("https://push.lightstreamer.com", "DEMO");
		client.addListener(new BaseClientListener() {
			public void onStatusChange(String status) {
				if (status.equals("CONNECTED:WS-STREAMING")) {
					resume();
				}
			}
		});
		client.connectionDetails.setCertificatePins(asList(
				leafCertificate));
		client.connect();
		await(3000);
	}

	@Test
	public void testBadCertificate() throws Throwable {
		client = new LightstreamerClient("https://push.lightstreamer.com", "DEMO");
		client.addListener(new BaseClientListener() {
			public void onServerError(int code, String msg) {
				threadAssertEquals("62 Unrecognized server's identity", code + " " + msg);
				resume();
			}
		});
		client.connectionDetails.setCertificatePins(asList(
				bogusCertificate));
		client.connect();
		await(3000);
	}
	
	@Test
	public void testGetCertificatePins() throws Exception {
		client = new LightstreamerClient("https://push.lightstreamer.com", "DEMO");
		client.connectionDetails.setCertificatePins(asList(
				leafCertificate,
				intermediateCertificate));
		assertEquals(asList(leafCertificate, intermediateCertificate), 
				client.connectionDetails.getCertificatePins());
	}
	
	@Test
    public void testSetCertificatePinsWithNull() throws Exception {
		client = new LightstreamerClient("https://push.lightstreamer.com", "DEMO");
		try {
			client.connectionDetails.setCertificatePins(null);
			fail("Expected exception");
		} catch(IllegalArgumentException e) {
			assertEquals("Pins list cannot be null", e.getMessage());
		}
	}
}
