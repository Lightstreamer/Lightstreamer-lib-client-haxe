
# js only

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

# nodejs

- LightstreamerClient.addCookies: remove "It can be null." from uri parameter docs (unified with Java)

- ConnectionOptions.setHttpExtraHeaders: remove "Note that when the value is set WebSockets are disabled unless ConnectionOptions#setHttpExtraHeadersOnSessionCreationOnly is set to true" from docs
- ConnectionOptions.setHttpExtraHeadersOnSessionCreationOnly: remove "as a consequence, if any extra header is actually specified, WebSockets will be disabled (as the current browser client API does not support the setting of custom HTTP headers)" from docs