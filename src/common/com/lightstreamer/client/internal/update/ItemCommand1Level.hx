package com.lightstreamer.client.internal.update;

@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class ItemCommand1Level extends ItemCommand {

  override public function evtOnCS() {
    traceEvent("onCS");
    switch s_m {
    case s1, s2, s3, s4:
      goto(s_m);
      genDisposeKeys();
    default:
      // ignore
    }
  }

  override function createKey(keyName: String): ItemKey {
    return new Key1Level(keyName, this);
  }
}