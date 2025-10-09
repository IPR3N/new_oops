import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  static const supportedLocales = ['en', 'fr', 'es'];

  LocaleNotifier() : super(_getInitialLocale()) {
    initLocale(); // Appelle la version publique
  }

  static Locale _getInitialLocale() {
    final systemLocale = WidgetsBinding.instance.window.locale;
    print('System locale detected: ${systemLocale.languageCode}');
    if (supportedLocales.contains(systemLocale.languageCode)) {
      return Locale(systemLocale.languageCode);
    }
    return const Locale('en');
  }

  Future<void> initLocale() async { // Méthode publique
    final prefs = await SharedPreferences.getInstance();
    String? savedLocale = prefs.getString('locale');

    print('Saved locale from SharedPreferences: $savedLocale');
    if (savedLocale != null && supportedLocales.contains(savedLocale)) {
      state = Locale(savedLocale);
    }
    print('Final locale set: ${state.languageCode}');
  }

  Future<void> setLocale(String languageCode) async {
    if (supportedLocales.contains(languageCode)) {
      state = Locale(languageCode);
      await _saveLocale(languageCode);
    } else {
      print('Language $languageCode not supported');
    }
  }

  Future<void> _saveLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', languageCode);
    print('Locale saved to SharedPreferences: $languageCode');
  }
}