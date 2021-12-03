import HxUtils.*;

class NodeGenerator {
  static function main() {
    fixLib("bin/node/lightstreamer-node_orig.js");
    generateLibs();
    renameTypescriptDeclarationFile("bin/node/lightstreamer-node_orig.d.ts");
  }

  static function generateLibs() {
    run("npx rollup --config rollup.config.node.js");
  }
}