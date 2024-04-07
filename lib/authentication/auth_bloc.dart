import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/authentication/auth_event.dart';
import 'package:music_player/authentication/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;
  AuthBloc(this._firebaseAuth) : super(InitialAuthState()) {
    on<LoginEvent>((event, emit) async {
      String? validateEmailMessage =
          validateNonEmptyField(event.email, 'email');
      String? validatePasswordMessage =
          validateNonEmptyField(event.password.trim(), 'password');

      if (validateEmailMessage != null) {
        emit(AuthErrorState(errorMessage: validateEmailMessage));
        return;
      } else if (validatePasswordMessage != null) {
        emit(AuthErrorState(errorMessage: validatePasswordMessage));
        return;
      } else {
        try {
          await loginWithFirebase(event.email, event.password);
          emit(AuthSuccessState());
        } catch (ex) {
          emit(AuthErrorState(errorMessage: ex.toString()));
        }
      }
    });
    on<RegisterEvent>((event, emit) async {
      String? validateEmailMessage =
          validateNonEmptyField(event.email.trim(), 'email');
      String? validatePasswordMessage =
          validateNonEmptyField(event.password.trim(), 'password');

      if (validateEmailMessage != null) {
        emit(AuthErrorState(errorMessage: validateEmailMessage));
        return;
      } else if (validatePasswordMessage != null) {
        emit(AuthErrorState(errorMessage: validatePasswordMessage));
        return;
      } else {
        try {
          await registerWithFirebase(event.email, event.password);
          emit(AuthSuccessState());
        } catch (ex) {
          emit(AuthErrorState(errorMessage: ex.toString()));
        }
      }
    });
  }

  String? validateNonEmptyField(String? text, String field) {
    if (text == null || text.isEmpty) {
      return 'Please enter $field';
    }
    return null;
  }

  Future<void> loginWithFirebase(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw e.message ?? '';
    } catch (ex) {
      throw ex.toString();
    }
  }

  Future<void> registerWithFirebase(String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw e.message ?? '';
    } catch (ex) {
      throw ex.toString();
    }
  }
}
