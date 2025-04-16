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
package com.lightstreamer.client.internal;

import com.lightstreamer.client.internal.update.ItemCommand1Level;
import com.lightstreamer.client.internal.update.ItemBase;
import com.lightstreamer.internal.Types;

@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class ModeStrategyCommand1Level extends ModeStrategyCommand {
  
  override function createItem(itemIdx: Pos): ItemBase {
    return new ItemCommand1Level(itemIdx, subscription, client, m_subId);
  }
}