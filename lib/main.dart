import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/authentication/auth_bloc.dart';
import 'package:music_player/config/app_theme_bloc.dart';
import 'package:music_player/config/app_theme_event.dart';
import 'package:music_player/config/app_theme_state.dart';
import 'package:music_player/config/strings.dart';
import 'package:music_player/config/theme/app_theme.dart';
import 'package:music_player/config/theme/dark_theme.dart';
import 'package:music_player/config/theme/light_theme.dart';
import 'package:music_player/songs/home_screen.dart';
import 'package:music_player/authentication/auth_screen.dart';
import 'package:music_player/songs/songs_bloc.dart';

import 'config/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SongBloc(),
        ),
        BlocProvider(
          create: (context) => AppThemeBloc(),
        ),
        BlocProvider(
          create: (context) => AuthBloc(firebaseAuth),
        ),
      ],
      child: MyApp(
        auth: firebaseAuth,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final FirebaseAuth auth;
  const MyApp({super.key, required this.auth});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of our application.

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero).then((value) {
      context.read<AppThemeBloc>().add(InitialAppLoading());

      context.read<AppThemeBloc>().add(InitialAppTheme());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppThemeBloc, AppThemeState>(
      builder: (ctx, state) {
        AppTheme appTheme = AppTheme.light;
        if (state is AppThemeSetState) {
          appTheme = state.appTheme;

          return MaterialApp(
            title: Strings.appTitle,
            theme: LightTheme.lightTheme,
            darkTheme: DarkTheme.darkTheme,
            // themeMode: ThemeMode.light,
            themeMode:
                appTheme == AppTheme.light ? ThemeMode.light : ThemeMode.dark,
            home: StreamBuilder<User?>(
              stream: widget.auth.userChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return snapshot.hasData
                    ? const HomeScreen()
                    : const LoginScreen();
              },
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
