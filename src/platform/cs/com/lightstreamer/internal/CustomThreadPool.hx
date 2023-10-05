package com.lightstreamer.internal;

// source: https://learn.microsoft.com/en-us/archive/msdn-magazine/2005/february/net-matters-file-copy-progress-custom-thread-pools
@:cs.using("System", "System.Threading", "System.Collections.Generic")
@:classCode('
private Semaphore _workWaiting;
private Queue<WaitQueueItem> _queue;
private List<Thread> _threads;

public void Dispose() {
    if (_threads != null) {
        _threads.ForEach(delegate (Thread t) { t.Interrupt(); });
        _threads = null;
    }
}

public void QueueUserWorkItem(WaitCallback callback, object state) {
    if (_threads == null)
        throw new ObjectDisposedException(GetType().Name);
    if (callback == null)
        throw new ArgumentNullException("callback");
    WaitQueueItem item = new WaitQueueItem();
    item.Callback = callback;
    item.State = state;
    item.Context = ExecutionContext.Capture();
    lock (_queue)
        _queue.Enqueue(item);
    _workWaiting.Release();
}

private void Run() {
    try {
        while (true) {
            _workWaiting.WaitOne();
            WaitQueueItem item;
            lock (_queue)
                item = _queue.Dequeue();
            ExecutionContext.Run(item.Context, new ContextCallback(item.Callback), item.State);
        }
    } catch (ThreadInterruptedException) {
    }
}

private class WaitQueueItem {
    public WaitCallback Callback;
    public object State;
    public ExecutionContext Context;
}')
@:nativeGen
class CustomThreadPool {

  @:functionCode('
  if (numThreads <= 0)
      throw new ArgumentOutOfRangeException("numThreads");
  _threads = new List<Thread>(numThreads);
  _queue = new Queue<WaitQueueItem>();
  _workWaiting = new Semaphore(0, int.MaxValue);
  for (int i = 0; i < numThreads; i++) {
      Thread t = new Thread(Run);
      t.IsBackground = true;
      _threads.Add(t);
      t.Start();
  }')
  public function new(numThreads: Int) {}

  extern public function Dispose(): Void;

  extern public function QueueUserWorkItem(callback: cs.system.threading.WaitCallback, state: Null<cs.system.Object>): Void;
}
