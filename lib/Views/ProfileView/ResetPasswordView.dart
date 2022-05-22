import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:holomusic/ServerRequests/UserRequest.dart';
import 'package:validators/validators.dart';

import '../../Common/Parameters/AppStyle.dart';
import '../../UIComponents/CommonComponents.dart';

class ResetPasswordView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  static const _usernameId = 0;
  static const _emailId = 1;
  static const _passwordId = 2;
  static const List<String> fieldsIds = ["username", "email", "password"];

  Map<String, String?> _errorMap = {
    fieldsIds[_usernameId]: null,
    fieldsIds[_emailId]: null,
    fieldsIds[_passwordId]: null,
  };

  InputDecoration generateInputDecoration(String hint, [String? error]) {
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
        filled: true,
        errorText: error);
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.operationSuccess),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Reset ok!"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.ok),
              onPressed: () {
                int count = 0;
                Navigator.popUntil(context, (route) {
                  return count++ == 2;
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future onRegisterClick() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      final email = _emailController.text.characters.string;
      final username = _usernameController.text.characters.string;
      final password = _passwordController.text.characters.string;

      final response = await UserRequest.resetPassword(email, password);
      Map<String, String?> newErrorMaps = {};
      bool responseSuccess = response.keys.isEmpty;
      if (!responseSuccess) {
        for (var field in fieldsIds) {
          for (int i = 0; i < response.keys.length; i++) {
            if (field == response.keys.elementAt(i)) {
              //If searching field and received filed matches
              final message = response.values.elementAt(i).first;
              newErrorMaps[field] = message;
            } //endFor
          } //endFor

          if (!response.keys.contains(field)) {
            //Fill not passed fields with null
            newErrorMaps[field] = null;
          }
        }
        setState(() {
          _errorMap = newErrorMaps;
        });
      } else {
        //If signup success
        _showMyDialog();
      }
      setState(() {
        _isLoading = false;
      });
    }
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
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back_ios, color: AppStyle.text))
                ]),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    "Reset Password",
                    style: AppStyle.textStyle,
                  )
                ]),
                Form(
                    key: _formKey,
                    child: Column(children: [
                      const SizedBox(height: 15),
                      TextFormField(
                          style: AppStyle.textStyle,
                          decoration:
                          generateInputDecoration("E-Mail", _errorMap[fieldsIds[_emailId]]),
                          controller: _emailController,
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return AppLocalizations.of(context)!.pleaseEnterYourEmail;
                            }
                            if (!isEmail(value!)) {
                              return AppLocalizations.of(context)!.itIsNotAnEmail;
                            }
                            return null;
                          }),
                      const SizedBox(height: 15),
                      TextFormField(
                          style: AppStyle.textStyle,
                          decoration: generateInputDecoration(
                              AppLocalizations.of(context)!.password,
                              _errorMap[fieldsIds[_passwordId]]),
                          obscureText: true,
                          controller: _passwordController,
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return AppLocalizations.of(context)!.pleaseEnterYourPassword;
                            }
                            if (value!.length < 3) {
                              return AppLocalizations.of(context)!.enterAtLeast3character;
                            }
                            return null;
                          }),
                      const SizedBox(height: 15),
                      TextFormField(
                          style: AppStyle.textStyle,
                          decoration:
                          generateInputDecoration(AppLocalizations.of(context)!.passwordRepeat),
                          obscureText: true,
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return AppLocalizations.of(context)!.pleaseRepeatYourPassword;
                            }
                            if (_passwordController.value.text != value) {
                              return AppLocalizations.of(context)!.yourPasswordMustMatch;
                            }
                            return null;
                          }),
                    ])),
                const SizedBox(height: 15),
                _isLoading
                    ? const CircularProgressIndicator()
                    : CommonComponents.generateButton(
                    text: "Reset", onClick: onRegisterClick),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
