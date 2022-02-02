
js only
- removed ConnectionSharing

revised logging mechanism (same API on all platforms)

removed methods
- ConnectionOptions.getConnectTimeout
- ConnectionOptions.setConnectTimeout
- ConnectionOptions.getCurrentConnectTimeout
- ConnectionOptions.setCurrentConnectTimeout
- ConnectionOptions.isEarlyWSOpenEnabled
- ConnectionOptions.setEarlyWSOpenEnabled

added methods
- MpnSubscription.getActualTriggerExpression
- MpnSubscription.getActualNotificationFormat

removed methods on android
- MpnBuilder.contentAvailable(String contentAvailable)
- MpnBuilder.contentAvailableAsString()
- MpnBuilder.contentAvailable(boolean contentAvailable)
- MpnBuilder.contentAvailableAsBool()

moved classes
- to com.lightstreamer.client.mpn.MpnDevice from com.lightstreamer.client.mpn.android.MpnDevice
- to com.lightstreamer.client.mpn.MpnBuilder from com.lightstreamer.client.mpn.util.MpnBuilder