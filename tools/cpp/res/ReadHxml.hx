import sys.io.File;

function main() {
  var args = Sys.args();
  if (args.length != 1) {
    Sys.exit(1);
  }
  var hxml = File.getContent(args[0]);
  var r = ~/^--cpp (.*)/m;
  if (!r.match(hxml)) {
    Sys.exit(2);
  }
  Sys.print(r.matched(1));
}

