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
package ls.haxe.util;

import androidx.annotation.NonNull;

import com.lightstreamer.client.mpn.MpnDeviceListener;

public class BaseMpnDeviceListener implements MpnDeviceListener {
    @Override
    public void onListenStart() {

    }

    @Override
    public void onListenEnd() {

    }

    @Override
    public void onRegistered() {

    }

    @Override
    public void onSuspended() {

    }

    @Override
    public void onResumed() {

    }

    @Override
    public void onStatusChanged(@NonNull String s, long l) {

    }

    @Override
    public void onRegistrationFailed(int i, @NonNull String s) {

    }

    @Override
    public void onSubscriptionsUpdated() {

    }
}
