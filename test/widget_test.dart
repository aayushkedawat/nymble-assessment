// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:music_player/authentication/auth_bloc.dart';
import 'package:music_player/authentication/auth_screen.dart';
import 'package:music_player/config/app_theme_bloc.dart';
import 'package:music_player/config/keys.dart';
import 'package:music_player/songs/songs_bloc.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  MockFirebaseAuth mockFirebaseAuth = MockFirebaseAuth();

  testWidgets('Check Widgets and enter text', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(providers: [
        BlocProvider(
          create: (context) => SongBloc(),
        ),
        BlocProvider(
          create: (context) => AppThemeBloc(),
        ),
        BlocProvider(
          create: (context) => AuthBloc(mockFirebaseAuth),
        ),
      ], child: const MaterialApp(home: LoginScreen())),
    );

    expect(find.byKey(Keys.emailTFKey), findsOneWidget);
    expect(find.byKey(Keys.passwordTFKey), findsOneWidget);

    await tester.enterText(find.byKey(Keys.emailTFKey), 'aayush@aayush.com');
    await tester.enterText(find.byKey(Keys.passwordTFKey), '123456');
    await tester.tap(find.byKey(Keys.authButtonKey));
    await tester.pump();
    expect(find.text('aayush@aayush.com'), findsOneWidget);
    expect(find.text('123456'), findsOneWidget);
  });
}
