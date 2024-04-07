import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:music_player/authentication/auth_bloc.dart';
import 'package:music_player/authentication/auth_event.dart';
import 'package:music_player/authentication/auth_state.dart';
import 'package:music_player/config/assets.dart';
import 'package:music_player/config/common_widgets.dart';
import 'package:music_player/config/keys.dart';
import 'package:music_player/config/strings.dart';
import 'package:music_player/config/text_themes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isDarkTheme = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLogin = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Strings.appTitle,
          style: TextThemes.tsCairo32Bold,
        ),
        actions: [
          CommonWidget.themeIcon(),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthErrorState) {
              Fluttertoast.showToast(msg: state.errorMessage);
            }
          },
          child: Container(
            padding: MediaQuery.of(context).padding,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Image.asset(
                    Assets.music,
                    height: 200,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    isLogin ? Strings.login : Strings.register,
                    style: TextThemes.tsCairo32Bold,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CommonWidget.textFieldWidget(
                    label: 'Email',
                    isPassword: false,
                    key: Keys.emailTFKey,
                    textEditingController: _emailController,
                    suffixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CommonWidget.textFieldWidget(
                    label: 'Password',
                    isPassword: true,
                    key: Keys.passwordTFKey,
                    textEditingController: _passwordController,
                    suffixIcon: Icons.password,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                      });
                    },
                    child: Text(
                      isLogin
                          ? Strings.createAnAccount
                          : Strings.alreadyHaveAnAccount,
                      style: TextThemes.tsCairo18Bold.copyWith(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 50,
                    width: 250,
                    child: OutlinedButton(
                      key: Keys.authButtonKey,
                      onPressed: () {
                        if (isLogin) {
                          context.read<AuthBloc>().add(LoginEvent(
                              email: _emailController.text,
                              password: _passwordController.text));
                        } else {
                          context.read<AuthBloc>().add(RegisterEvent(
                              email: _emailController.text,
                              password: _passwordController.text));
                        }
                      },
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all<double>(5),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.transparent,
                        ),
                      ),
                      child: Text(
                        isLogin ? Strings.login : Strings.register,
                        style: TextThemes.tsCairo18Bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
