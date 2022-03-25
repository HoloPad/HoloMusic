import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Utils {
  static String durationToText(Duration? duration) {
    if (duration == null) {
      return "";
    }
    var seconds = duration.inSeconds.remainder(60);
    if (duration.inHours < 1) {
      var s = "${duration.inMinutes}:";
      if (seconds < 10) s += "0";
      s += seconds.toString();
      return s;
    } else {
      var minutes = duration.inMinutes.remainder(60);
      var s= "${duration.inHours}:";
      if(minutes<10)s+="0";
      s+=minutes.toString();
      if (seconds < 10) s += "0";
      s += seconds.toString();
      return s;
    }
  }

  static String viewToString(int views, BuildContext context) {
    const oneBilion = 1000000000;
    const oneMilion = 1000000;
    if(views>oneBilion) {
      return (views/oneBilion).toStringAsFixed(1)+" "+AppLocalizations.of(context)!.billions;
    }
    if(views>oneMilion) {
      return (views/oneMilion).toStringAsFixed(1)+" "+AppLocalizations.of(context)!.millions;
    } else {
      return views.toString();
    }
  }
}
