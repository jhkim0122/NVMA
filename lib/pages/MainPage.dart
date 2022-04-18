
import 'package:flutter/material.dart';

import '../models/DataDestination.dart';
import '../models/DataModel.dart';
import '../models/DataSource.dart';
import '../models/Parser.dart';
import '../models/Processor.dart';
import '../utils/NVMABottomNavigationBar.dart';
import 'NoiseMeasurementPage.dart';
import 'VibrationMeasurementPage.dart';

class MainPage extends StatefulWidget{
  const MainPage({key}) : super(key:key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 9999; // MainPage
  final int _noiseIndex = 0;
  final int _vibIndex = 1;

  var sensorTimeDataModelsMap = Map<String, RealtimeSensorTimeDataModel>();
  late MicCapture _micCapture;
  late BlueConnection _btConnection;
  late TcpConnection _tcpConnection;

  var _pageView;

  @override
  initState() {
    super.initState();
    _micCapture = MicCapture();
    var _micParser = InternalMicParser(sensorTimeDataModelsMap);
    var _micProcessor = ConvertToByteDataProcessor()..setDestination(Logger());
    _micParser.setProcessor(_micProcessor);
    _micCapture.setParser(InternalMicParser(sensorTimeDataModelsMap));

    _btConnection = BlueConnection();
    var _btParser = Esp32AdxlParser(0, sensorTimeDataModelsMap);
    var _btProcessor = ConvertToByteDataProcessor()..setDestination(Logger());
    _btParser.setProcessor(_btProcessor);
    _btConnection.setParser(_btParser);

    _tcpConnection = TcpConnection();
    var _tcpParser = NVDSDataParser(sensorTimeDataModelsMap);
    var _tcpProcessor = ConvertToByteDataProcessor()..setDestination(Logger());
    _tcpParser.setProcessor(_tcpProcessor);
    _tcpConnection.setParser(_tcpParser);

    _getPageView(selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return _pageView;
  }

  void _getPageView(index){
    _pageView = WillPopScope(
        onWillPop: () async{
          if(selectedIndex != 9999) {
            selectedIndex = 9999;
            _getPageView(selectedIndex);
            setState((){});
            return false;
          }
          else {
            return true;
          }
        },
        child: Scaffold(
          appBar: _getAppBar(index),
          body: _getBody(index),
          bottomNavigationBar: _getBottomNavigationBar(index),
      )
    );
    setState((){});
  }

  AppBar _getAppBar(index){
    if(index == 0){
      return AppBar(
        leading : IconButton(
            icon : const Icon(Icons.arrow_back),
            onPressed:() => setState((){
              selectedIndex = 9999;
              _getPageView(selectedIndex);
            }),
        ),
        title: const Text("Noise Measurement Page"),
        elevation:3.0,
      );
    } else if(index == 1) {
      return AppBar(
        leading : IconButton(
          icon : const Icon(Icons.arrow_back),
          onPressed:() => setState((){selectedIndex = 9999;
          _getPageView(selectedIndex);}),
        ),
        title: const Text("Vibration Measurement Page"),
        elevation:3.0,
      );
    } else { // Main page
      return AppBar(
        title: const Text("Noise Vibration Measurement App", style: TextStyle(fontSize:20, fontWeight: FontWeight.bold)),
        elevation:3.0,
      );
    }
  }

  Widget _getBody(index){
    if(index == 0){
      return NoiseMeasurementPage(_micCapture, sensorTimeDataModelsMap);
    } else if(index == 1) {
      return VibrationMeasurementPage(_btConnection, _tcpConnection, sensorTimeDataModelsMap);
    } else { // Main page
      return SingleChildScrollView(
            padding: const EdgeInsets.only(top:10, left:15, right:15),
            child: Column(
                children:[
                  ListTile(
                      leading: const Padding(
                          padding: EdgeInsets.only(left:10),
                          child: Icon(Icons.mic, color: Colors.black)
                      ),
                      title: const Text('Noise Measurement', style:TextStyle(fontSize:18, fontWeight: FontWeight.bold)),
                      subtitle: const Padding(padding:EdgeInsets.only(left:5, top:10), child:Text('내장마이크로 소음 측정', style:TextStyle(color:Colors.grey))),
                      trailing: const Icon(Icons.navigate_next),
                      contentPadding: const EdgeInsets.symmetric(vertical:10),
                      onTap: () => setState((){
                        selectedIndex = _noiseIndex;
                        _getPageView(selectedIndex);
                      })
                  ),
                  const Divider(height:2.0, color: Colors.black45),
                  ListTile(
                      leading: const Padding(
                          padding: EdgeInsets.only(left:12, top:5),
                          child:Icon(Icons.vibration, color: Colors.black)
                      ),
                      title: const Text('Vibration Measurement', style:TextStyle(fontSize:18, fontWeight: FontWeight.bold)),
                      subtitle: const Padding(padding:EdgeInsets.only(left:5, top:10), child:Text('무선 센서로 진동 측정', style:TextStyle(color:Colors.grey))),
                      trailing: const Icon(Icons.navigate_next),
                      contentPadding: const EdgeInsets.symmetric(vertical:10),
                      onTap: () => setState((){
                        selectedIndex = _vibIndex;
                        _getPageView(selectedIndex);
                      })
                  ),
                  const Divider(height:2.0, color: Colors.black45),
                ])
        );
    }
  }

  Widget _getBottomNavigationBar(index){
    if(index == 0){
      return NVMABottomNavigationBar(_getPageView, currentPage:'noise');
    } else if(index == 1) {
      return NVMABottomNavigationBar(_getPageView, currentPage:'vibration');
    }
    else {
      return const SizedBox();
    }
  }
}