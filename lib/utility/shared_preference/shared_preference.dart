import 'package:shared_preferences/shared_preferences.dart';

enum SharedPreferenceKeys {
  notificationToken("notificationToken"),
  uid("uid"),
  userName("user_name");

  final String value;
  const SharedPreferenceKeys(this.value);
}

 class CustomSharedPreference {
  Future<bool> storeData(
      {required SharedPreferenceKeys key, required String data}) async {
    try {
      final sharedPref = await SharedPreferences.getInstance();
      return await sharedPref.setString(key.value, data);
    } catch (e) {
      return false;
    }
  }

  Future<String?> getData({required SharedPreferenceKeys key}) async {
    final sharedPref = await SharedPreferences.getInstance();
    return sharedPref.getString(key.value);
  }

  Future<bool> deleteData({required SharedPreferenceKeys key}) async {
    try {
      final sharedPref = await SharedPreferences.getInstance();
      return await sharedPref.remove(key.value);
    } catch (e) {
      return false;
    }
  }

  Future<bool> clear() async {
    try {
      final sharedPref = await SharedPreferences.getInstance();
      return await sharedPref.clear();
    } catch (e) {
      return false;
    }
  }
}
