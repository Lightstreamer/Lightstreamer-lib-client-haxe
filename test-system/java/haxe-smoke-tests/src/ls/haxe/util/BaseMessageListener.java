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

import com.lightstreamer.client.ClientMessageListener;

public class BaseMessageListener implements ClientMessageListener {

	public BaseMessageListener() {
	}

	@Override
	public void onAbort(String arg0, boolean arg1) {
	}

	@Override
	public void onDeny(String arg0, int arg1, String arg2) {
	}

	@Override
	public void onDiscarded(String arg0) {
	}

	@Override
	public void onError(String arg0) {
	}

	@Override
	public void onProcessed(String arg0, String arg1) {
	}
}
