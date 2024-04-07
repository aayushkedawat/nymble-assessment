import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/config/app_theme_event.dart';
import 'package:music_player/config/theme/app_theme.dart';
import 'package:music_player/config/prefs.dart';
import 'app_theme_state.dart';

class AppThemeBloc extends Bloc<AppThemeEvent, AppThemeState> {
  // AppThemeBloc() : super(AppThemeSetState(appTheme: AppTheme.light)) {
  AppThemeBloc() : super(LoadingAppThemeState()) {
    on<InitialAppTheme>((event, emit) async {
      AppTheme appTheme = await getAppTheme();
      emit(AppThemeSetState(appTheme: appTheme));
    });

    on<InitialAppLoading>((event, emit) async {
      emit(LoadingAppThemeState());
    });
    on<ChangeAppTheme>((event, emit) async {
      // for (var element in words) {
      //   if (element.contains(event.word)) {
      //     searchTitles.add(element);
      //   }
      // }
      AppTheme currentAppTheme = await getAppTheme();

      AppTheme? changedAppTheme;
      if (currentAppTheme == AppTheme.dark) {
        changedAppTheme = AppTheme.light;
      } else {
        changedAppTheme = AppTheme.dark;
      }
      await Prefs().setAppTheme(changedAppTheme);
      emit(AppThemeSetState(appTheme: changedAppTheme));
    });
    // on<Init>
  }

  Future<AppTheme> getAppTheme() async {
    return await Prefs().getAppTheme();
  }
}
