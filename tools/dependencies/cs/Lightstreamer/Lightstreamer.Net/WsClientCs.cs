using System;
using System.Collections.Generic;
using System.IO;
using System.Net.Security;
using System.Net.WebSockets;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace com.lightstreamer.cs
{
    public class WsClientCs
    {
        private readonly ClientWebSocket ws;
        private volatile bool isCanceled = false;

        public WsClientCs()
        {
            ws = new ClientWebSocket();
        }

        public async Task ConnectAsync(
            string url, string protocol,
            IDictionary<string, string> headers,
            Proxy proxy,
            RemoteCertificateValidationCallback certificateValidator)
        {
            try
            {
                // set sub-protocol
                ws.Options.AddSubProtocol(protocol);
                // set headers
                if (headers != null)
                {
                    foreach (var h in headers)
                    {
                        ws.Options.SetRequestHeader(h.Key, h.Value);
                    }
                }
                // set cookies
                ws.Options.Cookies = CookieHelper.instance.GetCookieContainer();
                // set proxy
                if (proxy != null)
                {
                    var uriBuilder = new UriBuilder(proxy.Host);
                    uriBuilder.Port = proxy.Port;
                    var webProxy = new System.Net.WebProxy(uriBuilder.Uri);
                    if (proxy.User != null)
                    {
                        webProxy.Credentials = new System.Net.NetworkCredential(proxy.User, proxy.Password);
                    }
                    ws.Options.Proxy = webProxy;
                }
                // set certificate validator
                if (certificateValidator != null)
                {
                    ws.Options.RemoteCertificateValidationCallback = certificateValidator;
                }
                // connect
                var uri = new Uri(url);
                await ws.ConnectAsync(uri, CancellationToken.None);
                OnOpen(this);
                // see https://stackoverflow.com/a/23784968
                // and https://stackoverflow.com/a/60232204
                WebSocketReceiveResult result = null;
                do
                {
                    ArraySegment<Byte> buffer = new ArraySegment<byte>(new byte[8192]);
                    using (var ms = new MemoryStream())
                    {
                        do
                        {
                            result = await ws.ReceiveAsync(buffer, CancellationToken.None);
                            ms.Write(buffer.Array, buffer.Offset, result.Count);
                        }
                        while (!result.EndOfMessage);

                        ms.Seek(0, SeekOrigin.Begin);

                        if (result.MessageType == WebSocketMessageType.Text)
                        {
                            using (var reader = new StreamReader(ms, Encoding.UTF8))
                            {
                                string line;
                                while ((line = await reader.ReadLineAsync()) != null)
                                {
                                    OnText(this, line);
                                }
                            }
                        }
                    }
                } while (result.MessageType != WebSocketMessageType.Close);
            }
            catch (Exception ex)
            {
                OnError(this, ex);
            }
        }

        public void SendAsync(string txt)
        {
            ws.SendAsync(
                new ArraySegment<byte>(Encoding.UTF8.GetBytes(txt)),
                WebSocketMessageType.Text, true, CancellationToken.None);
        }

        public void Dispose()
        {
            isCanceled = true;
            ws.Abort();
            ws.Dispose();
        }

        public bool IsDisposed()
        {
            return isCanceled;
        }

        virtual public void OnOpen(WsClientCs client) { }
        virtual public void OnText(WsClientCs client, string line) { }
        virtual public void OnError(WsClientCs client, Exception error) { }
    }
}
