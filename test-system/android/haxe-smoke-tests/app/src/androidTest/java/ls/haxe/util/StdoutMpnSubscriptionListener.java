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
import androidx.annotation.Nullable;

import com.lightstreamer.client.mpn.MpnSubscriptionListener;

public class StdoutMpnSubscriptionListener implements MpnSubscriptionListener {
    @Override
    public void onListenStart() {

    }

    @Override
    public void onListenEnd() {

    }

    @Override
    public void onSubscription() {

    }

    @Override
    public void onUnsubscription() {

    }

    @Override
    public void onSubscriptionError(int i, @Nullable String s) {

    }

    @Override
    public void onUnsubscriptionError(int i, @Nullable String s) {

    }

    @Override
    public void onTriggered() {

    }

    @Override
    public void onStatusChanged(@NonNull String s, long l) {

    }

    @Override
    public void onPropertyChanged(@NonNull String s) {

    }

    @Override
    public void onModificationError(int i, String s, String s1) {

    }
}
