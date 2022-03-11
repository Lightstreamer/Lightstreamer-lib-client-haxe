using System;
using System.Collections;
using System.Collections.Generic;
using System.Net;
using System.Reflection;

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
            return uri == null ? GetAllCookies() : cookieContainer.GetCookies(uri);
        }

        public CookieCollection GetAllCookies()
        {
            // see https://stackoverflow.com/a/31900670
            var res = new CookieCollection();
            Hashtable k = (Hashtable) cookieContainer
                .GetType()
                .GetField("m_domainTable", BindingFlags.Instance | BindingFlags.NonPublic)
                .GetValue(cookieContainer);
            foreach (DictionaryEntry element in k)
            {
                SortedList l = (SortedList)element.Value.GetType().GetField("m_list", BindingFlags.Instance | BindingFlags.NonPublic).GetValue(element.Value);
                foreach (var e in l)
                {
                    var cl = (CookieCollection)((DictionaryEntry)e).Value;
                    foreach (Cookie fc in cl)
                    {
                        res.Add(fc);
                    }
                }
            }
            return res;
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
