using System;
using System.IO;
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
            string url, string body, string protocol)
        {
            try
            {
                ws.Options.AddSubProtocol(protocol);
                var uri = new Uri(url);
                await ws.ConnectAsync(uri, CancellationToken.None);
                OnOpen(this);
                // see https://stackoverflow.com/a/23784968
                ArraySegment<Byte> buffer = new ArraySegment<byte>(new byte[8192]);
                using (var ms = new MemoryStream())
                {
                    WebSocketReceiveResult result = null;
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
