import 'package:music_player/config/theme/app_theme.dart';

abstract class AppThemeState {}

class InitialAppThemeState extends AppThemeState {}

class LoadingAppThemeState extends AppThemeState {}

class AppThemeSetState extends AppThemeState {
  AppTheme appTheme;
  AppThemeSetState({
    required this.appTheme,
  });
}
