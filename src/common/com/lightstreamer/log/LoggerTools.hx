/*
 * Copyright (C) 2023 Lightstreamer Srl
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
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
