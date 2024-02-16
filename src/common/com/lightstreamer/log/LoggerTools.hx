package com.lightstreamer.log;

@:unreflective final streamLogger = LogManager.getLogger("lightstreamer.stream");
@:unreflective final protocolLogger = LogManager.getLogger("lightstreamer.protocol");
@:unreflective final internalLogger = LogManager.getLogger("lightstreamer.internal");
@:unreflective final sessionLogger = LogManager.getLogger("lightstreamer.session");
@:unreflective final actionLogger = LogManager.getLogger("lightstreamer.actions");
@:unreflective final reachabilityLogger = LogManager.getLogger("lightstreamer.reachability");
@:unreflective final subscriptionLogger = LogManager.getLogger("lightstreamer.subscriptions");
@:unreflective final messageLogger = LogManager.getLogger("lightstreamer.messages");
@:unreflective final cookieLogger = LogManager.getLogger("lightstreamer.cookies");
@:unreflective final pageLogger = LogManager.getLogger("lightstreamer.page");
#if LS_MPN
@:unreflective final mpnDeviceLogger = LogManager.getLogger("lightstreamer.mpn.device");
@:unreflective final mpnSubscriptionLogger = LogManager.getLogger("lightstreamer.mpn.subscriptions");
#end
