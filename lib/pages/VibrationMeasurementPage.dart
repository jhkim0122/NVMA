import 'package:flutter/material.dart';

import '../models/DataSource.dart';
import '../views/GaugeView.dart';

class VibrationMeasurementPage extends StatefulWidget{
  final List<BlueConnection> btConnectionList;
  final TcpConnection tcpConnection;
  final Map sensorTimeDataModelsMap;
  const VibrationMeasurementPage(this.btConnectionList, this.tcpConnection, this.sensorTimeDataModelsMap, {key}) : super(key:key);

  @override
  _VibrationMeasurementPageState createState() => _VibrationMeasurementPageState();
}

class _VibrationMeasurementPageState extends State<VibrationMeasurementPage> {

  @override
  Widget build(BuildContext context) {
    return const GaugeView("Vibration Measurement Page");
  }

}