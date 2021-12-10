import HxUtils;
import sys.io.File;

function main() {
  copyPackageJson();
  HxUtils.fixLib("bin/web/lightstreamer_orig.js");
  generateCoreLibs();
  generateWidgetLib();
  generateFullLibs();
  HxUtils.renameTypescriptDeclarationFile("bin/web/lightstreamer_orig.d.ts");
}

function copyPackageJson() {
  File.copy("tools/web/package.json", "bin/web/package.json");
}

function generateCoreLibs() {
  HxUtils.run("npx rollup --config rollup.config.core.js");
}

function generateWidgetLib() {
  HxUtils.run("npx rollup --config rollup.config.widgets.js");
}

function generateFullLibs() {
  HxUtils.run("npx rollup --config rollup.config.full.js");
}