package com.lightstreamer.client.mpn;

#if js @:native("FirebaseMpnBuilder") #end
extern class FirebaseMpnBuilder {
  public function new(?format: String);
  public function build(): String;
  public function getHeaders(): Null<NativeStringMap<String>>;
  public function setHeaders(newValue: Null<NativeStringMap<String>>): FirebaseMpnBuilder;
  public function getTitle(): Null<String>;
  public function setTitle(newValue: Null<String>): FirebaseMpnBuilder;
  public function getBody(): Null<String>;
  public function setBody(newValue: Null<String>): FirebaseMpnBuilder;
  public function getIcon(): Null<String>;
  public function setIcon(newValue: Null<String>): FirebaseMpnBuilder;
  public function getData(): Null<NativeStringMap<String>>;
  public function setData(newValue: Null<NativeStringMap<String>>): FirebaseMpnBuilder;
}