import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettings {
  // Clés existantes
  static const String _availabilityKey = 'notify_availability';
  static const String _messageSentKey = 'notify_message_sent';
  static const String _lowStockKey = 'notify_low_stock';
  static const String _maturityKey = 'notify_maturity';
  static const String _startKey = 'notify_project_start';
  static const String _progress50Key = 'notify_progress_50';
  static const String _progress80Key = 'notify_progress_80';
  static const String _harvestKey = 'notify_harvest';
  static const String _harvestDaysKey =
      'harvest_days'; // Nouvelle clé pour les jours

  static Future<void> initializeDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_availabilityKey))
      await prefs.setBool(_availabilityKey, true);
    if (!prefs.containsKey(_messageSentKey))
      await prefs.setBool(_messageSentKey, true);
    if (!prefs.containsKey(_lowStockKey))
      await prefs.setBool(_lowStockKey, false);
    if (!prefs.containsKey(_maturityKey))
      await prefs.setBool(_maturityKey, true);
    if (!prefs.containsKey(_startKey)) await prefs.setBool(_startKey, true);
    if (!prefs.containsKey(_progress50Key))
      await prefs.setBool(_progress50Key, false);
    if (!prefs.containsKey(_progress80Key))
      await prefs.setBool(_progress80Key, true);
    if (!prefs.containsKey(_harvestKey)) await prefs.setBool(_harvestKey, true);
    if (!prefs.containsKey(_harvestDaysKey))
      await prefs.setInt(_harvestDaysKey, 3); // Par défaut 3 jours
  }

  // Méthodes existantes (non modifiées)
  static Future<bool> getAvailabilityNotification() async =>
      (await SharedPreferences.getInstance()).getBool(_availabilityKey) ?? true;
  static Future<void> setAvailabilityNotification(bool value) async =>
      (await SharedPreferences.getInstance()).setBool(_availabilityKey, value);
  static Future<bool> getMessageSentNotification() async =>
      (await SharedPreferences.getInstance()).getBool(_messageSentKey) ?? true;
  static Future<void> setMessageSentNotification(bool value) async =>
      (await SharedPreferences.getInstance()).setBool(_messageSentKey, value);
  static Future<bool> getLowStockNotification() async =>
      (await SharedPreferences.getInstance()).getBool(_lowStockKey) ?? false;
  static Future<void> setLowStockNotification(bool value) async =>
      (await SharedPreferences.getInstance()).setBool(_lowStockKey, value);
  static Future<bool> getMaturityNotification() async =>
      (await SharedPreferences.getInstance()).getBool(_maturityKey) ?? true;
  static Future<void> setMaturityNotification(bool value) async =>
      (await SharedPreferences.getInstance()).setBool(_maturityKey, value);
  static Future<bool> getStartNotification() async =>
      (await SharedPreferences.getInstance()).getBool(_startKey) ?? true;
  static Future<void> setStartNotification(bool value) async =>
      (await SharedPreferences.getInstance()).setBool(_startKey, value);
  static Future<bool> getProgress50Notification() async =>
      (await SharedPreferences.getInstance()).getBool(_progress50Key) ?? false;
  static Future<void> setProgress50Notification(bool value) async =>
      (await SharedPreferences.getInstance()).setBool(_progress50Key, value);
  static Future<bool> getProgress80Notification() async =>
      (await SharedPreferences.getInstance()).getBool(_progress80Key) ?? true;
  static Future<void> setProgress80Notification(bool value) async =>
      (await SharedPreferences.getInstance()).setBool(_progress80Key, value);
  static Future<bool> getHarvestNotification() async =>
      (await SharedPreferences.getInstance()).getBool(_harvestKey) ?? true;
  static Future<void> setHarvestNotification(bool value) async =>
      (await SharedPreferences.getInstance()).setBool(_harvestKey, value);

  static Future<int> getHarvestDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_harvestDaysKey) ?? 3;
  }

  static Future<void> setHarvestDays(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_harvestDaysKey, days.clamp(1, 30));
  }
}
