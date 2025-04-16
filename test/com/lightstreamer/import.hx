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
#if LS_HAS_PROXY
import com.lightstreamer.client.Proxy.LSProxy as Proxy;
#end
import com.lightstreamer.client.Subscription.LSSubscription as Subscription;
import com.lightstreamer.client.LightstreamerClient.LSLightstreamerClient as LightstreamerClient;
#if LS_MPN
import com.lightstreamer.client.mpn.MpnDevice.LSMpnDevice as MpnDevice;
import com.lightstreamer.client.mpn.MpnSubscription.LSMpnSubscription as MpnSubscription;
#end

import utils.*;
import utils.TestTools;

using Lambda;
using StringTools;
using utils.TestTools;