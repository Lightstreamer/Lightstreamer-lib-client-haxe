package com.lightstreamer.log;

import com.lightstreamer.client.NativeTypes;

final streamLogger = LogManager.getLogger("lightstreamer.stream");
final protocolLogger = LogManager.getLogger("lightstreamer.protocol");
final internalLogger = LogManager.getLogger("lightstreamer.internal");
final sessionLogger = LogManager.getLogger("lightstreamer.session");
final actionLogger = LogManager.getLogger("lightstreamer.actions");
final reachabilityLogger = LogManager.getLogger("lightstreamer.reachability");
final subscriptionLogger = LogManager.getLogger("lightstreamer.subscriptions");
final messageLogger = LogManager.getLogger("lightstreamer.messages");
final mpnDeviceLogger = LogManager.getLogger("lightstreamer.mpn.device");
final mpnSubscriptionLogger = LogManager.getLogger("lightstreamer.mpn.subscriptions");

inline function logFatal(logger: Logger, line: String, ?exception: Exception) {
  if (logger.isFatalEnabled()) {
    logger.fatal(line, exception);
  }
}

inline function logError(logger: Logger, line: String, ?exception: Exception) {
  if (logger.isErrorEnabled()) {
    logger.error(line, exception);
  }
}

inline function logWarn(logger: Logger, line: String, ?exception: Exception) {
  if (logger.isWarnEnabled()) {
    logger.warn(line, exception);
  }
}

inline function logInfo(logger: Logger, line: String, ?exception: Exception) {
  if (logger.isInfoEnabled()) {
    logger.info(line, exception);
  }
}

inline function logDebug(logger: Logger, line: String, ?exception: Exception) {
  if (logger.isDebugEnabled()) {
    logger.debug(line, exception);
  }
}