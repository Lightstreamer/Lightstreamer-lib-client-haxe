import HxUtils;
import sys.io.File;

function main() {
  var coreClasses: Array<String> = haxe.Json.parse(File.getContent("tools/classes.core.json"));
  var mpnClasses: Array<String> = haxe.Json.parse(File.getContent("tools/classes.mpn.json"));
  var classes = coreClasses.concat(mpnClasses);
  copyPackageJson();
  HxUtils.fixLib("bin/web/lightstreamer_orig.full.js", classes);
  generateWidgetLib();
  generateFullLibs();
  HxUtils.renameTypescriptDeclarationFile("bin/web/lightstreamer_orig.full.d.ts");
}

function copyPackageJson() {
  File.copy("tools/web/package.json", "bin/web/package.json");
}

function generateWidgetLib() {
  HxUtils.run("npx rollup --config rollup.config.widgets.js");
}

function generateFullLibs() {
  HxUtils.run("npx rollup --config rollup.config.full.js");
}