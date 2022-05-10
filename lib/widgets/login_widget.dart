import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ios_android_flutter/helpers/validation_errors.dart';
import 'package:ios_android_flutter/rest/apis.dart';
import 'package:ios_android_flutter/rest/retrofit.dart';
import 'package:ios_android_flutter/sqlite/provider.dart';

import '../helpers/theme.dart';
import '../model/response_token.dart';
import '../sqlite/user.dart';
import 'tracks_widget.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({Key? key}) : super(key: key);

  @override
  State<LoginWidget> createState() => _LoginWidget();
}

class _LoginWidget extends State<LoginWidget> {
  int selectedIndex = 0;
  String? loginValid;
  String? firstnameValid;
  String? lastnameValid;
  String? emailValid;
  String? passwordValid;
  final loginController = TextEditingController();
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    loginController.dispose();
    firstnameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    checkAccess();
    loginController.addListener(validateLogin);
    firstnameController.addListener(validateFirstname);
    lastnameController.addListener(validateLastname);
    emailController.addListener(validateEmail);
    passwordController.addListener(validatePassword);
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void validateLogin() {
    String? validate =
        loginController.text.isNotEmpty ? null : ValidationErrors.required;
    if (validate != loginValid) {
      setState(() {
        loginValid = validate;
      });
    }
  }

  void validateFirstname() {
    String? validate =
        firstnameController.text.isNotEmpty ? null : ValidationErrors.required;
    if (validate != firstnameValid) {
      setState(() {
        firstnameValid = validate;
      });
    }
  }

  void validateLastname() {
    String? validate =
        lastnameController.text.isNotEmpty ? null : ValidationErrors.required;
    if (validate != lastnameValid) {
      setState(() {
        lastnameValid = validate;
      });
    }
  }

  void validateEmail() {
    String? validate =
        emailController.text.isNotEmpty ? null : ValidationErrors.required;
    if (validate != emailValid) {
      setState(() {
        emailValid = validate;
      });
    }
  }

