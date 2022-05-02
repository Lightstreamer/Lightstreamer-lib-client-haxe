package com.lightstreamer.client.internal.update;

import com.lightstreamer.internal.Types;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

private enum abstract State_m(Int) {
  var s1 = 1; var s2 = 2; var s3 = 3; var s4 = 4;
}

@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class ItemMerge extends ItemBase {
  var s_m: State_m = s1;

  override public function evtUpdate(values: Map<Pos, FieldValue>) {
    traceEvent("update");
    switch s_m {
    case s1:
      if (subscription.hasSnapshot()) {
        doSnapshot(values);
        goto(s2);
      } else {
        doFirstUpdate(values);
        goto(s3);
      }
    case s2:
      doUpdate0(values);
      goto(s3);
    case s3:
      doUpdate0(values);
      goto(s3);
    default:
      // ignore
    }
  }

  override public function evtDispose(strategy: ModeStrategy) {
    traceEvent("dispose");
    switch s_m {
    case s1, s2, s3:
      finalize();
      goto(s4);
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