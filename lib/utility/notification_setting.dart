import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettings {
  static const _newMessagesKey = 'new_messages';
  static const _promotionsKey = 'promotions';
  static const _updatesKey = 'updates';

  static Future<void> saveSettings({
    required bool newMessages,
    required bool promotions,
    required bool updates,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_newMessagesKey, newMessages);
    await prefs.setBool(_promotionsKey, promotions);
    await prefs.setBool(_updatesKey, updates);
  }

  static Future<Map<String, bool>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      _newMessagesKey: prefs.getBool(_newMessagesKey) ?? true,
      _promotionsKey: prefs.getBool(_promotionsKey) ?? false,
      _updatesKey: prefs.getBool(_updatesKey) ?? true,
    };
  }
}
