import 'dart:io';

class PlatformSize {
  static final isMobile = Platform.isAndroid || Platform.isIOS || Platform.isFuchsia;
  static double sizedBoxSpaceL = isMobile ? 20 : 15;
  static double sizedBoxSpaceS = isMobile ? 0 : 5;
}
