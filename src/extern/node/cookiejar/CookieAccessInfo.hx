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
package cookiejar;

/**
class to determine matching qualities of a cookie
*/
@:jsRequire("cookiejar", "CookieAccessInfo")
extern class CookieAccessInfo {
  static final All: CookieAccessInfo;
  /**
  String domain - domain to match
  String path - path to match
  Boolean secure - access is secure (ssl generally)
  Boolean script - access is from a script
   */
  function new(?domain: String, ?path: String, ?secure: Bool, ?script: Bool);
}