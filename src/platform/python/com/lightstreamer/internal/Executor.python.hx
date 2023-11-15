package com.lightstreamer.internal;

import python.lib.threading.Thread;

class Executor {
  final thread: Thread;
  final loop: Asyncio.EventLoop;

  public function new() {
    loop = Asyncio.new_event_loop();
    thread = new Thread({target: () -> {
      Asyncio.set_event_loop(loop);
      loop.run_forever();
      loop.close();
    },
    daemon: true
  });
    thread.start();
  }

  inline public function submit(callback: ()->Void) {
    loop.call_soon_threadsafe(callback);
  }

  inline public function schedule(callback: ()->Void, delay: Types.Millis) {
    return loop.call_later_threadsafe(delay / 1000.0, callback);
  }

  public function stop() {
    loop.call_soon_threadsafe(loop.stop);
    thread.join();
  }
}