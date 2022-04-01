import 'package:flutter/material.dart';

import '../Common/Parameters/AppStyle.dart';

class CommonComponents {
  static TextButton generateButton({
    required String text,
    IconData? icon,
    required Function() onClick,
    double opacity = 0.8,
  }) {
    return TextButton(
        onPressed: onClick,
        child: Card(
            color: AppStyle.primaryBackground.withOpacity(opacity),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(text, style: AppStyle.textStyle),
                      const SizedBox(width: 5),
                      Icon(icon, color: AppStyle.text)
                    ]))));
  }
}
