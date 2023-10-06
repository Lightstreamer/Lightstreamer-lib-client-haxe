package com.lightstreamer.client.internal;

import com.lightstreamer.client.internal.update.*;
import com.lightstreamer.internal.Types;
import com.lightstreamer.internal.MacroTools;

@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class ModeStrategyCommand2Level extends ModeStrategyCommand {
  public var requestedMaxFrequency: Null<RequestedMaxFrequency>;
  var aggregateRealMaxFrequency: Null<RealMaxFrequency>;

  override public function evtOnSUB(nItems: Int, nFields: Int, cmdIdx: Null<Pos>, keyIdx: Null<Pos>, currentFreq: Null<RequestedMaxFrequency>) {
    traceEvent("onSUB");
    if (s_m == s1) {
      doSUBCMD2Level(nItems, nFields, cmdIdx, keyIdx, currentFreq);
      goto(s2);
    }
  }

  override public function evtSetRequestedMaxFrequency(freq: Null<RequestedMaxFrequency>) {
    traceEvent("setRequestedMaxFrequency");
    switch s_m {
    case s1, s2:
      doSetRequestedMaxFrequency(freq);
      goto(s_m);
      genSetRequestedMaxFrequency();
    default:
      // ignore
    }
  }

  public function evtOnRealMaxFrequency2LevelAdded(freq: Null<RealMaxFrequency>) {
    traceEvent("onRealMaxFrequency2LevelAdded");
    if (s_m == s2) {
      doAggregateFrequenciesWhenFreqIsAdded(freq);
      goto(s2);
    }
  }

  public function evtOnRealMaxFrequency2LevelRemoved() {
    traceEvent("onRealMaxFrequency2LevelRemoved");
    if (s_m == s2) {
      doAggregateFrequenciesWhenFreqIsRemoved();
      goto(s2);
    }
  }

  override public function evtOnCONF(freq: RealMaxFrequency) {
    traceEvent("onCONF");
    if (s_m == s2) {
      doCONF2Level(freq);
      doAggregateFrequenciesWhenFreqIsAdded(freq);
      goto(s2);
    }
  }

  override function createItem(itemIdx: Pos): ItemBase {
    return new ItemCommand2Level(itemIdx, subscription, this, client, m_subId);
  }

  @:nullSafety(Off)
  function doSUBCMD2Level(nItems: Int, nFields: Int, cmdIdx: Null<Pos>, keyIdx: Null<Pos>, currentFreq: Null<RequestedMaxFrequency>) {
    var items = subscription.fetchItems();
    var fields = subscription.fetchFields();
    assert(items != null ? nItems == items.length : true);
    assert(fields != null ? nFields == fields.length : true);
    assert(fields != null ? cmdIdx - 1 == fields.indexOf("command") : true);
    assert(fields != null ? keyIdx - 1 == fields.indexOf("key") : true);
    requestedMaxFrequency = currentFreq;
  }

  function doSetRequestedMaxFrequency(maxFrequency: Null<RequestedMaxFrequency>) {
    requestedMaxFrequency = maxFrequency;
  }

  function genSetRequestedMaxFrequency() {
    for (_ => item in items) {
      cast(item, ItemCommand2Level).evtSetRequestedMaxFrequency();
    }
  }

  function doCONF2Level(maxFrequency: RealMaxFrequency) {
    realMaxFrequency = maxFrequency;
  }

  function maxFreq(cumulated: Null<RealMaxFrequency>, freq: Null<RealMaxFrequency>): Null<RealMaxFrequency> {
    /*
     +----------------+-----------+----------------------+-----------+
     | MAX(curr, freq)| null      | Number               | unlimited |
     | curr/freq      |           |                      |           |
     +----------------+-----------+----------------------+-----------+
     | null           | freq      | freq                 | freq      |
     +----------------+-----------+----------------------+-----------+
     | Number         | curr      | MAX(curr, freq)      | freq      |
     +----------------+-----------+----------------------+-----------+
     | unlimited      | curr      | curr                 | curr      |
     +----------------+-----------+----------------------+-----------+
     */
    var newMax: Null<RealMaxFrequency>;
    switch cumulated {
    case RFreqLimited(var dc):
      switch freq {
      case RFreqLimited(var df):
        newMax = RFreqLimited(Math.max(dc, df));
      case RFreqUnlimited:
        newMax = freq;
      case null:
        newMax = cumulated;
      }
    case RFreqUnlimited:
      newMax = cumulated;
    case null:
      newMax = freq;
    }
    return newMax;
  }

  function doAggregateFrequenciesWhenFreqIsAdded(freq: Null<RealMaxFrequency>) {
    var newMax = maxFreq(aggregateRealMaxFrequency, freq);
    var prevMax = aggregateRealMaxFrequency;
    aggregateRealMaxFrequency = newMax;
    
    if (!realFrequencyEquals(prevMax, newMax)) {
      subscription.fireOnRealMaxFrequency(newMax, m_subId);
    }
  }

  function doAggregateFrequenciesWhenFreqIsRemoved() {
    var newMax = realMaxFrequency;
    var breakOuterLoop = false;
    for (_ => item in items) {
      for (_ => key in cast(item, ItemCommand2Level).keys) {
        var freq = cast(key, Key2Level).realMaxFrequency;
        newMax = maxFreq(newMax, freq);
        if (newMax == RFreqUnlimited) {
          breakOuterLoop = true;
          break;
        }
      }
      if (breakOuterLoop) break;
    }
    var prevMax = aggregateRealMaxFrequency;
    aggregateRealMaxFrequency = newMax;
    
    if (!realFrequencyEquals(prevMax, newMax)) {
      subscription.fireOnRealMaxFrequency(newMax, m_subId);
    }
  }
}