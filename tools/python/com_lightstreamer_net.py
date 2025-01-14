import aiohttp
import asyncio
from threading import Thread
from threading import Lock
from yarl import URL
from http.cookies import SimpleCookie

class LS_IO_Thread(Thread):
  def __init__(self):
    super().__init__(name="LS_IO", daemon=True)
    self.loop = asyncio.new_event_loop()

  def run(self):
    asyncio.set_event_loop(self.loop)
    self.loop.run_forever()

  def submit_coro(self, coro):
    return asyncio.run_coroutine_threadsafe(coro, self.loop)

  def create_future(self):
    return self.loop.create_future()

ls_io_thread = LS_IO_Thread()
ls_io_thread.start()

class CookieHelper:
  instance = None

  @staticmethod
  def getInstance():
    if CookieHelper.instance is None:
      CookieHelper.instance = CookieHelper()
    return CookieHelper.instance

  def __init__(self):
    self.jar = aiohttp.CookieJar()
    self._lock = Lock()

  def addCookies(self, uri, cookies):
    with self._lock:
      self.jar.update_cookies(cookies, URL(uri))

  def getCookies(self, uri):
    with self._lock:
      if uri is None:
        cookies = SimpleCookie()
        for cookie in self.jar:
          cookies[cookie.key] = cookie
        return cookies
      else:
        return self.jar.filter_cookies(URL(uri))
  
  def clearCookies(self):
    with self._lock:
      self.jar.clear()

class SessionPy:
  session = None

  @staticmethod
  def getInstance():
    if SessionPy.session is None:
      SessionPy.session = aiohttp.ClientSession(cookie_jar=CookieHelper.getInstance().jar)
    return SessionPy.session

  @staticmethod
  async def freeInstance():
    if SessionPy.session is not None:
      session = SessionPy.session
      SessionPy.session = None
      await session.close()

def build_proxy(proxy):
  proxy_url = None
  proxy_auth = None
  if proxy is not None:
    proxy_url = proxy.url
    if proxy.user is not None:
      proxy_auth = aiohttp.BasicAuth(proxy.user, password=proxy.password)
  return proxy_url, proxy_auth

class HttpClientPy:
  def __init__(self):
    self.isCanceled = False
    self.cancellationToken = ls_io_thread.create_future()

  def sendAsync(self, url, body, headers, proxy, sslContext):
    ls_io_thread.submit_coro(self._sendAsync(url, body, headers, proxy, sslContext))

  async def _sendAsync(self, url, body, headers, proxy, sslContext):
    if headers is None:
      headers = {}
    headers["Content-Type"] = "text/plain; charset=utf-8"
    proxy_url, proxy_auth = build_proxy(proxy)
    try:
      session = SessionPy.getInstance()
      async with session.request("POST", url, data=body, headers=headers, proxy=proxy_url, proxy_auth=proxy_auth, ssl=sslContext) as resp:
        self.cancellationToken.set_result(resp)
        if not resp.ok:
          raise Exception("Unexpected HTTP code: " + str(resp.status))
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
    self.isCanceled = False
    self.cancellationToken = ls_io_thread.create_future()

  def connectAsync(self, url, protocol, headers, proxy, sslContext):
    ls_io_thread.submit_coro(self._connectAsync(url, protocol, headers, proxy, sslContext))

  async def _connectAsync(self, url, protocol, headers, proxy, sslContext):
    proxy_url, proxy_auth = build_proxy(proxy)
    try:
      session = SessionPy.getInstance()
      async with session.ws_connect(url, protocols=(protocol,), headers=headers, proxy=proxy_url, proxy_auth=proxy_auth, ssl=sslContext) as ws:
        self.cancellationToken.set_result(ws)
        self.ws = ws
        self.on_open(self)
        async for msg in ws:
          if msg.type == aiohttp.WSMsgType.TEXT:
            for line in msg.data.split('\r\n'):
              if line != '':
                self.on_text(self, line)
          else:
            raise Exception("Unexpected Websocket message: " + str(msg.type))
    except BaseException as ex:
      if not self.isDisposed():
        self.on_error(self, ex)

  def sendAsync(self, txt):
    ls_io_thread.submit_coro(self.ws.send_str(txt))

  def dispose(self):
    if not self.isCanceled:
      self.isCanceled = True
      if self.cancellationToken.done():
        resp = self.cancellationToken.result()
        ls_io_thread.submit_coro(resp.close())
      else:
        async def on_done_callback(future):
          resp = future.result()
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

async def _initModule():
  # init the singletons SessionPy and CookieHelper
  SessionPy.getInstance()

ls_io_thread.submit_coro(_initModule()).result()