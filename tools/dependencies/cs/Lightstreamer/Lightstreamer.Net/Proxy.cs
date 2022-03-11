using System;

namespace com.lightstreamer.cs
{
    public class Proxy
    {
        public string Host, User, Password;
        public int Port;

        public Proxy(string host, int port, string user, string password)
        {
            Host = host;
            Port = port;
            User = user;
            Password = password;
        }
    }
}
