abstract class AuthEvent {
  final String email;
  final String password;

  AuthEvent({required this.email, required this.password});
}

class LoginEvent extends AuthEvent {
  LoginEvent({required super.email, required super.password});
}

class RegisterEvent extends AuthEvent {
  RegisterEvent({required super.email, required super.password});
}
