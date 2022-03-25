import 'package:flutter/material.dart';
import 'package:holomusic/Common/Misc/Utils.dart';

class TimeSlider extends StatelessWidget {
  Duration? current;
  Duration? end;
  Function(double)? onChange;
  Color? textColor;

  TimeSlider({this.current, this.end, this.onChange, this.textColor, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    current ??= const Duration(seconds: 0);
    end ??= const Duration(seconds: 0);
    const double thumbRadius = 10;

    return Column(children: [
      SliderTheme(
          data: SliderThemeData(
              thumbColor: const Color.fromRGBO(213, 213, 213, 1.0),
              activeTrackColor: const Color.fromRGBO(255, 255, 255, 1),
              inactiveTrackColor: const Color.fromRGBO(255, 255, 255, 0.1),
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: thumbRadius),
              overlayShape: SliderComponentShape.noThumb),
          child: Slider(
            value: current!.inSeconds.toDouble(),
            min: 0,
            max: end!.inSeconds.toDouble(),
            onChanged: onChange,
          )),
      Padding(
          padding: const EdgeInsets.fromLTRB(thumbRadius, 0, thumbRadius, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(Utils.durationToText(current),
                  style: TextStyle(color: textColor)),
              Text(Utils.durationToText(end),
                  style: TextStyle(color: textColor))
            ],
          ))
    ]);
  }
}
