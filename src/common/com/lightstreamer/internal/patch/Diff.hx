package com.lightstreamer.internal.patch;

enum DiffOperations {
  DiffCopy(n: Int);
  DiffAdd(n: Int, s: String);
  DiffDel(n: Int);
}

function applyDiff(base: String, operations: Array<DiffOperations>): String {
  var pos = 0;
  var result = new StringBuf();
  for (op in operations) {
    switch op {
    case DiffCopy(n):
      if (n > 0) {
        result.add(base.substr(pos, n));
        pos += n;
      }
    case DiffAdd(n, s):
      if (n > 0) {
        result.add(s);
      }
    case DiffDel(n):
      if (n > 0) {
        pos += n;
      }
    }
  }
  return result.toString();
}