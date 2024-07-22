import sys.net.Socket;

function main() {
  var ss = new Socket();
  ss.bind(new sys.net.Host("127.0.0.1"), 1234);
  ss.listen(99);
  while (true) {
    ss.accept();
  }
}