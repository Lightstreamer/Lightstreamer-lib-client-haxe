#if LS_HAS_PROXY
import com.lightstreamer.client.Proxy.LSProxy as Proxy;
#end
import com.lightstreamer.client.Subscription.LSSubscription as Subscription;
import com.lightstreamer.client.ConnectionDetails.LSConnectionDetails as ConnectionDetails;
import com.lightstreamer.client.ConnectionOptions.LSConnectionOptions as ConnectionOptions;
import com.lightstreamer.client.LightstreamerClient.LSLightstreamerClient as LightstreamerClient;
#if LS_MPN
import com.lightstreamer.client.mpn.MpnDevice.LSMpnDevice as MpnDevice;
import com.lightstreamer.client.mpn.MpnSubscription.LSMpnSubscription as MpnSubscription;
#end
