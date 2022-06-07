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
@:unreflective final cookieLogger = LogManager.getLogger("lightstreamer.cookies");
#if LS_MPN
@:unreflective final mpnDeviceLogger = LogManager.getLogger("lightstreamer.mpn.device");
@:unreflective final mpnSubscriptionLogger = LogManager.getLogger("lightstreamer.mpn.subscriptions");
#end

inline function logFatal(logger: Logger, line: String, ?exception: NativeException) {
  if (logger.isFatalEnabled()) {
    logger.fatal(line, exception);
  }
}

inline function logError(logger: Logger, line: String, ?exception: NativeException) {
  if (logger.isErrorEnabled()) {
    logger.error(line, exception);
  }
}

inline function logErrorEx(logger: Logger, line: String, exception: haxe.Exception) {
  if (logger.isErrorEnabled()) {
    logger.error(line + "\n" + exception.details());
  }
}

inline function logWarn(logger: Logger, line: String, ?exception: NativeException) {
  if (logger.isWarnEnabled()) {
    logger.warn(line, exception);
  }
}

inline function logInfo(logger: Logger, line: String, ?exception: NativeException) {
  if (logger.isInfoEnabled()) {
    logger.info(line, exception);
  }
}

inline function logDebug(logger: Logger, line: String, ?exception: NativeException) {
  if (logger.isDebugEnabled()) {
    logger.debug(line, exception);
  }
}

inline function logDebugEx(logger: Logger, line: String, exception: haxe.Exception) {
  if (logger.isDebugEnabled()) {
    logger.debug(line + "\n" + exception.details());
  }
}

inline function logTrace(logger: Logger, line: String, ?exception: NativeException) {
  if (logger.isTraceEnabled()) {
    logger.trace(line, exception);
  }
}