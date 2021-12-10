import HxUtils;
import sys.io.File;

class WebGenerator {
  static function main() {
    copyPackageJson();
    HxUtils.fixLib("bin/web/lightstreamer_orig.js");
    generateCoreLibs();
    generateWidgetLib();
    generateFullLibs();
    HxUtils.renameTypescriptDeclarationFile("bin/web/lightstreamer_orig.d.ts");
  }

  static function copyPackageJson() {
    File.copy("tools/web/package.json", "bin/web/package.json");
  }

  static function generateCoreLibs() {
    HxUtils.run("npx rollup --config rollup.config.core.js");
  }

  static function generateWidgetLib() {
    HxUtils.run("npx rollup --config rollup.config.widgets.js");
  }

  static function generateFullLibs() {
    HxUtils.run("npx rollup --config rollup.config.full.js");
  }
}