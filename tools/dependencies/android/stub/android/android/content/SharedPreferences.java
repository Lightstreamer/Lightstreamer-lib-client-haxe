package android.content;

public interface SharedPreferences {

    Editor edit();

    String getString(String key, String defValue);

    int getInt(String key, int defValue);
    
    public interface Editor {
        
        public Editor putString(String key, String value);
        
        public Editor putInt(String key, int value);
        
        public boolean commit();
    }
}