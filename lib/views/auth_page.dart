import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wand_tictactoe/providers/firebase_auth_provider.dart';
import 'package:wand_tictactoe/widgets/wand_progress_indicator.dart';
import 'package:wand_tictactoe/widgets/wand_snackbar.dart';

class AuthPage extends StatefulWidget {
  AuthPage({this.initialMode});
  final AuthPageMode initialMode;

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String email;
  String passwd;
  String confirmPasswd;
  String username;

  RegExp emailRegexp = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  bool loadingRequest = false;

  AuthPageMode mode = AuthPageMode.signin;

  AnimationController _animationHideButtonController;
  CurvedAnimation _animationHideButtonCurve;
  Animation _animationHideButton;

  bool showConfirmPasswordInput = true;
  bool onGoingAnimation = false;

  Future<void> Function(String email, String passwd, String username)
      registerWithEmailAndPasswd;
  Future<void> Function(String email, String passwd) loginWithEmailAndPasswd;

  @override
  void initState() {
    super.initState();
    registerWithEmailAndPasswd = context
        .read(firebaseAuthController.notifier)
        .registerWithEmailAndPasswd;
    loginWithEmailAndPasswd =
        context.read(firebaseAuthController.notifier).loginWithEmailAndPasswd;
    if (widget.initialMode != null) mode = widget.initialMode;
    if (mode == AuthPageMode.login) showConfirmPasswordInput = false;

    _animationHideButtonController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    _animationHideButtonCurve = CurvedAnimation(
        parent: _animationHideButtonController, curve: Curves.easeOut);
    _animationHideButton =
        Tween<double>(begin: 0, end: 25).animate(_animationHideButtonCurve)
          ..addListener(() {
            setState(() {});
          });
  }

  void processAuth() async {
    setState(() => loadingRequest = true);
    try {
      if (mode == AuthPageMode.signin) {
        await registerWithEmailAndPasswd(email, passwd, username);
        if (mounted) {
          setState(() => loadingRequest = false);
        }
      } else if (mode == AuthPageMode.login) {
        await loginWithEmailAndPasswd(email, passwd);
        if (mounted) {
          setState(() => loadingRequest = false);
        }
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        ScaffoldMessenger.of(context)
            .showSnackBar(buildSnackBar(context, "${e.message}"));
        if (mounted) {
          setState(() => loadingRequest = false);
        }
      }
    }
  }

  Widget _buildLoginWidget() {
    return Material(
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
      elevation: 10,
      child: Column(
        verticalDirection: VerticalDirection.up,
        children: [
          AnimatedCrossFade(
            duration: Duration(milliseconds: 300),
            crossFadeState: loadingRequest
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            secondChild: Container(
              height: 100.0,
              child: Center(
                child: WANDProgressIndicator(
                  type: WANDProgressIndicatorType.minimal,
                  size: 50,
                ),
              ),
            ),
            firstChild: Column(
              verticalDirection: VerticalDirection.up,
              children: [
                Transform.translate(
                  offset: Offset(0, -_animationHideButton.value),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 20.0, right: 20.0, bottom: 10.0),
                          child: TextButton(
                            onPressed: () {
                              if (onGoingAnimation) return;
                              setState(() {
                                onGoingAnimation = true;
                                showConfirmPasswordInput =
                                    !showConfirmPasswordInput;
                              });
                              _animationHideButtonController
                                  .forward()
                                  .then((value) {
                                setState(() {
                                  switch (mode) {
                                    case AuthPageMode.login:
                                      mode = AuthPageMode.signin;
                                      break;
                                    case AuthPageMode.signin:
                                      mode = AuthPageMode.login;
                                      break;
                                  }
                                });

                                _animationHideButtonController
                                    .reverse()
                                    .then((value) {
                                  setState(() {
                                    onGoingAnimation = false;
                                  });
                                });
                              });
                            },
                            child: Text(mode == AuthPageMode.signin
                                ? "I already have an account"
                                : "I need an account"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, _animationHideButton.value),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 10.0, left: 20.0, right: 20.0),
                          child: ElevatedButton(
                            onPressed: () {
                              if (onGoingAnimation) return;
                              _formKey.currentState.save();
                              final ok = _formKey.currentState.validate();
                              if (ok) {
                                _formKey.currentState.save();
                                processAuth();
                              }
                            },
                            child: Opacity(
                              opacity: -((_animationHideButton.value / 25) - 1),
                              child: Text(mode == AuthPageMode.signin
                                  ? "Sign in"
                                  : "Log in"),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              top: 10.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  AnimatedCrossFade(
                    duration: Duration(milliseconds: 500),
                    sizeCurve: Curves.easeOut,
                    crossFadeState: showConfirmPasswordInput
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: _buildTextFormField(
                      text: "Username",
                      icon: Icons.person,
                      validator: (value) {
                        value = value.trim();
                        if (mode == AuthPageMode.signin) {
                          if (value == "") return "Field required!";
                        } else {
                          return null;
                        }
                      },
                      onSaved: (newValue) {
                        username = newValue;
                      },
                    ),
                    secondChild: Container(),
                  ),
                  _buildTextFormField(
                    text: "E-mail",
                    icon: Icons.alternate_email_rounded,
                    validator: (value) {
                      value = value.trim();
                      if (value == "") return "Field required!";
                      if (!emailRegexp.hasMatch(value))
                        return "Wrong email format!";
                    },
                    onSaved: (newValue) {
                      email = newValue;
                    },
                  ),
                  _buildTextFormField(
                    obscureText: true,
                    text: "Password",
                    icon: Icons.lock_rounded,
                    validator: (value) {
                      value = value.trim();

                      if (value == "") return "Field required!";
                      if (value.length < 6 && mode == AuthPageMode.signin)
                        return "Should be at least 6 characters long!";
                    },
                    onSaved: (newValue) {
                      passwd = newValue;
                    },
                  ),
                  AnimatedCrossFade(
                    duration: Duration(milliseconds: 500),
                    sizeCurve: Curves.easeOut,
                    crossFadeState: showConfirmPasswordInput
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: _buildTextFormField(
                      obscureText: true,
                      text: "Confirm password",
                      icon: Icons.lock_outline_rounded,
                      validator: (value) {
                        value = value.trim();

                        if (mode == AuthPageMode.signin) {
                          if (value == "") return "Field required!";
                          if (value != passwd && passwd != "")
                            return "Passwords don't match!";
                        } else {
                          return null;
                        }
                      },
                      onSaved: (newValue) {
                        confirmPasswd = newValue;
                      },
                    ),
                    secondChild: Container(),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    String text = "",
    IconData icon,
    Function(String) validator,
    Function onSaved,
    bool obscureText = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            obscureText: obscureText,
            key: Key("${text}_input"),
            onSaved: onSaved,
            decoration: InputDecoration(
              hintText: text,
              suffixIcon: icon == null ? null : Icon(icon),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!KeyboardVisibilityProvider.isKeyboardVisible(context))
                Image.asset("assets/title.png"),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, bottom: 16.0),
                      child: _buildLoginWidget(),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationHideButtonController.dispose();
    super.dispose();
  }
}

enum AuthPageMode {
  login,
  signin,
}
