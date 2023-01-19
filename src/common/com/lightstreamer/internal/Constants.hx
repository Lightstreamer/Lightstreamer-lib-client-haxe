package com.lightstreamer.internal;

import com.lightstreamer.internal.MacroTools.getDefine;

final TLCP_VERSION = "TLCP-2.4.0";
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
final LS_LIB_NAME = "dotnet_client";
#elseif python
final LS_LIB_NAME = "python_client";
#elseif php
final LS_LIB_NAME = "php_client";
#elseif cpp
final LS_LIB_NAME = "cpp_client";
#end