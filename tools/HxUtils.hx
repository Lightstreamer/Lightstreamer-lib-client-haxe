import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
using StringTools;

class HxUtils {

  static final classes = ["LightstreamerClient", "Subscription"];

  public static function fixLib(path: String) {
    // fix https://github.com/HaxeFoundation/haxe/issues/7366
    var lib = File.getContent(path);
    var needle = "typeof exports != \"undefined\" ? exports : typeof window != \"undefined\" ? window : typeof self != \"undefined\" ? self : this";
    lib = lib.replace(needle, "{}");
    lib = '$lib
export { ${classes.join(",")} };
';
    File.saveContent(path, lib);
  }

  public static function renameTypescriptDeclarationFile(inPath: String) {
    var baseDir = Path.directory(inPath);
    var outPath = Path.join([baseDir, "types.d.ts"]);
    FileSystem.rename(inPath, outPath);
  }

  public static function run(cmd: String) {
    var exit = Sys.command(cmd);
    if (exit != 0) {
      throw 'Cannot run `$cmd`';
    }
  }
}

