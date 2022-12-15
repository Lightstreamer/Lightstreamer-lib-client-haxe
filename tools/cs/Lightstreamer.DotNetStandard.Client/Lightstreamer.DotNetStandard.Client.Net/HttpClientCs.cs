using System;
using System.Collections.Generic;
using System.IO;
using System.Net.Http;
using System.Net.Security;
using System.Threading;
using System.Threading.Tasks;

namespace com.lightstreamer.cs
{
    public class HttpClientCs
    {
        static readonly HttpClientHandler clientHandler = new HttpClientHandler()
        {
            UseCookies = true,
            CookieContainer = CookieHelper.instance.GetCookieContainer()
        };

        // HttpClient is intended to be instantiated once and re-used throughout the life of an application
        static readonly HttpClient client = new HttpClient(clientHandler);

        public static void SetProxy(string host, int port, string user, string password)
        {
            // see https://stackoverflow.com/a/49159273
            var uriBuilder = new UriBuilder(host);
            uriBuilder.Port = port;
            var webProxy = new System.Net.WebProxy(uriBuilder.Uri);
            if (user != null)
            {
                webProxy.Credentials = new System.Net.NetworkCredential(user, password);
            }
            clientHandler.Proxy = webProxy;
        }

        public static void SetRemoteCertificateValidationCallback(RemoteCertificateValidationCallback callback)
        {
            // see https://khalidabuhakmeh.com/validating-ssl-certificates-with-dotnet-servicepointmanager
            clientHandler.ServerCertificateCustomValidationCallback =
                   (sender, cert, chain, sslPolicyErrors) => callback(sender, cert, chain, sslPolicyErrors);
        }

        volatile bool isCanceled = false;
        CancellationTokenSource cancellationToken;

        public HttpClientCs()
        {
            this.cancellationToken = new CancellationTokenSource();
        }

        public async Task SendAsync(
            string url,
            string body,
            IDictionary<string, string> headers)
        {
            var request = new HttpRequestMessage(HttpMethod.Post, url);
            request.Content = new StringContent(body, System.Text.Encoding.UTF8, "application/x-www-form-urlencoded");
            // set headers
            if (headers != null)
            {
                foreach(var entry in headers)
                {
                    request.Headers.Add(entry.Key, entry.Value);
                }
            }
            // send request
            try
            {
                // see https://stackoverflow.com/a/44292439
                using (var response = await client.SendAsync(request, HttpCompletionOption.ResponseHeadersRead, cancellationToken.Token))
                {
                    if (!response.IsSuccessStatusCode)
                    {
                        OnError(this, new Exception("Unexpected HTTP code: " + response.StatusCode));
                        return;
                    }
                    using var stream = await response.Content.ReadAsStreamAsync();
                    using var reader = new StreamReader(stream);
                    string line;
                    while ((line = await reader.ReadLineAsync()) != null)
                    {
                        OnText(this, line);
                    }
                }
                OnDone(this);
            }
            catch (Exception ex)
            {
                OnError(this, ex);
            }
        }

        public void Dispose()
        {
            isCanceled = true;
            cancellationToken.Cancel();
        }

        public bool IsDisposed()
        {
            return isCanceled;
        }

        virtual public void OnText(HttpClientCs client, string line) { }
        virtual public void OnError(HttpClientCs client, Exception error) { }
        virtual public void OnDone(HttpClientCs client) { }
    }
}
