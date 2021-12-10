import HxUtils;
import sys.io.File;

class NodeGenerator {
  static function main() {
    copyPackageJson();
    HxUtils.fixLib("bin/node/lightstreamer-node_orig.js");
    generateLibs();
    HxUtils.renameTypescriptDeclarationFile("bin/node/lightstreamer-node_orig.d.ts");
  }

  static function copyPackageJson() {
    File.copy("tools/node/package.json", "bin/node/package.json");
  }

  static function generateLibs() {
    HxUtils.run("npx rollup --config rollup.config.node.js");
  }
}