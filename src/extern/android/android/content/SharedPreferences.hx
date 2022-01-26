package android.content;

extern class SharedPreferences {
  function edit(): Editor;
  function getString(key: String, defValue: Null<String>): String;
  function getInt(key: String, defValue: Int): Int;
}

extern class Editor {
  function putString(key: String, value: String): Editor;
  function putInt(key: String, value: Int): Editor;
  function commit(): Bool;
}