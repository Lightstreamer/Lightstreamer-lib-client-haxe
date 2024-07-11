package com.lightstreamer.internal.impl.colyseus;

import sys.net.Host;
import haxe.net.impl.SocketSys;

class LsSocket extends SocketSys {
  
  // adapted from SocketSys.initialize
  override public function initialize(secure:Bool) {
    this.secure = secure;
    var impl:Dynamic = null;
    if (secure) {
        #if (haxe_ver >= "3.3")
    #if python
                this.impl = new python.net.SslSocket();
    #else
      this.impl = new sys.ssl.Socket();
    #end
        #else
            throw 'Not supporting secure sockets';
        #end
    } else {
        this.impl = new sys.net.Socket();
    }
    try {
        this.impl.connect(new Host(host), port);
        //this.impl.setFastSend(true);
        this.impl.setBlocking(false);
        //this.impl.setBlocking(true);
        this.sendConnect = true;
        if (debug) trace('socket.connected!');
    } catch (e:Dynamic) {
        this.sendError = true;
        if (debug) trace('socket.error! $e');
    }

    return this;
  }
}