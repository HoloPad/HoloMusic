import 'package:flutter/material.dart';

import '../Common/Parameters/AppStyle.dart';
import '../Common/Parameters/PlatformSize.dart';

enum ButtonType { normal, warning }

class CommonComponents {
  static TextButton generateButton(
      {required String text,
      IconData? icon,
      required Function() onClick,
      double opacity = 0.8,
      ButtonType buttonType = ButtonType.normal}) {
    double distance = PlatformSize.isMobile ? 0 : 12;

    return TextButton(
        style: TextButton.styleFrom(
            padding: EdgeInsets.only(bottom: distance, top: distance),
            alignment: Alignment.centerLeft),
        onPressed: onClick,
        child: Card(
            margin: EdgeInsets.zero,
            color: buttonType == ButtonType.normal
                ? AppStyle.primaryBackground.withOpacity(opacity)
                : const Color.fromRGBO(170, 0, 0, 1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(text, style: AppStyle.textStyle, textAlign: TextAlign.center),
                      SizedBox(width: icon != null ? 5 : 0),
                      if (icon != null) Icon(icon, color: AppStyle.text)
                    ]))));
  }
}
