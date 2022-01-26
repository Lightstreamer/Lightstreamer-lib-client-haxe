package android.content.pm;

extern class PackageManager {
  function getPackageInfo(pkgName: String, flags: Int): PackageInfo;
}