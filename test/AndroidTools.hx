var appContext: android.content.Context;

function openRawResource(res: String): java.io.InputStream {
  return appContext.getResources().openRawResource(
    appContext.getResources().getIdentifier(res, "raw", appContext.getPackageName()));
}