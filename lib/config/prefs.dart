import 'package:music_player/config/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  final String _appThemeKey = 'appTheme';
  final String _favouritesAddKey = 'favouritesAdd';

  Future<void> setAppTheme(AppTheme appTheme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(_appThemeKey, appTheme.name);
  }

  Future<AppTheme> getAppTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String appTheme = prefs.getString(_appThemeKey) ?? 'light';
    if (appTheme == 'light') {
      return AppTheme.light;
    }
    return AppTheme.dark;
  }

  Future<void> setSyncStatus(bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_favouritesAddKey, status);
  }

  Future<bool> getSyncStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool status = prefs.getBool(_favouritesAddKey) ?? false;
    return status;
  }

  Future<void> setFavourites(List<String> fav) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(_favouritesAddKey, fav);
  }

  Future<List<String>> getFavourites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> favList = prefs.getStringList(_favouritesAddKey) ?? [];
    return favList;
  }

  Future<void> clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.clear();
  }
}
