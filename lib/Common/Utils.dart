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
}