  void validatePassword() {
    String? validate =
        passwordController.text.isNotEmpty ? null : ValidationErrors.required;
    if (validate != passwordValid) {
      setState(() {
        passwordValid = validate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: OrientationBuilder(builder: (context, orientation) {
          return getTemplate(orientation);
        }));
  }

  ListView getTemplate(Orientation orientation) {
    if (selectedIndex == 1) {
      return registerForm();
    } else {
      return loginForm();
    }
  }

  ListView loginForm() {
    return ListView(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
              flex: 1,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 48, 16, 8),
                  child: TextField(
                    controller: loginController,
                    autofocus: false,
                    style: const TextStyle(fontSize: 22.0),
                    decoration: InputDecoration(
                        errorStyle: const TextStyle(fontSize: 16),
                        suffixIcon: loginValid == null
                            ? null
                            : const Icon(Icons.error, color: Colors.red),
                        hintText: AppLocalizations.of(context)?.loginHint ?? '',
                        contentPadding: const EdgeInsets.only(
                            left: 14.0, bottom: 8.0, top: 8.0),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(width: 2.0),
                          borderRadius: BorderRadius.circular(8.0),
                        )),
                  )))
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
              flex: 1,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    controller: passwordController,
                    autofocus: false,
                    obscureText: true,
                    style: const TextStyle(fontSize: 22.0),
                    decoration: InputDecoration(
                        errorStyle: const TextStyle(fontSize: 16, height: 0.6),
                        suffixIcon: passwordValid == null
                            ? null
                            : const Icon(Icons.error, color: Colors.red),
                        hintText:
                            AppLocalizations.of(context)?.passwordHint ?? '',
                        contentPadding: const EdgeInsets.only(
                            left: 14.0, bottom: 8.0, top: 8.0),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(width: 2.0),
                          borderRadius: BorderRadius.circular(8.0),
                        )),
                  )))
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 46),
                    primary: CustomColors.primaryColor,
                    textStyle: const TextStyle(fontSize: 20),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    )),
                onPressed: auth,
                child: Text(AppLocalizations.of(context)?.loginForm ?? ''),
              ))
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Flexible(
              flex: 1,
              child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: TextButton(
                    key: Key("toRegister"),
                    onPressed: () {
                      onItemTapped(1);
                    },
                    child: Text(
                        AppLocalizations.of(context)?.registerButton ?? ''),
                  )))
        ]),
      ],
    );
  }

  ListView registerForm() {
    return ListView(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
              flex: 1,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 50, 16, 8),
                  child: TextField(
                    controller: loginController,
                    autofocus: false,
                    style: TextStyle(fontSize: 22.0),
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        errorStyle: const TextStyle(fontSize: 16, height: 0.6),
                        suffixIcon: loginValid == null
                            ? null
                            : const Icon(Icons.error, color: Colors.red),
                        hintText: AppLocalizations.of(context)?.loginHint ?? '',
                        contentPadding: const EdgeInsets.only(
                            left: 14.0, bottom: 8.0, top: 8.0),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(width: 2.0),
                          borderRadius: BorderRadius.circular(8.0),
                        )),
                  )))
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
              flex: 1,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    controller: firstnameController,
                    autofocus: false,
                    style: TextStyle(fontSize: 22.0),
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        errorStyle: const TextStyle(fontSize: 16, height: 0.6),
                        suffixIcon: firstnameValid == null
                            ? null
                            : const Icon(Icons.error, color: Colors.red),
                        hintText:
                            AppLocalizations.of(context)?.firstnameHint ?? '',
                        contentPadding: const EdgeInsets.only(
                            left: 14.0, bottom: 8.0, top: 8.0),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(width: 2.0),
                          borderRadius: BorderRadius.circular(8.0),
                        )),
                  )))
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
              flex: 1,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    controller: lastnameController,
                    autofocus: false,
                    style: TextStyle(fontSize: 22.0),
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        errorStyle: const TextStyle(fontSize: 16, height: 0.6),
                        suffixIcon: lastnameValid == null
                            ? null
                            : const Icon(Icons.error, color: Colors.red),
                        hintText:
                            AppLocalizations.of(context)?.lastnameHint ?? '',
                        contentPadding: const EdgeInsets.only(
                            left: 14.0, bottom: 8.0, top: 8.0),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(width: 2.0),
                          borderRadius: BorderRadius.circular(8.0),
                        )),
                  )))
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
              flex: 1,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    controller: emailController,
                    autofocus: false,
                    style: TextStyle(fontSize: 22.0),
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        errorStyle: const TextStyle(fontSize: 16, height: 0.6),
                        suffixIcon: emailValid == null
                            ? null
                            : const Icon(Icons.error, color: Colors.red),
                        hintText: AppLocalizations.of(context)?.emailHint ?? '',
                        contentPadding: const EdgeInsets.only(
                            left: 14.0, bottom: 8.0, top: 8.0),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(width: 2.0),
                          borderRadius: BorderRadius.circular(8.0),
                        )),
                  )))
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
              flex: 1,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    controller: passwordController,
                    autofocus: false,
                    obscureText: true,
                    style: TextStyle(fontSize: 22.0),
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        errorStyle: const TextStyle(fontSize: 16, height: 0.6),
                        suffixIcon: passwordValid == null
                            ? null
                            : const Icon(Icons.error, color: Colors.red),
                        hintText:
                            AppLocalizations.of(context)?.passwordHint ?? '',
                        contentPadding: const EdgeInsets.only(
                            left: 14.0, bottom: 8.0, top: 8.0),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(width: 2.0),
                          borderRadius: BorderRadius.circular(8.0),
                        )),
                  )))
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 46),
                    primary: CustomColors.primaryColor,
                    textStyle: const TextStyle(fontSize: 20),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    )),
                onPressed: () {
                  register();
                },
                child: Text(AppLocalizations.of(context)?.registerButton ?? ''),
              ))
        ]),
        TextButton(
          onPressed: () {
            onItemTapped(0);
          },
          child: Text(AppLocalizations.of(context)?.loginForm ?? ''),
        )
      ],
    );
  }

  void auth() async {
    String login = loginController.text;
    String password = passwordController.text;
    if (login.isNotEmpty && password.isNotEmpty) {
      AuthResponse response = await ApiRequest(
              Dio(BaseOptions(contentType: "application/json")),
              baseUrl: Apis.baseUrl)
          .login(login, password);
      await handleResponse(response);
    }
  }

  void register() async {
    String login = loginController.text;
    String firstname = firstnameController.text;
    String lastname = lastnameController.text;
    String email = emailController.text;
    String password = passwordController.text;
    if (login.isNotEmpty &&
        firstname.isNotEmpty &&
        lastname.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty) {
      AuthResponse response = await ApiRequest(
              Dio(BaseOptions(contentType: "application/json")),
              baseUrl: Apis.baseUrl)
          .register(login, firstname, lastname, email, password);
      handleResponse(response);
    }
  }

  Future<void> handleResponse(AuthResponse response) async {
    if (response != null) {
      User? user = await DBProvider.db.getUserByLogin(response.username);
      if (user != null) {
        user.token = response.token;
        user.active = 1;
        DBProvider.db.updateUser(user);
        DBProvider.userId = user.id;
      } else {
        User user =
            User(login: response.username, token: response.token, active: 1);
        DBProvider.db.newUser(user);
        DBProvider.userId =
            (await DBProvider.db.getUserByLogin(user.login))?.id;
      }
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => TracksWidget(needToWrap: false)));
    }
  }

  void checkAccess() async {
    User? user = await DBProvider.db.getActiveUser();
    if (user != null) {
      String token = user.token;
      bool hasAccess = await ApiRequest(
              Dio(BaseOptions(contentType: "application/json")),
              baseUrl: Apis.baseUrl)
          .check(token);
      if (hasAccess) {
        DBProvider.userId = user.id;
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => TracksWidget(needToWrap: false)));
      } else {
        user.active = 0;
        DBProvider.db.updateUser(user);
      }
    }
  }
}
