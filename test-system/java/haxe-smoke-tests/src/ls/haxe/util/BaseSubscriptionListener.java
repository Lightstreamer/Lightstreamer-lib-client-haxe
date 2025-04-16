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

import com.lightstreamer.client.ItemUpdate;
import com.lightstreamer.client.SubscriptionListener;

public class BaseSubscriptionListener implements SubscriptionListener {

	public BaseSubscriptionListener() {
	}

	@Override
	public void onClearSnapshot(String arg0, int arg1) {
	}

	@Override
	public void onCommandSecondLevelItemLostUpdates(int arg0, String arg1) {
	}

	@Override
	public void onCommandSecondLevelSubscriptionError(int arg0, String arg1, String arg2) {
	}

	@Override
	public void onEndOfSnapshot(String arg0, int arg1) {
	}

	@Override
	public void onItemLostUpdates(String arg0, int arg1, int arg2) {
	}

	@Override
	public void onItemUpdate(ItemUpdate arg0) {
	}

	@Override
	public void onListenEnd() {
	}

	@Override
	public void onListenStart() {
	}

	@Override
	public void onRealMaxFrequency(String arg0) {
	}

	@Override
	public void onSubscription() {
	}

	@Override
	public void onSubscriptionError(int arg0, String arg1) {
	}

	@Override
	public void onUnsubscription() {
	}
}
