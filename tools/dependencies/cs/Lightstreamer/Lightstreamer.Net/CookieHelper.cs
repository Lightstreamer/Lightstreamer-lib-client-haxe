using System;
using System.Collections.Generic;
using System.Net;

namespace com.lightstreamer.cs
{
    public class CookieHelper
    {
        public static readonly CookieHelper instance = new CookieHelper();
        private readonly CookieContainer cookieContainer = new CookieContainer();

        private CookieHelper() { }

        public void AddCookies(Uri uri, CookieCollection cookies)
        {
            cookieContainer.Add(uri, cookies);
        }

        public CookieCollection GetCookies(Uri uri)
        {
            return cookieContainer.GetCookies(uri);
        }

        public CookieContainer GetCookieContainer()
        {
            return cookieContainer;
        }

        public void ClearCookies(string uri)
        {
            var cookies = cookieContainer.GetCookies(new Uri(uri));
            foreach (Cookie c in cookies)
            {
                c.Expired = true;
            }
        }
    }
}
