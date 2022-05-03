package com.lightstreamer.client.internal.update;

import com.lightstreamer.internal.Types.Pos;

interface ItemKey {
  function evtUpdate(keyValue: Map<Pos, Null<String>>, snapshot: Bool): Void;
  function evtSetRequestedMaxFrequency(): Void;
  function evtDispose(): Void;
  function getCommandValue(fieldIdx: Pos): Null<String>;
}