abstract class AppThemeEvent {}

class InitialAppTheme extends AppThemeEvent {}

class InitialAppLoading extends AppThemeEvent {}

class ChangeAppTheme extends AppThemeEvent {
  ChangeAppTheme();
}
