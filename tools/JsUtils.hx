import sys.io.File;
using StringTools;

class JsUtils {

  static final classes = ["LightstreamerClient", "Subscription"];

  static function main() {
    var lib = File.getContent("bin/web/lightstreamer_orig.js");
    lib = fixLib(lib);

    generateESM(lib);
    generateCommonJS(lib);
    generateUMD(lib);
    generateWidgetLib();
    generateFullLibs();
  }

  static function fixLib(lib: String) {
    // fix https://github.com/HaxeFoundation/haxe/issues/7366
    var needle = "typeof exports != \"undefined\" ? exports : typeof window != \"undefined\" ? window : typeof self != \"undefined\" ? self : this";
    return lib.replace(needle, "{}");
  }

  static function generateESM(lib: String) {
    var output = '$lib
export { ${classes.join(",")} };
';
    File.saveContent("bin/web/lightstreamer-core.esm.js", output);
  }

  static function generateCommonJS(lib: String) {
    var output = '$lib
${[for (c in classes) 'exports.$c = $c;'].join("\n")}
';
    File.saveContent("bin/web/lightstreamer-core.common.js", output);
  }

  static function generateUMD(lib: String) {
    var output = '
(function (root, factory) {
  var hx_exports = factory();
  if (typeof define === "function" && define.amd) {
    define("lightstreamer", ["module"], function(module) {
      var namespace = (module.config()["ns"] ? module.config()["ns"] + "/" : "");
      ${[for (c in classes) 'define(namespace + "$c", function() { return hx_exports.$c; });'].join("\n")}
    });
    require(["lightstreamer"]);
  } else {
    var namespace = createNs(extractNs(), root);
    ${[for (c in classes) 'namespace.$c = hx_exports.$c;'].join("\n")}
  }
  function extractNs() {
    var scripts = window.document.getElementsByTagName("script");
    for (var i = 0, len = scripts.length; i < len; i++) {
      if ("data-lightstreamer-ns" in scripts[i].attributes) {        
        return scripts[i].attributes["data-lightstreamer-ns"].value;
      }
    }
    return null;
  }
  function createNs(ns, root) {
    if (! ns) {
      return root;
    }
    var pieces = ns.split(".");
    var parent = root || window;
    for (var j = 0; j < pieces.length; j++) {
      var qualifier = pieces[j];
      var obj = parent[qualifier];
      if (! (obj && typeof obj == "object")) {
        obj = parent[qualifier] = {};
      }
      parent = obj;
    }
    return parent;
  }
}(typeof self !== "undefined" ? self : this, function () {
  $lib
  return $$hx_exports;
}));
';
    File.saveContent("bin/web/lightstreamer-core.js", output);
  }

  static function generateWidgetLib() {
    run("npx rollup --config rollup.config.widgets.js");
  }

  static function generateFullLibs() {
    run("npx rollup --config rollup.config.js");
  }

  static function run(cmd: String) {
    var exit = Sys.command(cmd);
    if (exit != 0) {
      throw 'Cannot run `$cmd`';
    }
  }
}
