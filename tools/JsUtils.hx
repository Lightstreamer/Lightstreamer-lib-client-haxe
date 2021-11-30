import sys.io.File;
using StringTools;

class JsUtils {

  static final classes = ["LightstreamerClient", "Subscription"];

  static function main() {
    fixLib();
    generateCoreLibs();
    generateWidgetLib();
    generateFullLibs();
  }

  static function fixLib() {
    // fix https://github.com/HaxeFoundation/haxe/issues/7366
    var lib = File.getContent("bin/web/lightstreamer_orig.js");
    var needle = "typeof exports != \"undefined\" ? exports : typeof window != \"undefined\" ? window : typeof self != \"undefined\" ? self : this";
    lib = lib.replace(needle, "{}");
    lib = '$lib
export { ${classes.join(",")} };
';
    File.saveContent("bin/web/lightstreamer_orig.js", lib);
  }

  static function generateCoreLibs() {
    run("npx rollup --config rollup.config.core.js");
  }

  static function generateWidgetLib() {
    run("npx rollup --config rollup.config.widgets.js");
  }

  static function generateFullLibs() {
    run("npx rollup --config rollup.config.full.js");
  }

  static function run(cmd: String) {
    var exit = Sys.command(cmd);
    if (exit != 0) {
      throw 'Cannot run `$cmd`';
    }
  }
}
