import hx.files.*;

final deps = Path.of("tools/dependencies/python");
final res = Path.of("tools/release/python");
final bin = Path.of("bin/python");
final dist = Path.of("dist/python/lightstreamer-client");
final dist_src = Path.of("dist/python/lightstreamer-client/src/lightstreamer_client");

function main() {
  // NB the current directory must be the root of the project
  createDir(bin);
  createDir(dist);
  createDir(dist_src);
  // build the library
  Sys.command("haxe build.python.hxml");
  // copy the artifacts to dist
  copy("client.py", bin, dist_src);
  copy("com_lightstreamer_net.py", deps, dist_src);
  copy("__init__.py", res, dist_src);
  copy("LICENSE", res, dist);
  copy("pyproject.toml", res, dist);
  copy("README.md", res, dist);
  copy("setup.py", res, dist);
}

function createDir(dir: Path) {
  dir.toDir().delete(true);
  dir.toDir().create();
}

function copy(file: String, from: Path, to: Path) {
  from.join(file).toFile().copyTo(to.join(file), [OVERWRITE]);
}