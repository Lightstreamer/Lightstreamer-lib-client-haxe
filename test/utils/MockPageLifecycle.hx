package utils;

import com.lightstreamer.internal.PlatformApi;

#if LS_WEB
import js.Browser;
import com.lightstreamer.log.LoggerTools.pageLogger;

class MockPageLifecycle implements IPageLifecycle {
  public var onEvent(default, null): PageState -> Void;
  public var frozen(default, default): Bool = false;

  public function create(onEvent: PageState->Void) {
    this.onEvent = onEvent;
    return this;
  }
  public function new() {}
  public function startListening() {}
  public function stopListening() {}
  public function freeze() {
    Browser.window.setTimeout(() -> {
      pageLogger.warn('Frozen event detected');
      frozen = true;
      onEvent(Frozen);
    });
  }
  public function resume() {
    Browser.window.setTimeout(() -> {
      pageLogger.warn('Resumed event detected');
      frozen = false;
      onEvent(Resumed);
    });
  }
}
#else
class MockPageLifecycle implements IPageLifecycle {
  public function create(onEvent: PageState->Void) return this;
  public var frozen(default, default): Bool = false;
  public function new() {}
  public function startListening() {}
  public function stopListening() {}
}
#end