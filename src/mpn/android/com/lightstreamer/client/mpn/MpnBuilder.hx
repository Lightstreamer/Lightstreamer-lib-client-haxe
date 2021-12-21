package com.lightstreamer.client.mpn;

class MpnBuilder {
  public function build(): String {
    return null;
  }
  public overload function collapseKey(collapseKey: String): MpnBuilder {
    return this;
  }
  public overload function collapseKey(): String {
    return null;
  }
  public overload function priority(priority: String): MpnBuilder {
    return this;
  }
  public overload function priority(): String {
    return null;
  }
  // TODO deprecati
  // public overload function contentAvailable(contentAvailable: String): MpnBuilder {
  //   return this;
  // }
  // public overload function contentAvailableAsString(): String {
  //   return null;
  // }
  // public overload function contentAvailable(contentAvailable: Bool): MpnBuilder {
  //   return this;
  // }
  // public overload function contentAvailableAsBool(): Bool {
  //   return false;
  // }
  public overload function timeToLive(timeToLive: String): MpnBuilder {
    return this;
  }
  public overload function timeToLiveAsString(): String {
    return null;
  }
  public overload function timeToLive(timeToLive: Int): MpnBuilder {
    return this;
  }
  public overload function timeToLiveAsInteger(): Int {
    return 0;
  }
  public overload function title(title: String): MpnBuilder {
    return this;
  }
  public overload function title(): String {
    return null;
  }
  public overload function titleLocKey(titleLocKey: String): MpnBuilder {
    return this;
  }
  public overload function titleLocKey(): String {
    return null;
  }
  public overload function titleLocArguments(titleLocKey: Array<String>): MpnBuilder {
    return this;
  }
  public overload function titleLocArguments(): Array<String> {
    return null;
  }
  public overload function body(body: String): MpnBuilder {
    return this;
  }
  public overload function body(): String {
    return null;
  }
  public overload function bodyLocKey(bodyLocKey: String): MpnBuilder {
    return this;
  }
  public overload function bodyLocKey(): String {
    return null;
  }
  public overload function bodyLocArguments(bodyLocKey: Array<String>): MpnBuilder {
    return this;
  }
  public overload function bodyLocArguments(): Array<String> {
    return null;
  }
  public overload function icon(icon: String): MpnBuilder {
    return this;
  }
  public overload function icon(): String {
    return null;
  }
  public overload function sound(sound: String): MpnBuilder {
    return this;
  }
  public overload function sound(): String {
    return null;
  }
  public overload function tag(tag: String): MpnBuilder {
    return this;
  }
  public overload function tag(): String {
    return null;
  }
  public overload function color(color: String): MpnBuilder {
    return this;
  }
  public overload function color(): String {
    return null;
  }
  public overload function clickAction(clickAction: String): MpnBuilder {
    return this;
  }
  public overload function clickAction(): String {
    return null;
  }
  public overload function data(clickAction: Map<String, String>): MpnBuilder {
    return this;
  }
  public overload function data(): Map<String, String> {
    return null;
  }
}