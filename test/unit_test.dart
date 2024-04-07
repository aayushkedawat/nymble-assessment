import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/authentication/auth_bloc.dart';

import 'widget_test.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockFirebaseAuth mockFirebaseAuth = MockFirebaseAuth();

  test('Auth Bloc test', () {
    String? email = "";
    String field = "email";

    // Act
    String? errorMessage =
        AuthBloc(mockFirebaseAuth).validateNonEmptyField(email, field);

    // Assert
    expect(errorMessage, "Please enter email");

    email = "test@example.com";
    field = "email";

    // Act
    errorMessage =
        AuthBloc(mockFirebaseAuth).validateNonEmptyField(email, field);

    // Assert
    expect(errorMessage, null);
  });
}
