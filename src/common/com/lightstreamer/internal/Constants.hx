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
package com.lightstreamer.internal;

import com.lightstreamer.internal.MacroTools.getDefine;

final TLCP_VERSION = "TLCP-2.5.0";
final FULL_TLCP_VERSION = TLCP_VERSION + ".lightstreamer.com";

final LS_LIB_VERSION = getDefine("LS_VERSION", "0.0") + " build " + getDefine("LS_BUILD", "0");
final LS_CID = getDefine("LS_CID", "mgQkwtwdysogQz2BJ4Ji kOj2Bg");

#if LS_TEST
final LS_LIB_NAME = "generic_client";
#elseif LS_WEB
final LS_LIB_NAME = "javascript_client";
#elseif LS_NODE
final LS_LIB_NAME = "nodejs_client";
#elseif android
final LS_LIB_NAME = "android_client";
#elseif java
final LS_LIB_NAME = "javase_client";
#elseif cs
final LS_LIB_NAME = "dotnet_standard_client";
#elseif python
final LS_LIB_NAME = "python_client";
#elseif php
final LS_LIB_NAME = "php_client";
#elseif cpp
final LS_LIB_NAME = "cpp_client";
#end

final LS_CREATE_REALM = getDefine("LS_CREATE_REALM", "");