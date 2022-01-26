package android.content;

extern class Context {
  static final MODE_PRIVATE: Int;
  function getPackageName(): String;
  function getPackageManager(): android.content.pm.PackageManager;
  function getSharedPreferences(name: String, mode: Int): SharedPreferences;
}