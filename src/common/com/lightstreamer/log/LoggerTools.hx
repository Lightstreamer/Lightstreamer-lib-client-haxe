package com.lightstreamer.log;

import com.lightstreamer.internal.NativeTypes;

@:unreflective final streamLogger = LogManager.getLogger("lightstreamer.stream");
@:unreflective final protocolLogger = LogManager.getLogger("lightstreamer.protocol");
@:unreflective final internalLogger = LogManager.getLogger("lightstreamer.internal");
@:unreflective final sessionLogger = LogManager.getLogger("lightstreamer.session");
@:unreflective final actionLogger = LogManager.getLogger("lightstreamer.actions");
@:unreflective final reachabilityLogger = LogManager.getLogger("lightstreamer.reachability");
@:unreflective final subscriptionLogger = LogManager.getLogger("lightstreamer.subscriptions");
@:unreflective final messageLogger = LogManager.getLogger("lightstreamer.messages");
@:unreflective final mpnDeviceLogger = LogManager.getLogger("lightstreamer.mpn.device");
@:unreflective final mpnSubscriptionLogger = LogManager.getLogger("lightstreamer.mpn.subscriptions");
@:unreflective final cookieLogger = LogManager.getLogger("lightstreamer.cookies");

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

inline function logDebugEx(logger: Logger, line: String, ?exception: haxe.Exception) {
  if (logger.isDebugEnabled()) {
    logger.debug(line + "\n" + exception.details());
  }
}