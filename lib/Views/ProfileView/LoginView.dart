import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:holomusic/Common/Parameters/AppStyle.dart';
import 'package:holomusic/ServerRequests/User.dart';
import 'package:holomusic/UIComponents/CommonComponents.dart';

class LoginView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showWrongData = false;

  InputDecoration generateInputDecoration(String hint) {
    return InputDecoration(
        labelStyle: const TextStyle(color: Color.fromRGBO(0, 0, 0, 1)),
        contentPadding: const EdgeInsets.all(8),
        enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black12),
            borderRadius: BorderRadius.circular(15)),
        focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black12),
            borderRadius: BorderRadius.circular(15)),
        fillColor: const Color.fromRGBO(60, 60, 60, 1),
        hintText: hint,
        hintStyle: AppStyle.textStyle,
        filled: true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: AppStyle.scaffoldDecoration,
        padding: const EdgeInsets.all(16),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Icon(Icons.arrow_back_ios, color: AppStyle.text)),
                  ],
                ),
                Text(AppLocalizations.of(context)!.userManager,
                    style: AppStyle.titleStyle, textAlign: TextAlign.center),
                const SizedBox(height: 15),
                if (!UserRequest.isLogin()) ...[
                  Form(
                    key: _formKey,
                    child: Column(children: [
                      Text(
                        AppLocalizations.of(context)!.login,
                        style: AppStyle.textStyle,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                          style: AppStyle.textStyle,
                          decoration: generateInputDecoration(
                              AppLocalizations.of(context)!.emailOrUsername),
                          controller: _emailController,
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return AppLocalizations.of(context)!.enterYourEmail;
                            }
                            return null;
                          }),
                      const SizedBox(height: 15),
                      TextFormField(
                          style: AppStyle.textStyle,
                          decoration:
                              generateInputDecoration(AppLocalizations.of(context)!.password),
                          controller: _passwordController,
                          obscureText: true,
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return AppLocalizations.of(context)!.pleaseEnterYourPassword;
                            }
                            return null;
                          }),
                      const SizedBox(height: 15),
                      if (_showWrongData) ...[
                        Text(AppLocalizations.of(context)!.wrongCredential,
                            style: AppStyle.errorTextStyle),
                        const SizedBox(height: 15),
                      ],
                      CommonComponents.generateButton(
                          text: AppLocalizations.of(context)!.login,
                          onClick: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              final email = _emailController.value.text;
                              final password = _passwordController.value.text;
                              final success = await UserRequest.userLogin(email, password);
                              setState(() {
                                _showWrongData = !success;
                              });
                              if (success) {
                                Navigator.pop(context);
                              }
                            }
                          })
                    ]),
                  )
                ] else ...[
                  CommonComponents.generateButton(
                      text: AppLocalizations.of(context)!.logout,
                      onClick: () async {
                        final success = await UserRequest.logout();
                        if (success) Navigator.pop(context);
                      })
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
