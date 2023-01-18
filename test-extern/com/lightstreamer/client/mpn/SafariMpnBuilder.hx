package com.lightstreamer.client.mpn;

#if js @:native("SafariMpnBuilder") #end
extern class SafariMpnBuilder {
  public function new(?format: String);
  public function build(): String;
  public function getTitle(): Null<String>;
  public function setTitle(newValue: Null<String>): SafariMpnBuilder;
  public function getBody(): Null<String>;
  public function setBody(newValue: Null<String>): SafariMpnBuilder;
  public function getAction(): Null<String>;
  public function setAction(newValue: Null<String>): SafariMpnBuilder;
  public function getUrlArguments(): Null<NativeList<String>>;
  public function setUrlArguments(newValue: Null<NativeList<String>>): SafariMpnBuilder;
}