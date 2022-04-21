import 'dart:async';

import 'package:flutter/material.dart';

import '../models/DataSource.dart';
import '../utils/unit.dart';
import '../utils/FFT.dart';
import '../views/GaugeView.dart';
import '../views/ViewUtils.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class VibrationMeasurementPage extends StatefulWidget{
  final List<BlueConnection> btConnectionList;
  final TcpConnection tcpConnection;
  final Map sensorTimeDataModelsMap;
  const VibrationMeasurementPage(this.btConnectionList, this.tcpConnection, this.sensorTimeDataModelsMap, {key}) : super(key:key);

  @override
  _VibrationMeasurementPageState createState() => _VibrationMeasurementPageState();
}

class _VibrationMeasurementPageState extends State<VibrationMeasurementPage> {

  var _timer;
  var sensorConnection;
  var validIndex = 0;

  List _ffts = [];
  var _queueSize = 512;
  var _fft = [0.0];

  @override
  void initState() {
    super.initState();
    _getValidSensor();

    for (int i = 0; i < 3; i++) {
      _ffts.add([0.0,]);
    }

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {

      if(sensorConnection!=null && sensorConnection.isActivate()){
        for (var i = 0; i < 3; i++) {
          var _samplingRate = widget.sensorTimeDataModelsMap['di'+(validIndex*3+i+1).toString()].getSamplingRate().toDouble();
          var _queuedTime = (widget.sensorTimeDataModelsMap['di'+(validIndex*3+i+1).toString()].getMaxLength() / _samplingRate);
          var _freqResolution = _samplingRate / _queueSize;
          // realPainter.xMax = (1/_freqResolution);
          List<double> list = [0.0,];
          var timeDataList = widget.sensorTimeDataModelsMap['di'+(validIndex*3+i+1).toString()].getData().toList();
          if(timeDataList.length > _queueSize){
            list = [];
            timeDataList.sublist((timeDataList.length - _queueSize).toInt(), timeDataList.length).forEach((value){
              list.add(value);
            });
          }
          _ffts[i] = (fft.process(list));
          _ffts[i] = Unit.fromLinearToDecibel(_ffts[i], 0.000001);

          if(i==2) _fft = _ffts.last.toList();

        }
      }

      if(mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children:[
          getCard(_getConnectionButtons()),
          getCard(
              Column(
                  children:[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical:5),
                      child: Text("Vibration Gauge", style: TextStyle(fontSize:20, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(
                        height:250,
                        child: GaugeView(0, 100, "dB", _fft.last)
                    ),
                  ])
          ),
          getCard(
            Column(
                children:[
                  const Padding(
                    padding: EdgeInsets.only(top:10),
                    child: Text("Vibration Time Graph", style: TextStyle(fontSize:20, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                      height: 250,
                      child: charts.LineChart(
                        [
                          for(int i=0; i<3; i++)
                            charts.Series(
                              id: 'Vibration Time Graph',
                              data: _ffts[i],
                              domainFn: (series, int? index) => (index!),
                              measureFn: (series, int? index) => series,
                              colorFn: (_, __) => charts.MaterialPalette.lime.shadeDefault,
                            )
                        ],
                        animate: false,
                      )
                  ),
                ]
            ),
          ),
        ]
      )
    );
  }

  _getValidSensor() {
    widget.btConnectionList.forEach((con) {
      if (con.isActivate()) {
        sensorConnection = con;
        validIndex = widget.btConnectionList.indexOf(sensorConnection);
      }
    });
  }

  _getConnectionButtons() {
    List<Widget> sensorCons = [];

    widget.btConnectionList.forEach((con) {
      sensorCons.add(FlatButton(
        child: Column(
          children: [
            Container(
              width: 50.0,
              height: 49.0,
              margin: const EdgeInsets.only(top:10, bottom: 10),
              decoration: BoxDecoration(
                color: con.isActivate() ? Colors.blue.shade600 : Colors.grey,
                shape: BoxShape.circle,
              ),
              child: Icon(con.isActivate() ? Icons.bluetooth_rounded : Icons.bluetooth_disabled_rounded, color: Colors.white, size: 40.0),
            ),
            Text(con.name, style: TextStyle(fontSize: 13.0, color: con.isActivate() ? Colors.blue.shade600 : Colors.grey)),
          ],
        ),
        onPressed: () async {
          String conName = " ";
          widget.btConnectionList.forEach((connection) {
            if (connection.isActivate() && connection != con) {
              conName = connection.name;
            }
          });
          if (conName != " ") {
            await _popupRejection(conName);
          } else {
            if(!con.isActivate()) {
              await con.activate();
            } else {
              con.deactivate();
              for(int i=0; i<3; i++) {
                _ffts[i] = [[0.0,],[0.0,]];
                widget.sensorTimeDataModelsMap['di'+(validIndex*3+i+1).toString()].data.clear();
              }
            }
            setState((){});
          }
        },
      ));
    });

    if(sensorCons.isEmpty){
      sensorCons.add(
          const Padding(
              padding: EdgeInsets.only(left:10, right:10),
              child: Center(
                  child: Text('등록된 Bluetooth Device가 없습니다.\n설정 메뉴에서 Sensor Connection을 연결해주세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),)
              )
          )
      );
    }
    return Container(
      color: Colors.transparent,
      height: 100.0,
      padding: const EdgeInsets.only(top:10),
      child: Scrollbar(
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: sensorCons,
          )
      ),
    );
  }

  _popupRejection(conName) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          contentPadding:
          const EdgeInsets.only(top: 30.0, left: 15.0, right: 15.0),
          content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("현재 미지원 기능입니다.", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 20.0),
                Text("다른 디바이스($conName)가 연결되어 있습니다.\n연결 해제 후 다시 시도해주세요.", textAlign: TextAlign.center),
              ]),
          actions: <Widget>[
            FlatButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

}