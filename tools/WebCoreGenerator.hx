import HxUtils;
import sys.io.File;

function main() {
  var coreClasses: Array<String> = haxe.Json.parse(File.getContent("tools/classes.core.json"));
  copyPackageJson();
  HxUtils.fixLib("bin/web/lightstreamer_orig.core.js", coreClasses);
  generateCoreLibs();
}

function copyPackageJson() {
  File.copy("tools/web/package.json", "bin/web/package.json");
}

function generateCoreLibs() {
  HxUtils.run("npx rollup --config rollup.config.core.js");
}