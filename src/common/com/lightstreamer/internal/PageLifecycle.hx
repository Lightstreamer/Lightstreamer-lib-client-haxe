package com.lightstreamer.internal;

import com.lightstreamer.internal.PlatformApi;
import com.lightstreamer.client.internal.ClientMachine;
import com.lightstreamer.log.LoggerTools.pageLogger;

// dummy implementation
class PageLifecycle implements IPageLifecycle {
  static public function newLoggingInstance() return new PageLifecycle(_ -> null);
  public var frozen(default, null): Bool = false;
  inline public function new(onEvent: PageState->Void) {}
  inline public function startListening() {}
  inline public function stopListening() {}
}