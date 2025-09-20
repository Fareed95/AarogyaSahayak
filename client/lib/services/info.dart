import 'package:shared_preferences/shared_preferences.dart';

class Info {
  static final Info _instance = Info._internal();
  static SharedPreferences? _prefs;

  factory Info() {
    return _instance;
  }

  Info._internal() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Ensure preferences is initialized
  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await _init();
    }
  }

  // ============ AUTHENTICATION RELATED ============

  Future<void> setLoggedIn(bool value) async {
    await _ensureInitialized();
    await _prefs!.setBool('isLoggedIn', value);
  }

  Future<bool> isLoggedIn() async {
    await _ensureInitialized();
    return _prefs!.getBool('isLoggedIn') ?? false;
  }

  Future<void> setUserId(String userId) async {
    await _ensureInitialized();
    await _prefs!.setString('userId', userId);
  }

  Future<String?> getUserId() async {
    await _ensureInitialized();
    return _prefs!.getString('userId');
  }

  Future<void> setUserEmail(String email) async {
    await _ensureInitialized();
    await _prefs!.setString('userEmail', email);
  }

  Future<String?> getUserEmail() async {
    await _ensureInitialized();
    return _prefs!.getString('userEmail');
  }

  Future<void> setUserName(String name) async {
    await _ensureInitialized();
    await _prefs!.setString('userName', name);
  }

  Future<String?> getUserName() async {
    await _ensureInitialized();
    return _prefs!.getString('userName');
  }

  // ============ APP SETTINGS ============

  Future<void> setDarkMode(bool value) async {
    await _ensureInitialized();
    await _prefs!.setBool('isDarkMode', value);
  }

  Future<bool> isDarkMode() async {
    await _ensureInitialized();
    return _prefs!.getBool('isDarkMode') ?? false;
  }

  Future<void> setLanguage(String languageCode) async {
    await _ensureInitialized();
    await _prefs!.setString('language', languageCode);
  }

  Future<String> getLanguage() async {
    await _ensureInitialized();
    return _prefs!.getString('language') ?? 'en';
  }

  Future<void> setNotificationEnabled(bool value) async {
    await _ensureInitialized();
    await _prefs!.setBool('notificationsEnabled', value);
  }

  Future<bool> isNotificationEnabled() async {
    await _ensureInitialized();
    return _prefs!.getBool('notificationsEnabled') ?? true;
  }

  // ============ APP USAGE DATA ============

  Future<void> setFirstLaunch(bool value) async {
    await _ensureInitialized();
    await _prefs!.setBool('isFirstLaunch', value);
  }

  Future<bool> isFirstLaunch() async {
    await _ensureInitialized();
    return _prefs!.getBool('isFirstLaunch') ?? true;
  }

  Future<void> setLastLogin(DateTime date) async {
    await _ensureInitialized();
    await _prefs!.setString('lastLogin', date.toIso8601String());
  }

  Future<DateTime?> getLastLogin() async {
    await _ensureInitialized();
    String? dateString = _prefs!.getString('lastLogin');
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }

  Future<void> incrementAppOpens() async {
    await _ensureInitialized();
    int currentCount = _prefs!.getInt('appOpensCount') ?? 0;
    await _prefs!.setInt('appOpensCount', currentCount + 1);
  }

  Future<int> getAppOpensCount() async {
    await _ensureInitialized();
    return _prefs!.getInt('appOpensCount') ?? 0;
  }

  // ============ CUSTOM VALUES ============

  Future<void> setString(String key, String value) async {
    await _ensureInitialized();
    await _prefs!.setString(key, value);
  }

  Future<String?> getString(String key) async {
    await _ensureInitialized();
    return _prefs!.getString(key);
  }

  Future<void> setInt(String key, int value) async {
    await _ensureInitialized();
    await _prefs!.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    await _ensureInitialized();
    return _prefs!.getInt(key);
  }

  Future<void> setDouble(String key, double value) async {
    await _ensureInitialized();
    await _prefs!.setDouble(key, value);
  }

  Future<double?> getDouble(String key) async {
    await _ensureInitialized();
    return _prefs!.getDouble(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _ensureInitialized();
    await _prefs!.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    await _ensureInitialized();
    return _prefs!.getBool(key);
  }

  Future<void> setStringList(String key, List<String> value) async {
    await _ensureInitialized();
    await _prefs!.setStringList(key, value);
  }

  Future<List<String>?> getStringList(String key) async {
    await _ensureInitialized();
    return _prefs!.getStringList(key);
  }

  // ============ CLEAR DATA ============

  Future<void> removeKey(String key) async {
    await _ensureInitialized();
    await _prefs!.remove(key);
  }

  Future<void> clearAll() async {
    await _ensureInitialized();
    await _prefs!.clear();
  }

  Future<void> clearUserData() async {
    await _ensureInitialized();
    await _prefs!.remove('isLoggedIn');
    await _prefs!.remove('userId');
    await _prefs!.remove('userEmail');
    await _prefs!.remove('userName');
  }

  // ============ CHECK IF KEY EXISTS ============

  Future<bool> containsKey(String key) async {
    await _ensureInitialized();
    return _prefs!.containsKey(key);
  }

  // ============ GET ALL KEYS ============

  Future<Set<String>> getKeys() async {
    await _ensureInitialized();
    return _prefs!.getKeys();
  }
}