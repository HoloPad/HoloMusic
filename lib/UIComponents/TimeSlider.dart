import 'package:flutter/material.dart';
import 'package:holomusic/Common/Utils.dart';

class TimeSlider extends StatelessWidget {
  Duration? current;
  Duration? end;
  Function(double)? onChange;

  TimeSlider({this.current, this.end, this.onChange, Key? key})
      : super(key: key);


  @override
  Widget build(BuildContext context) {
    current ??= const Duration(seconds: 0);
    end ??= const Duration(seconds: 0);
    const double thumbRadius = 10;

    return Column(children: [
      SliderTheme(
          data: SliderThemeData(
            thumbColor: Colors.green,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: thumbRadius),
            overlayShape: SliderComponentShape.noThumb
          ),
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
              Text(Utils.durationToText(current)),
              Text(Utils.durationToText(end))
            ],
          ))
    ]);
  }
}
