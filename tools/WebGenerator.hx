import HxUtils.*;

class WebGenerator {
  static function main() {
    fixLib("bin/web/lightstreamer_orig.js");
    generateCoreLibs();
    generateWidgetLib();
    generateFullLibs();
    renameTypescriptDeclarationFile("bin/web/lightstreamer_orig.d.ts");
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
}