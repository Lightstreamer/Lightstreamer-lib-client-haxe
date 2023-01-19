package tools;

import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
using StringTools;

function main() {
  var args = Sys.args();
  var coreClasses: Array<String> = haxe.Json.parse(File.getContent(args[1]));
  fixLib(args[0], coreClasses, args[2]);
}

function fixLib(path: String, classes: Array<String>, outPath: String) {
  // fix https://github.com/HaxeFoundation/haxe/issues/7366
  var lib = File.getContent(path);
  var needle = "var $hx_exports = typeof exports != \"undefined\" ? exports : typeof window != \"undefined\" ? window : typeof self != \"undefined\" ? self : this;";
  lib = lib.replace(needle, "var $hx_exports = {};");
  lib = '$lib
export { ${classes.join(",")} };
';
  File.saveContent(outPath, lib);
}
