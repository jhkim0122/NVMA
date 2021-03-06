import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/DataSource.dart';
import '../views/GaugeView.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import '../views/ViewUtils.dart';

class NoiseMeasurementPage extends StatefulWidget{
  final MicCapture micCapture;
  final Map sensorTimeDataModelsMap;
  const NoiseMeasurementPage(this.micCapture, this.sensorTimeDataModelsMap, {key}) : super(key:key);

  @override
  _NoiseMeasurementPageState createState() => _NoiseMeasurementPageState();
}

class _NoiseMeasurementPageState extends State<NoiseMeasurementPage> {

  var _timer;
  var _currentValue = 0.0;
  var _scale = 50;
  List<double> _series = [];

  @override
  void initState() {
    super.initState();

    widget.micCapture.activate();

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _series.clear();
      widget.sensorTimeDataModelsMap["internal mic"].getData().toList().forEach((elem){
        _series.add(elem*_scale);
      });
      _getCurrentValue();

      if(this.mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    widget.micCapture.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children:[
              getCard(
                  Column(
                      children:[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical:5),
                          child: Text("Noise Decibel Gauge", style: TextStyle(fontSize:20, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(
                          height:250,
                          child: GaugeView(20, 120, "dB", _currentValue),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom:10),
                          child:Text(_getNoiseDecibelInformation(_currentValue), style: const TextStyle(fontSize:18)),
                        )
                      ])
              ),
              getCard(
                Column(
                    children:[
                      const Padding(
                        padding: EdgeInsets.only(top:10),
                        child: Text("Noise Time Graph", style: TextStyle(fontSize:20, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(
                        height: 250,
                        child: charts.LineChart(
                          [charts.Series(
                            id: 'Noise Time Graph',
                            data: _series,
                            domainFn: (series, int? index) => (index!),
                            measureFn: (series, int? index) => series,
                            colorFn: (_, __) => charts.MaterialPalette.lime.shadeDefault,
                          )],
                        animate: false,
                        )
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:10),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text("scale : $_scale", style: const TextStyle(fontSize:12, color: Colors.grey))
                        ))
                    ]
                ),
              ),
            ])
    );
  }

  void _getCurrentValue() {
    double rmsSum = 0.0;
    var micData = widget.sensorTimeDataModelsMap["internal mic"].getData().toList();
    for(var i=0; i<micData.length; i++) {
      rmsSum += micData.elementAt(i) * micData.elementAt(i);
    }
    double rms = sqrt(rmsSum/micData.length);
    _currentValue = (20 * log(rms / 0.00002) / ln10);
  }

  String _getNoiseDecibelInformation(noiseValue) {
    if(noiseValue<25) return "20dB : ????????? ???????????? ??????";
    else if(noiseValue<35) return "30dB : ????????? ??????, ???????????? ??????";
    else if(noiseValue<45) return "40dB : ?????????, ????????? ????????? ??????";
    else if(noiseValue<55) return "50dB : ????????? ?????????";
    else if(noiseValue<65) return "60dB : ????????? ?????? ??????";
    else if(noiseValue<75) return "70dB : ????????? ??????, ???????????? ?????????";
    else if(noiseValue<85) return "80dB : ????????? ??? ????????? ??????";
    else if(noiseValue<95) return "90dB : ????????? ?????? ?????? ???";
    else if(noiseValue<105) return "100dB : ?????? ?????? ??? ????????? ??????";
    else if(noiseValue<115) return "110dB : ???????????? ?????? ??????";
    else return "120dB : ???????????? ????????? ??????";
  }

}