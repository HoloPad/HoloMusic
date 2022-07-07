import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:holomusic/Common/Parameters/AppStyle.dart';
import 'package:holomusic/ServerRequests/UserRequest.dart';
import 'package:holomusic/UIComponents/CommonComponents.dart';
import 'package:holomusic/Views/ProfileView/RegisterView.dart';
import 'package:holomusic/Views/ProfileView/ResetPasswordView.dart';

class UserManagerView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UserManagerViewState();
}

class _UserManagerViewState extends State<UserManagerView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _responseMessage = "";
  bool _messageIsError = true;
  bool _showSendEmailButton = false;
  bool _isLoading = false;

  Future<void> _showDeleteAccountDialog() async {
    final _deletePasswordController = TextEditingController();
    final _deleteFormKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppStyle.primaryBackground,
          title: Text(AppLocalizations.of(context)!.deleteAccount, style: AppStyle.textStyle),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(AppLocalizations.of(context)!.confirmDeleteAccount, style: AppStyle.textStyle),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Form(
                        key: _deleteFormKey,
                        child: TextFormField(
                            style: AppStyle.textStyle,
                            controller: _deletePasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                                hintText: "Password", hintStyle: AppStyle.textStyle, filled: true),
                            validator: (value) {
                              if (value != null && value.isEmpty) {
                                return AppLocalizations.of(context)!.pleaseEnterYourPassword;
                              }
                              return null;
                            }))),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.yes, style: AppStyle.textStyle),
              onPressed: () async {
                if (_deleteFormKey.currentState?.validate() ?? false) {
                  final success = await UserRequest.deleteAccount(
                      _deletePasswordController.text.characters.string);
                  if (success) {
                    int count = 0;
                    Navigator.popUntil(context, (route) {
                      return count++ == 2;
                    });
                  }
                }
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel, style: AppStyle.textStyle),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

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
                      Text(_responseMessage,
                          style: TextStyle(
                              color:
                                  _messageIsError ? AppStyle.errorTextStyle.color : AppStyle.text)),
                      if (_showSendEmailButton && !_isLoading) ...[
                        const SizedBox(height: 15),
                        CommonComponents.generateButton(
                          text: AppLocalizations.of(context)!.reSendVerificationEmail,
                          onClick: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              final email = _emailController.value.text;
                              final password = _passwordController.value.text;
                              setState(() {
                                _isLoading = true;
                              });
                              final result =
                                  await UserRequest.sendVerificationEmail(email, password);
                              setState(() {
                                _isLoading = false;
                                _responseMessage = result
                                    ? AppLocalizations.of(context)!.emailSent
                                    : AppLocalizations.of(context)!.cannotSentEmail;
                                _messageIsError = !result;
                              });
                            }
                          },
                        )
                      ],
                      const SizedBox(height: 15),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : CommonComponents.generateButton(
                              text: AppLocalizations.of(context)!.login,
                              onClick: () async {
                                if (_formKey.currentState?.validate() ?? false) {
                                  final email = _emailController.value.text;
                                  final password = _passwordController.value.text;
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  final result = await UserRequest.userLogin(email, password);
                                  String errorToShow = "";
                                  switch (result) {
                                    case LoginResponse.success:
                                      Navigator.pop(context);
                                      break;
                                    case LoginResponse.emailNotVerified:
                                      errorToShow = AppLocalizations.of(context)!.emailNotVerified;
                                      break;
                                    case LoginResponse.error:
                                      errorToShow = AppLocalizations.of(context)!.wrongCredential;
                                      break;
                                  }
                                  setState(() {
                                    _showSendEmailButton = result == LoginResponse.emailNotVerified;
                                    _responseMessage = errorToShow;
                                    _messageIsError = result != LoginResponse.success;
                                    _isLoading = false;
                                  });
                                }
                              })
                    ]),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(children: [
                    const Expanded(
                        child: Divider(
                      color: Colors.white,
                    )),
                    Container(
                        margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Text(AppLocalizations.of(context)!.or, style: AppStyle.textStyle)),
                    const Expanded(
                        child: Divider(
                      color: Colors.white,
                    )),
                  ]),
                  const SizedBox(
                    height: 15,
                  ),
                  CommonComponents.generateButton(
                      text: AppLocalizations.of(context)!.signup,
                      onClick: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterView()),
                        ).then((value) => Navigator.pop(context));
                      }),
                  const Divider(),
                  CommonComponents.generateButton(
                      text: "Reset Password",
                      onClick: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ResetPasswordView()),
                        ).then((value) => Navigator.pop(context));
                      }),
                ] else ...[
                  CommonComponents.generateButton(
                      text: AppLocalizations.of(context)!.logout,
                      onClick: () async {
                        await UserRequest.logout();
                        Navigator.pop(context);
                      }),
                  const Divider(),
                  CommonComponents.generateButton(
                      text: AppLocalizations.of(context)!.deleteAccount,
                      buttonType: ButtonType.warning,
                      onClick: () => _showDeleteAccountDialog()),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
