package com.lightstreamer.client.internal.update;

import com.lightstreamer.internal.Types;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

private  enum abstract State_m(Int) {
  var s1 = 1; var s2 = 2; var s3 = 3;
}

@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class ItemRaw extends ItemBase {
  var s_m: State_m = s1;

  override public function evtUpdate(values: Map<Pos, FieldValue>) {
    traceEvent("update");
    switch s_m {
    case s1:
      doFirstUpdate(values);
      goto(s2);
    case s2:
      doUpdate0(values);
      goto(s2);
    default:
      // ignore
    }
  }

  override public function evtDispose(strategy: ModeStrategy) {
    traceEvent("dispose");
    switch s_m {
    case s1, s2:
      finalize();
      goto(s3);
      strategy.unrelate(itemIdx);
    default:
      // ignore
    }
  }

  function goto(to: State_m) {
    s_m = to;
    internalLogger.logTrace('sub#itm#goto($m_subId:$itemIdx) $s_m');
  }

  function traceEvent(evt: String) {
    internalLogger.logTrace('sub#itm#$evt($m_subId:$itemIdx) in $s_m');
  }
}