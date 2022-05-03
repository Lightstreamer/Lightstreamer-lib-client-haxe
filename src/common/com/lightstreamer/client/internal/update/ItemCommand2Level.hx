package com.lightstreamer.client.internal.update;

import com.lightstreamer.internal.Types;

@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class ItemCommand2Level extends ItemCommand {
  public final strategy: ModeStrategyCommand2Level;

  public function new(itemIdx: Pos, sub: Subscription, strategy: ModeStrategyCommand2Level, client: ClientMachine, subId: Int) {
    super(itemIdx, sub, client, subId);
    this.strategy = strategy;
  }

  override public function evtOnCS() {
    traceEvent("onCS");
    switch s_m {
    case s1, s2, s3, s4:
      goto(s_m);
      genDisposeKeys();
      genOnRealMaxFrequency2LevelRemoved();
    default:
      // ignore
    }
  }

  public function evtSetRequestedMaxFrequency() {
    traceEvent("setRequestedMaxFrequency");
    switch s_m {
    case s1, s2, s3, s4:
      goto(s_m);
      genSetRequestedMaxFrequency();
    default:
      // ignore
    }
  }

  override function createKey(keyName: String): ItemKey {
    return new Key2Level(keyName, this);
  }
  
  function genSetRequestedMaxFrequency() {
    for (_ => key in keys) {
      key.evtSetRequestedMaxFrequency();
    }
  }
  
  function genOnRealMaxFrequency2LevelRemoved() {
    strategy.evtOnRealMaxFrequency2LevelRemoved();
  }
}