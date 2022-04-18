import 'package:flutter/material.dart';

import '../models/DataSource.dart';
import '../views/GaugeView.dart';

class NoiseMeasurementPage extends StatefulWidget{
  final MicCapture micCapture;
  final Map sensorTimeDataModelsMap;
  const NoiseMeasurementPage(this.micCapture, this.sensorTimeDataModelsMap, {key}) : super(key:key);

  @override
  _NoiseMeasurementPageState createState() => _NoiseMeasurementPageState();
}

class _NoiseMeasurementPageState extends State<NoiseMeasurementPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const GaugeView("Noise Measurement Page");
  }

}