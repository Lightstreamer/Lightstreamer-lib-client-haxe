package com.lightstreamer.internal;

import com.lightstreamer.internal.MacroTools.getDefine;

final TLCP_VERSION = "TLCP-2.4.0";
final FULL_TLCP_VERSION = TLCP_VERSION + ".lightstreamer.com";

#if LS_TEST
final LS_LIB_NAME = "generic_client";
final LS_LIB_VERSION = "0.0 build 0";
final LS_CID = "mgQkwtwdysogQz2BJ4Ji kOj2Bg";
#elseif LS_WEB
final LS_LIB_NAME = "javascript_client";
final LS_LIB_VERSION = "9.0.0-beta.1 build 20220624";
final LS_CID = "pcYgxn8m8 feOojyA1V661f4gpAeL83dXoqoH6M982l89l";
#elseif LS_NODE
final LS_LIB_NAME = "nodejs_client";
final LS_LIB_VERSION = "9.0.0-beta.1 build 20220624";
final LS_CID = "tqGko0tg4pkpW3EAK3M5hgWg4CHfDprfc85DM4S9Aa";
#elseif android
final LS_LIB_NAME = "android_client";
final LS_LIB_VERSION = "5.0.0-beta.1 build 20220624";
final LS_CID = "gpGxttxdysogQz2GJ4L74dHzfAL1x-onG37BM6MD86p";
#elseif java
final LS_LIB_NAME = "javase_client";
final LS_LIB_VERSION = "5.0.0-beta.1 build 20220624";
final LS_CID = "pcYgxptg4pkpW3AAK3M5hgWg4CHfDprfc85DM4S9Am";
#elseif cs
final LS_LIB_NAME = "dotnet_client";
final LS_LIB_VERSION = "6.0.0-beta.1 build 20220624";
final LS_CID = "jqWtj1tg4pkpW3BAK3M5hgWg4CHfDprfc85DM4S9Ai";
#elseif python
final LS_LIB_NAME = "python_client";
final LS_LIB_VERSION = getDefine("LS_VERSION", "0.0") + " build " + getDefine("LS_BUILD", "0");
final LS_CID = getDefine("LS_CID", "mgQkwtwdysogQz2BJ4Ji kOj2Bg");
#elseif php
final LS_LIB_NAME = "php_client";
final LS_LIB_VERSION = "1.0.0-beta.1 build 20220624";
final LS_CID = "vjSfhw.i6 33e64BIf  g1g3g2.pz482h85HM8c";
#elseif cpp
final LS_LIB_NAME = "cpp_client";
final LS_LIB_VERSION = "1.0.0-beta.1 build 20220624";
final LS_CID = "irSfhw.i6 33e64BIf  g1g3g2.pz482h85HM8w";
#end