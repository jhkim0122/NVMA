import 'dart:async';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class GaugeView extends StatefulWidget{
  final String title;
  const GaugeView(this.title, {key}) : super(key:key);

  @override
  _GaugeViewState createState() => _GaugeViewState();
}

class _GaugeViewState extends State<GaugeView> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if(mounted) setState((){});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SfRadialGauge(
          title: GaugeTitle(
              text: widget.title,
              textStyle: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
          axes: <RadialAxis>[
            RadialAxis(
                minimum: 0, maximum: 60,
                ranges: <GaugeRange>[
                  GaugeRange(
                      startValue: 0,
                      endValue: 60,
                      gradient: SweepGradient(
                        colors: [Colors.yellow, Colors.orange, Colors.yellow.shade900, Colors.deepOrange, Colors.redAccent, Colors.red, Colors.red.shade900, Colors.black],
                      ),
                      startWidth: 10,
                      endWidth: 10),
                ],
                pointers: <GaugePointer>[
                  NeedlePointer(
                    value: DateTime.now().second+ (DateTime.now().millisecond/1000),
                    needleLength: 0.8,
                    knobStyle: const KnobStyle(knobRadius:0.06),
                  )
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                      widget: Text(
                          (DateTime.now().second+ (DateTime.now().millisecond/1000)).toStringAsFixed(1),
                          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                      angle: 90,
                      positionFactor: 0.3)
                ])
              ])
    );
  }
  
}