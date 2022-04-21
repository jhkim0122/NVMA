import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:nvma/models/options/BluetoothOptions.dart';

import '../models/DataSource.dart';
import '../models/options/SensorOptions.dart';
import '../views/ViewUtils.dart';
import 'BluetoothSettingPopup.dart';

class SettingPage extends StatefulWidget {
  final MicCapture micCapture;
  final List<BlueConnection> btConnectionList;
  final TcpConnection tcpConnection;
  final Map sensorTimeDataModelsMap;
  final BluetoothOptions btOptions;
  final SensorOptions sensorOptions;
  const SettingPage(this.micCapture, this.btConnectionList, this.tcpConnection, this.sensorTimeDataModelsMap, this.btOptions, this.sensorOptions, {key}) : super(key:key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  List<Widget> _btSensorCards = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _getBtSensorCards();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          Padding(
              padding: const EdgeInsets.only(top:20, left:20),
              child: Align(
                alignment: Alignment.centerLeft,
                child:Text("Connection Setting", style: TextStyle(color:Colors.blue.shade700, fontWeight: FontWeight.w700, fontSize:25))
              )
          ),
          getCard(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding:EdgeInsets.only(bottom:5, right: 20),
                  child: Text("Vibration Bluetooth Sensors", style: TextStyle(fontSize:20, fontWeight: FontWeight.bold)),),
                SingleChildScrollView(
                  padding: const EdgeInsets.only(left:10),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                      children: (_btSensorCards.isNotEmpty ? _btSensorCards : <Widget>[const SizedBox(height:0)])
                          + [Container(
                              height: 50,
                              margin: const EdgeInsets.only(top:10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.blue.shade600, width: 2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(Icons.add, color: Colors.blue.shade600, size: 30.0),
                                onPressed: () async{
                                  await FlutterBluetoothSerial.instance.requestEnable();
                                  await _popupBluetoothSetting();
                                  setState(() {});
                                },
                              )),
                          ]),
                ),
              ]),
            color: Colors.blue.withOpacity(0.1),
          )
        ]
      )
    );
  }

  _getBtSensorCards(){
    _btSensorCards  = [];
    widget.btConnectionList.forEach((con){
      _btSensorCards.add(
          Container(
              height: 50,
              margin: const EdgeInsets.only(top:10, right:10),
              decoration: BoxDecoration(
                color: con.isActivate()?Colors.blue.shade600:Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: FlatButton.icon(
                  icon: Icon(con.isActivate()?Icons.bluetooth_connected:Icons.bluetooth_disabled_rounded, color: con.isActivate()?Colors.white:Theme.of(context).disabledColor, size: 30.0),
                  label: Text(con.name, style:TextStyle(color: con.isActivate()?Colors.white:Theme.of(context).disabledColor)),
                  onPressed: () async{
                    String conName = " ";
                    widget.btConnectionList.forEach((connection){
                      if(connection.isActivate() && connection!=con) conName = connection.name;
                    });
                    if(conName != " ") {await _popupRejection(conName);}
                    else {
                      if(con.isActivate()) {await con.activate();}
                      else {con.deactivate();}
                      setState((){});
                    }
                  },
                  onLongPress: () async{
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                          contentPadding: const EdgeInsets.only(top:30.0, left:20, right:20),
                          content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children:[
                                Text(con.name+" 디바이스를 삭제합니다."),
                                const SizedBox(height: 10),
                              ]
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: const Text('취소'),
                              onPressed: () {
                                Navigator.pop(context);
                                setState((){});
                              },
                            ),
                            FlatButton(
                              child: const Text('확인'),
                              onPressed: () {
                                _removeCon(con);
                                Navigator.pop(context);
                                setState((){});
                              },
                            ),
                          ],
                        );},
                    );
                  }
              )
          ));
    });
    setState((){});
  }

  _removeCon(con) {
    var index = widget.btConnectionList.indexOf(con);
    widget.btConnectionList.removeAt(index);
    widget.btOptions.map.remove(con.address);
    widget.btOptions.save();

    for(int i=1; i<4; i++){
      widget.sensorOptions.map.remove('di'+((index*3)+i).toString());
      widget.sensorOptions.map.remove('di'+((index*3)+i).toString()+'_type');
      widget.sensorOptions.map.remove('di'+((index*3)+i).toString()+'_position');
      widget.sensorOptions.map.remove('di'+((index*3)+i).toString()+'_sensitivity');
    }

    var tempMap = Map();

    widget.sensorOptions.map.forEach((k, v){
      if(k.contains('di')){
        var i = k.substring(k.indexOf('di')+2, k.indexOf('di')+3);
        if(int.parse(i) > ((index*3)+3)){
          tempMap[k] = v;
        }
      }
    });

    tempMap.forEach((k, v){
      var i = k.substring(k.indexOf('di')+2, k.indexOf('di')+3);
      String key = k.replaceFirst(i, (int.parse(i)-3).toString());
      widget.sensorOptions.map[key] = v;
      widget.sensorOptions.map.remove(k);
    });

    widget.sensorOptions.save();
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

  _popupBluetoothSetting() async{
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            contentPadding: const EdgeInsets.all(0.0),
            content: SizedBox(
                height: 500, width: 400,
                child: BluetoothSettingPopup(widget.btConnectionList, widget.tcpConnection, widget.sensorTimeDataModelsMap, widget.btOptions, widget.sensorOptions, checkAvailability: false,)),
            actions: <Widget>[
              FlatButton(
                  child: const Text('닫기', style: TextStyle(color: Colors.black)),
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {});
                  }),],
          );
        });
  }

}