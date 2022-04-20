import 'dart:async';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class GaugeView extends StatefulWidget{
  final double minValue;
  final double maxValue;
  final String unit;
  final double currentValue;
  const GaugeView(this.minValue, this.maxValue, this.unit, this.currentValue, {key}) : super(key:key);

  @override
  _GaugeViewState createState() => _GaugeViewState();
}

class _GaugeViewState extends State<GaugeView> {

  @override
  Widget build(BuildContext context) {
    return SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
                minimum: widget.minValue, maximum: widget.maxValue,
                ranges: <GaugeRange>[
                  GaugeRange(
                      startValue: widget.minValue,
                      endValue: widget.maxValue,
                      gradient: SweepGradient(
                        colors: [Colors.yellow, Colors.orange, Colors.yellow.shade900, Colors.deepOrange, Colors.redAccent, Colors.red, Colors.red.shade900, Colors.black],
                      ),
                      startWidth: 10,
                      endWidth: 10),
                ],
                pointers: <GaugePointer>[
                  NeedlePointer(
                    value: widget.currentValue,
                    needleLength: 0.8,
                    knobStyle: const KnobStyle(knobRadius:0.06),
                  )
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                      widget: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize:MainAxisSize.min,
                        children:[
                          Text((widget.currentValue).toStringAsFixed(1),
                              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                          Text(widget.unit,
                              style: const TextStyle(fontSize: 20)),
                      ]),
                      angle: 90,
                      positionFactor: 0.3)
                ])
              ]);
  }
  
}