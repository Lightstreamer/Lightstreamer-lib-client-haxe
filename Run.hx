
function main() {
  for (i in 0...25) {
    Sys.println('####################');
    Sys.println('Test $i');
    Sys.println('####################');
    var start = Sys.cpuTime();
    Sys.command("bin-test/cpp/TestAll-debug");
    var end = Sys.cpuTime();
    if (end - start > 30) {
      Sys.println('Test $i interrupted');
      Sys.exit(1);
    }
  }
  Sys.println("Tests done.");
}