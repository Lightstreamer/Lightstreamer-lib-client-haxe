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