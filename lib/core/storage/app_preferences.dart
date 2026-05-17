import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences._();
  static final AppPreferences instance = AppPreferences._();

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  static const _selectedTabKey = 'selected_dashboard_tab';
  static const _showOfflineBannerKey = 'show_offline_banner';

  Future<int> getSelectedDashboardTab() async =>
      await _prefs.getInt(_selectedTabKey) ?? 0;

  Future<void> setSelectedDashboardTab(int index) async {
    await _prefs.setInt(_selectedTabKey, index);
  }

  Future<bool> getShowOfflineBanner() async =>
      await _prefs.getBool(_showOfflineBannerKey) ?? true;

  Future<void> setShowOfflineBanner(bool value) async {
    await _prefs.setBool(_showOfflineBannerKey, value);
  }
}
