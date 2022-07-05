import Sys.println;

final BASE = "..";
final WEBSITE = "https://www.lightstreamer.com";

function main() {
  var args = Sys.args();
  if (args.length != 2) {
    println("Syntax: haxe --run Docs <target> <version>");
    Sys.exit(1);
  }
  var target = args[0];
  var version = args[1];
  var supportedTargets = ["python", "java"];
  if (!supportedTargets.contains(target)) {
    println("Invalid target: " + target);
    println("Supported targets are: " + supportedTargets);
    Sys.exit(1);
  }
  if (!~/^\d+\.\d+\.\d+/.match(version)) {
    println("Invalid version: " + version);
    Sys.exit(1);
  }
  switch target {
  case "java":
    genJavaDocs(version);
  case "python":
    genPythonDocs(version);
  }
}

function genJavaDocs(version: String) {
  Sys.command("haxe", [
    "--jvm", "dummy.jar",
    "--macro", 'include("com.lightstreamer")', 
    "--class-path", '$BASE/src/extern/java',
    "--no-output",
    "-xml", '$BASE/dist/java/java.xml', 
    "-D", "doc-gen", 
    "-D", "LS_HAS_PROXY", 
    "-D", "LS_HAS_COOKIES", 
    "-D", "LS_HAS_TRUST_MANAGER"]);
  Sys.command("haxelib", [
    "run", "dox",
    "-i", '$BASE/dist/java/java.xml', 
    "-o", '$BASE/dist/java/pages', 
    "--toplevel-package", "com.lightstreamer", "--keep-field-order",
    "--title", 'Lightstreamer Java Client SDK $version API Reference', 
    "-D", "version", '$version', 
    "-D", "website", '$WEBSITE',
    "-theme", "./theme", 
    "-D", "description", '$PKG_DESC']);
}

function genPythonDocs(version: String) {
  Sys.command("haxe", [
    "--python", "dummy.py",
    "--macro", 'include("com.lightstreamer")', 
    "--no-output",
    "-xml", '$BASE/dist/python/python.xml', 
    "-D", "doc-gen", 
    "-D", "LS_HAS_PROXY", 
    "-D", "LS_HAS_COOKIES", 
    "-D", "LS_HAS_TRUST_MANAGER"]);
  Sys.command("haxelib", [
    "run", "dox",
    "-i", '$BASE/dist/python/python.xml', 
    "-o", '$BASE/dist/python/pages', 
    "--toplevel-package", "com.lightstreamer", "--keep-field-order",
    "--title", 'Lightstreamer Python Client SDK $version API Reference', 
    "-D", "version", '$version', 
    "-D", "website", '$WEBSITE',
    "-theme", "./theme", 
    "-D", "description", '$PKG_DESC']);
}

final PKG_DESC = "This library enables any application to communicate bidirectionally with the Lightstreamer Server. The API allows to subscribe to real-time data pushed by the server and to send any message to the server.<br><br>The library exposes a fully asynchronous API. All the API calls that require any action from the library itself are queued for processing by a dedicated thread before being carried out. The same thread is also used to carry notifications for the appropriate listeners as provided by the custom code. Blocking operations and internal housekeeping are performed on different threads.<br><br>The library offers automatic recovery from connection failures, automatic selection of the best available transport, and full decoupling of subscription and connection operations. The subscriptions are always meant as subscriptions <i>to the LightstreamerClient</i>, not <i>to the Server</i>; the LightstreamerClient is responsible of forwarding the subscriptions to the Server and re-forwarding all the subscriptions whenever the connection is broken and then reopened.<br><br>Start digging into the API from the <code>LightstreamerClient</code> object. The library can be available depending on Edition and License Type. To know what features are enabled by your license, please see the License tab of the Monitoring Dashboard (by default, available at <i>/dashboard</i>).";