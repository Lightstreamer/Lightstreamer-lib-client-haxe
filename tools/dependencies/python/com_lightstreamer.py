import aiohttp
import asyncio
from threading import Thread

class LS_IO_Thread(Thread):
  def __init__(self):
    super().__init__(name="LS_IO", daemon=True)

  def run(self):
    self.loop = asyncio.new_event_loop()
    asyncio.set_event_loop(self.loop)
    self.loop.run_forever()

  def submit_coro(self, coro):
    asyncio.run_coroutine_threadsafe(coro, self.loop)

  def create_future(self):
    return self.loop.create_future()

ls_io_thread = LS_IO_Thread()
ls_io_thread.start()

class SessionPy:
  session = None

  @staticmethod
  def getInstance():
    if SessionPy.session is None:
      SessionPy.session = aiohttp.ClientSession()
    return SessionPy.session

  @staticmethod
  async def freeInstance():
    if SessionPy.session is not None:
      session = SessionPy.session
      SessionPy.session = None
      await session.close()

class HttpClientPy:
  def __init__(self):
    #self.loop = ls_io_thread.loop
    self.isCanceled = False
    #self.cancellationToken = self.loop.create_future()
    self.cancellationToken = ls_io_thread.create_future()

  def sendAsync(self, url, body, headers):
    #self.loop.create_task(self._sendAsync(url, body, headers))
    ls_io_thread.submit_coro(self._sendAsync(url, body, headers))

  async def _sendAsync(self, url, body, headers):
    if headers is None:
      headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded; charset=utf-8"
    try:
      session = SessionPy.getInstance()
      async with session.request("POST", url, data=body, headers=headers) as resp:
        self.cancellationToken.set_result(resp)
        if not resp.ok:
          raise Exception("Unexpected HTTP code: " + resp.status)
        async for line in resp.content:
          self.on_text(self, line.decode("utf-8").rstrip('\r\n'))
      self.on_done(self)
    except BaseException as ex:
      if not self.isDisposed():
        self.on_error(self, ex)
  
  def dispose(self):
    if not self.isCanceled:
      self.isCanceled = True
      if self.cancellationToken.done():
        resp = self.cancellationToken.result()
        resp.close()
      else:
        def on_done_callback(future):
          resp = future.result()
          resp.close()
        self.cancellationToken.add_done_callback(on_done_callback)

  def isDisposed(self):
    return self.isCanceled

  def on_text(self, client, line):
    pass

  def on_error(self, client, exception):
    pass

  def on_done(self, client):
    pass

class WsClientPy:
  def __init__(self):
    #self.loop = ls_io_thread.loop
    self.isCanceled = False
    #self.cancellationToken = self.loop.create_future()
    self.cancellationToken = ls_io_thread.create_future()

  def connectAsync(self, url, protocol, headers):
    #self.loop.create_task(self._connectAsync(url, protocol, headers))
    ls_io_thread.submit_coro(self._connectAsync(url, protocol, headers))

  async def _connectAsync(self, url, protocol, headers):
    try:
      session = SessionPy.getInstance()
      async with session.ws_connect(url, protocols=(protocol,), headers=headers) as ws:
        self.cancellationToken.set_result(ws)
        self.ws = ws
        self.on_open(self)
        async for msg in ws:
          if msg.type == aiohttp.WSMsgType.TEXT:
            for line in msg.data.split('\r\n'):
              if line != '':
                self.on_text(self, line)
          else:
            raise Exception("Unexpected Websocket message: " + msg.type)
    except BaseException as ex:
      if not self.isDisposed():
        self.on_error(self, ex)

  def sendAsync(self, txt):
    #self.loop.create_task(self.ws.send_str(txt))
    ls_io_thread.submit_coro(self.ws.send_str(txt))

  def dispose(self):
    if not self.isCanceled:
      self.isCanceled = True
      if self.cancellationToken.done():
        resp = self.cancellationToken.result()
        #self.loop.create_task(resp.close())
        ls_io_thread.submit_coro(resp.close())
      else:
        async def on_done_callback(future):
          resp = future.result()
          #self.loop.create_task(resp.close())
          ls_io_thread.submit_coro(resp.close())
        self.cancellationToken.add_done_callback(on_done_callback)

  def isDisposed(self):
    return self.isCanceled

  def on_open(self, client):
    pass

  def on_text(self, client, line):
    pass

  def on_error(self, client, exception):
    pass