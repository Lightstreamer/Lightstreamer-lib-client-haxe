#ifndef INCLUDED_Lightstreamer_ConnectionOptions
#define INCLUDED_Lightstreamer_ConnectionOptions

#include "../Lightstreamer.h"
#include "Lightstreamer/Proxy.h"

namespace Lightstreamer {

class ConnectionOptions {
  HaxeObject _delegate = nullptr;

  void initDelegate(HaxeObject client) {
    _delegate = LightstreamerClient_getConnectionOptions(client);
  }

  friend class LightstreamerClient;
public:
  ConnectionOptions(const ConnectionOptions&) = delete;
  ConnectionOptions& operator=(const ConnectionOptions&) = delete;

  ConnectionOptions() {}

  ~ConnectionOptions() {
    Lightstreamer_releaseHaxeObject(_delegate);
  }

  long getContentLength() {
    return ConnectionOptions_getContentLength(_delegate);
  }

  long getFirstRetryMaxDelay() {
    return ConnectionOptions_getFirstRetryMaxDelay(_delegate);
  }

  std::string getForcedTransport() {
    return ConnectionOptions_getForcedTransport(_delegate);
  }

  std::map<std::string, std::string> getHttpExtraHeaders() {
    return ConnectionOptions_getHttpExtraHeaders(_delegate);
  }

  long getIdleTimeout() {
    return ConnectionOptions_getIdleTimeout(_delegate);
  }

  long getKeepaliveInterval() {
    return ConnectionOptions_getKeepaliveInterval(_delegate);
  }

  std::string getRequestedMaxBandwidth() {
    return ConnectionOptions_getRequestedMaxBandwidth(_delegate);
  }

  std::string getRealMaxBandwidth() {
    return ConnectionOptions_getRealMaxBandwidth(_delegate);
  }

  long getPollingInterval() {
    return ConnectionOptions_getPollingInterval(_delegate);
  }

  long getReconnectTimeout() {
    return ConnectionOptions_getReconnectTimeout(_delegate);
  }

  long getRetryDelay() {
    return ConnectionOptions_getRetryDelay(_delegate);
  }

  long getReverseHeartbeatInterval() {
    return ConnectionOptions_getReverseHeartbeatInterval(_delegate);
  }

  long getStalledTimeout() {
    return ConnectionOptions_getStalledTimeout(_delegate);
  }

  long getSessionRecoveryTimeout() {
    return ConnectionOptions_getSessionRecoveryTimeout(_delegate);
  }

  bool isHttpExtraHeadersOnSessionCreationOnly() {
    return ConnectionOptions_isHttpExtraHeadersOnSessionCreationOnly(_delegate);
  }

  bool isServerInstanceAddressIgnored() {
    return ConnectionOptions_isServerInstanceAddressIgnored(_delegate);
  }

  bool isSlowingEnabled() {
    return ConnectionOptions_isSlowingEnabled(_delegate);
  }

  void setContentLength(long contentLength) {
    ConnectionOptions_setContentLength(_delegate, contentLength);
  }

  void setFirstRetryMaxDelay(long firstRetryMaxDelay) {
    ConnectionOptions_setFirstRetryMaxDelay(_delegate, firstRetryMaxDelay);
  }

  void setForcedTransport(const std::string& forcedTransport) {
    ConnectionOptions_setForcedTransport(_delegate, &forcedTransport);
  }

  void setHttpExtraHeaders(const std::map<std::string, std::string>& headers) {
    ConnectionOptions_setHttpExtraHeaders(_delegate, &headers);
  }

  void setHttpExtraHeadersOnSessionCreationOnly(bool httpExtraHeadersOnSessionCreationOnly) {
    ConnectionOptions_setHttpExtraHeadersOnSessionCreationOnly(_delegate, httpExtraHeadersOnSessionCreationOnly);
  }

  void setIdleTimeout(long idleTimeout) {
    ConnectionOptions_setIdleTimeout(_delegate, idleTimeout);
  }

  void setKeepaliveInterval(long keepaliveInterval) {
    ConnectionOptions_setKeepaliveInterval(_delegate, keepaliveInterval);
  }

  void setRequestedMaxBandwidth(const std::string& maxBandwidth) {
    ConnectionOptions_setRequestedMaxBandwidth(_delegate, &maxBandwidth);
  }

  void setPollingInterval(long pollingInterval) {
    ConnectionOptions_setPollingInterval(_delegate, pollingInterval);
  }

  void setReconnectTimeout(long reconnectTimeout) {
    ConnectionOptions_setReconnectTimeout(_delegate, reconnectTimeout);
  }

  void setRetryDelay(long retryDelay) {
    ConnectionOptions_setRetryDelay(_delegate, retryDelay);
  }

  void setReverseHeartbeatInterval(long reverseHeartbeatInterval) {
    ConnectionOptions_setReverseHeartbeatInterval(_delegate, reverseHeartbeatInterval);
  }

  void setServerInstanceAddressIgnored(bool serverInstanceAddressIgnored) {
    ConnectionOptions_setServerInstanceAddressIgnored(_delegate, serverInstanceAddressIgnored);
  }

  void setSlowingEnabled(bool slowingEnabled) {
    ConnectionOptions_setSlowingEnabled(_delegate, slowingEnabled);
  }

  void setStalledTimeout(long stalledTimeout) {
    ConnectionOptions_setStalledTimeout(_delegate, stalledTimeout);
  }

  void setSessionRecoveryTimeout(long sessionRecoveryTimeout) {
    ConnectionOptions_setSessionRecoveryTimeout(_delegate, sessionRecoveryTimeout);
  }

  // TODO cpp doc: an empty host results in the proxy being removed
  void setProxy(const Proxy& proxy) {
    ConnectionOptions_setProxy(_delegate, &proxy);
  }
};

} // namespace Lightstreamer

#endif // INCLUDED_Lightstreamer_ConnectionOptions