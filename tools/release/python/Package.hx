import hx.files.*;
import Sys.println;
import sys.io.File;

using StringTools;

// NB the current directory must be the root of the project
final deps = Path.of("tools/dependencies/python");
final res = Path.of("tools/release/python");
final bin = Path.of("bin/python");
final dist = Path.of("dist/python/lightstreamer-client");
final dist_src = Path.of("dist/python/lightstreamer-client/src/lightstreamer_client");

function main() {
  var args = Sys.args();
  if (args.length == 0) {
    println("Syntax: haxe package.python.hxml <version>");
    Sys.exit(1);
  }
  var version = args[0];
  if (!~/^\d+\.\d+\.\d+/.match(version)) {
    println("Invalid version: " + version);
    Sys.exit(1);
  }
  createDir(bin);
  createDir(dist);
  createDir(dist_src);
  // build the library
  Sys.command("haxe build.python.hxml");
  // replace the version number
  var pyproject = File.getContent(res.join("pyproject.toml").getAbsolutePath());
  pyproject = pyproject.replace("::version::", version);

  var readme = File.getContent(res.join("README.md").getAbsolutePath());
  readme = readme.replace("::version::", version);
  // copy the artifacts to dist
  copy("com_lightstreamer_client.py", bin, dist_src);
  copy("com_lightstreamer_net.py", deps, dist_src);
  copy("__init__.py", res, dist_src);
  copy("LICENSE", res, dist);
  File.saveContent(dist.join("pyproject.toml").getAbsolutePath(), pyproject);
  File.saveContent(dist.join("README.md").getAbsolutePath(), readme);
  copy("setup.py", res, dist);
}

function createDir(dir: Path) {
  dir.toDir().delete(true);
  dir.toDir().create();
}

function copy(file: String, from: Path, to: Path) {
  from.join(file).toFile().copyTo(to.join(file), [OVERWRITE]);
}