/*
 * Copyright (C) 2023 Lightstreamer Srl
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
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