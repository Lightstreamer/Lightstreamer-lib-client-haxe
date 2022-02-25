package cookiejar;

/**
class to determine matching qualities of a cookie
*/
@:jsRequire("cookiejar", "CookieAccessInfo")
extern class CookieAccessInfo {
  static final All: CookieAccessInfo;
  /**
  String domain - domain to match
  String path - path to match
  Boolean secure - access is secure (ssl generally)
  Boolean script - access is from a script
   */
  function new(?domain: String, ?path: String, ?secure: Bool, ?script: Bool);
}