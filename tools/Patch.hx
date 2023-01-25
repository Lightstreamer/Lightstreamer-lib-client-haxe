package tools;

import sys.io.File;
using StringTools;

function main() {
  var args = Sys.args();
  fixLib(args[0]);
}

function fixLib(path: String) {
  // fix https://github.com/HaxeFoundation/haxe/issues/7366
  var lib = File.getContent(path);
  var needle = "var $hx_exports = typeof exports != \"undefined\" ? exports : typeof window != \"undefined\" ? window : typeof self != \"undefined\" ? self : this;";
  lib = lib.replace(needle, "var $hx_exports = {};");
  File.saveContent(path, lib);
}
