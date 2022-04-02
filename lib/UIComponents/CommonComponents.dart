import 'package:flutter/material.dart';

import '../Common/Parameters/AppStyle.dart';
import '../Common/Parameters/PlatformSize.dart';

class CommonComponents {
  static TextButton generateButton({
    required String text,
    IconData? icon,
    required Function() onClick,
    double opacity = 0.8,
  }) {
    double distance = PlatformSize.isMobile ? 0 :12;
    return TextButton(
        style: TextButton.styleFrom(
            padding: EdgeInsets.only(bottom: distance,top:distance),
            alignment: Alignment.centerLeft),
        onPressed: onClick,
        child: Card(
            margin: EdgeInsets.zero,
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
