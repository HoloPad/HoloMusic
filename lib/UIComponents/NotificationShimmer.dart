import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../Common/Notifications/ShimmerLoadingNotification.dart';
import '../Common/Parameters/AppStyle.dart';
import 'Shimmer.dart';

class NotificationShimmer extends StatefulWidget {
  Widget child;
  int elementsToLoad;
  String notificationId;
  Duration timeout;
  bool smartTimeout; //Set a max interval time between received notifications
  Duration maxWaitingTime;

  NotificationShimmer(
      {Key? key,
      required this.child,
      required this.elementsToLoad,
      required this.notificationId,
      this.timeout = const Duration(seconds: 2),
      this.maxWaitingTime = const Duration(seconds: 1),
      this.smartTimeout = true})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _NotificationShimmerState();
}

class _NotificationShimmerState extends State<NotificationShimmer> {
  int loadedElements = 0;
  bool showLoading = true;
  Timer? timer;
  Future? futureTask;
  bool isMounted = true;

  @override
  void initState() {
    if (widget.smartTimeout) {
      _startTimer();
    } else {
      futureTask =
          Future.delayed(widget.timeout).then((value) => stopLoading());
    }
    super.initState();
  }

  void _startTimer() {
    timer = Timer(widget.maxWaitingTime, stopLoading);
  }

  @override
  void dispose() {
    isMounted = false;
    timer?.cancel();
    super.dispose();
  }

  void stopLoading() {
    if (!isMounted && !showLoading) {
      return;
    }
    setState(() {
      showLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: AppStyle.ShimmerColorBase,
        highlightColor: AppStyle.ShimmerColorBackground,
        enabled: showLoading,
        child: NotificationListener<ShimmerLoadingNotification>(
            onNotification: (not) {
              if (not.id != widget.notificationId) return false;
              loadedElements++;
              if (loadedElements >= widget.elementsToLoad && showLoading) {
                WidgetsBinding.instance
                    .addPostFrameCallback((timeStamp) => stopLoading());
              }
              timer?.cancel();
              _startTimer();
              return true;
            },
            child: widget.child));
  }
}
