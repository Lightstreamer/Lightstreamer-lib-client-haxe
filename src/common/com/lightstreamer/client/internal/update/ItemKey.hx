package com.lightstreamer.client.internal.update;

import com.lightstreamer.internal.Types.Pos;
import com.lightstreamer.client.internal.update.UpdateUtils;

interface ItemKey {
  function evtUpdate(keyValue: Map<Pos, Null<CurrFieldVal>>, snapshot: Bool): Void;
  function evtSetRequestedMaxFrequency(): Void;
  function evtDispose(): Void;
  function getCommandValue(fieldIdx: Pos): Null<String>;
}